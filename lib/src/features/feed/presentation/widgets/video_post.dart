import 'dart:async';

import 'play_controls.dart';

import '../../../profile/presentation/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../data/stats_repository.dart';
import '../../domain/models/video_model.dart';
import '../../domain/models/dictionary_model.dart';
import '../../../onboarding/presentation/widgets/panda_button.dart';
import 'captions_overlay.dart';
import 'comments_panel.dart';
import 'dictionary_panel.dart';
import 'players/tiktok_player.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'players/youtube_player.dart';
import '../providers/stats_provider.dart';

class VideoPost extends ConsumerStatefulWidget {
  final VideoModel video;
  final bool isPlaying;
  final bool hideContent;
  final VoidCallback onStartQuiz;
  final VoidCallback onShowComments;

  final Function(String title, Widget content) onShowPanel;

  const VideoPost({
    super.key,
    required this.video,
    required this.isPlaying,
    this.hideContent = false,
    required this.onStartQuiz,
    required this.onShowComments,
    required this.onShowPanel,
    this.onSkip,
    this.onProgress, // Add progress callback if needed for top bar
  });

  final Function(double)? onProgress;
  final VoidCallback? onSkip;

  @override
  ConsumerState<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends ConsumerState<VideoPost> {
  bool _isPaused = false;
  Timer? _progressTimer;
  bool _isMuted = false;
  bool _xpAwarded = false;

  // Notifiers for UI updates
  final ValueNotifier<double> _currentTimeNotifier = ValueNotifier(0.0);
  final StreamController<int> _seekController =
      StreamController<int>.broadcast();

  // Tutorial Keys
  final GlobalKey _captionsKey = GlobalKey();
  final GlobalKey _startExerciseKey = GlobalKey();
  final GlobalKey _nextButtonKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;
  late StatsRepository _statsRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statsRepository = ref.read(statsRepositoryProvider);
  }

  @override
  void dispose() {
    _saveStats(widget.video);
    _stopTimer();
    _currentTimeNotifier.removeListener(_tutorialListener);
    _currentTimeNotifier.dispose();
    super.dispose();
  }

  void _toggleCaptions() {
    print('toggle captions');
    ref.read(settingsProvider.notifier).toggleCaptions();
  }

  void _startTimer() {
    _stopTimer();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _currentTimeNotifier.value += 0.016;
    });
  }

  void _stopTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _handleWordTap(String word) async {
    setState(() {
      _isPaused = true;
    });

    try {
      widget.onShowPanel(
        "Loading...",
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrand),
        ),
      );

      final data = await ApiClient.post('/dictionary', body: {'word': word});
      final dictionaryData = DictionaryModel.fromJson(data['data'][0]);

      if (mounted) {
        widget.onShowPanel(
          "Dictionary 📖",
          DictionaryPanel(
            data: dictionaryData,
            onClose: () {
              Navigator.of(context).pop();
            },
            videoId: widget.video.id,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onShowPanel(
          "Error",
          Center(
            child: Text(
              "Could not load definition for $word",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    // The player widget listens to 'isPlaying'.
    // We combine widget.isPlaying (scroll state) with _isPaused (user interaction).
  }

  @override
  void didUpdateWidget(VideoPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent says stop (scrolled away), ensure we reset local pause state or handle it?
    // Actually if scrolled away, widget.isPlaying becomes false.
    // If we scroll back, it becomes true. We probably want to respect the user's manual pause?
    // Let's reset manual pause on new video, but keep it if just scrolling back?
    // Simplify: Reset on video change.

    if (widget.video.url != oldWidget.video.url) {
      _saveStats(oldWidget.video);
      _handleVideoChanged();
    }

    // If we hide content (panel open), we treat it as paused.
    if (widget.hideContent != oldWidget.hideContent) {
      // logic handled in build via effectiveIsPlaying
    }
  }

  void _saveStats(VideoModel video) {
    final duration = _currentTimeNotifier.value;
    print('save stats');
    print('video duration $duration');
    if (duration > 1.0) {
      // Only save if watched at least 1 second
      _statsRepository.updateUserVideoStats(
        videoId: video.id,
        viewDuration: duration,
        lastViewedAt: DateTime.now(),
      );

      // Add XP for watching video
      if (!_xpAwarded) {
        _xpAwarded = true;
        ref
            .read(userLanguageProfileProvider.notifier)
            .addXp(event: 'watch_video', videoId: widget.video.id);
      }
    }
  }

  void _handleVideoChanged() {
    setState(() {
      _currentTimeNotifier.value = 0.0;
      _isPaused = false;
      _xpAwarded = false;
    });
  }

  bool _isVideoLoaded = false;

  void _onPlayerStateChange(bool isPlaying) {
    if (isPlaying) {
      // If the player reports it's playing, start our smoothing timer
      _startTimer();
      // Also ensure our UI reflects it (e.g. if autoplayed)
      if (_isPaused && mounted) setState(() => _isPaused = false);

      // Mark as loaded once it starts playing
      if (!_isVideoLoaded && mounted) {
        setState(() {
          _isVideoLoaded = true;
        });
      }
    } else {
      _stopTimer();
    }
  }

  void _onPlayerEnded() {
    _stopTimer();
    _saveStats(widget.video);
    _currentTimeNotifier.value = 0.0;
    // Loop logic is often handled by the player (TikTok/YouTube loop params),
    // but if we need to manually restart:
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Effective playing state:
    // 1. Must be the active video (widget.isPlaying)
    // 2. Must not be manually paused (_isPaused)
    // 3. Must not have content hidden (panel open)
    final effectiveIsPlaying =
        widget.isPlaying && !_isPaused && !widget.hideContent;

    final isYouTube = widget.video.platformType.toLowerCase() == 'youtube';
    String videoId = widget.video.externalId;
    if (videoId.isEmpty) {
      videoId = _extractVideoId(widget.video.url) ?? '';
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPlayer(effectiveIsPlaying),

        // Removed: if (!_isInitialized) ... Loading indicator
        // We can add it back if the Players report "isLoaded" state,
        // but for now let's rely on the player's native loading or add a callback later.
        // 1. Transparent Tap Layer
        PointerInterceptor(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(color: Colors.transparent),
          ),
        ),

        // 3. Bottom Gradient (For text readability)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        if (_isPaused || !widget.isPlaying && !widget.hideContent)
          Center(
            child: PointerInterceptor(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        // Actions Column (Right Side)
        Positioned(
          right: 16,
          bottom: 80, // Adjusted to sit above button
          child: PointerInterceptor(
            child: Column(
              children: [
                // Profile
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileView(),
                            ),
                          );
                        },
                        child: Consumer(
                          builder: (context, ref, child) {
                            final profileAsync = ref.watch(userProfileProvider);
                            final avatarUrl =
                                profileAsync.value?['avatar_url'] as String?;

                            return CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                avatarUrl ??
                                    "https://lh3.googleusercontent.com/aida-public/AB6AXuANlJyF7pvtcA0vFRyJEQFa7XkoUIgUyQWhE4Gc5CZE8a4qkbeRdMDmCCNIqHtI5LhZkzSGSyBvbeCZz0oq0FcN3KL1M-MvQ2l4sJ1mjtyIoIfghT_RcENVTfhs5UmfWeF3Hy_lunl8MS3gOi6healG8WlHFAwKXJvg1o-2dbVwZ9NWy5seJpd-Y0ppzUuDydRuCBKS8aXs7q-0XAYayTXRuct4XnkgMaCvJzy8ef9tfS5sXuoBtbz3tcoEn-kaFdYvJebPEUqDxoE",
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Like
                _buildActionItem(
                  Icons.favorite_rounded,
                  "12.5k",
                  Colors.white,
                  isLike: true,
                ),
                const SizedBox(height: 20),

                _buildActionItem(
                  Icons.chat_bubble_rounded,
                  "342", // TODO: Real count
                  Colors.white,
                  onTap: () {
                    widget.onShowPanel(
                      "Comments 💬",
                      CommentsPanel(videoId: widget.video.id),
                    );
                  },
                  size: 24,
                ),
                const SizedBox(height: 20),
                _buildActionItem(
                  settings.captions
                      ? Icons.closed_caption
                      : Icons.closed_caption_off,
                  "Caption",
                  Colors.white,
                  onTap: _toggleCaptions,
                ),
              ],
            ),
          ),
        ),

        // Bottom Info Area (Left Side)
        Positioned(
          left: 16,
          right: 80, // Space for actions
          bottom: 80, // aligned with actions bottom
          child: PointerInterceptor(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Captions Overlay
                if (settings.captions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RepaintBoundary(
                      child: CaptionsOverlay(
                        key: _captionsKey,
                        currentTimeNotifier: _currentTimeNotifier,
                        captions: widget.video.captions,
                        onWordTap: _handleWordTap,
                        translations: widget.video.translations,
                      ),
                    ),
                  ),

                // Title (Chinese)
                if (widget.video.title.isNotEmpty)
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w100,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                // Play Controls
                if (widget.video.platformType.toLowerCase() == 'youtube')
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: PlayControls(
                      isPlaying: effectiveIsPlaying,
                      onPlayPause: _togglePlayPause,
                      onRewind: () => _seekController.add(-5),
                      onForward: () => _seekController.add(5),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 4. Start Exercise Button + Skip Button (Bottom Fixed)
        Positioned(
          left: 16,
          right: 16,
          bottom: 10,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.hideContent ? 0.0 : 1.0,
            child: PointerInterceptor(
              child: IgnorePointer(
                ignoring: widget.hideContent,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: Container(
                          key: _startExerciseKey,
                          child: PandaButton(
                            text: "START EXERCISE",
                            onPressed: widget.onStartQuiz,
                            disabled: _isTutorialShowing,
                            icon: Icons.pets,
                            borderColor: Colors.black,
                            shadowColor: const Color.fromARGB(255, 38, 38, 38),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Skip Button
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Container(
                        key: _nextButtonKey,
                        child: PandaButton(
                          text: "",
                          icon: Icons.arrow_forward_rounded,
                          onPressed: widget.onSkip ?? () {},
                          disabled: _isTutorialShowing,
                          backgroundColor: Colors.white,
                          textColor: AppColors.pandaBlack,
                          borderColor: Colors.black,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _extractVideoId(String url) {
    if (url.trim().isEmpty) return null;

    // YouTube
    // 1. Shorts: youtube.com/shorts/{videoId}
    final shortsRegex = RegExp(
      r'youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final shortsMatch = shortsRegex.firstMatch(url);
    if (shortsMatch != null && shortsMatch.groupCount >= 1) {
      return shortsMatch.group(1);
    }

    // 2. Watch: youtube.com/watch?v={videoId}
    final watchRegex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtube\.com\/.*[?&]v=)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final watchMatch = watchRegex.firstMatch(url);
    if (watchMatch != null && watchMatch.groupCount >= 1) {
      return watchMatch.group(1);
    }

    // 3. Short URL: youtu.be/{videoId}
    final shortUrlRegex = RegExp(
      r'youtu\.be\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final shortUrlMatch = shortUrlRegex.firstMatch(url);
    if (shortUrlMatch != null && shortUrlMatch.groupCount >= 1) {
      return shortUrlMatch.group(1);
    }

    // 4. Fallback complex regex if needed, or rely on the above.
    // The previous regex was:
    // r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})'
    // Let's keep a simplified fallback for embed/etc if needed.
    final embedRegex = RegExp(
      r'youtube\.com\/(?:v|embed)\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final embedMatch = embedRegex.firstMatch(url);
    if (embedMatch != null && embedMatch.groupCount >= 1) {
      return embedMatch.group(1);
    }

    // TikTok (Simple pattern matching, might need refinement)
    // https://www.tiktok.com/@user/video/7438493829482939393
    final ttRegex = RegExp(
      r'tiktok\.com\/@[\w.-]+\/video\/(\d+)',
      caseSensitive: false,
    );
    final ttMatch = ttRegex.firstMatch(url);
    if (ttMatch != null && ttMatch.groupCount >= 1) {
      return ttMatch.group(1);
    }

    return null;
  }

  Widget _buildPlayer(bool isPlaying) {
    final isYouTube = widget.video.platformType.toLowerCase() == 'youtube';

    String videoId = widget.video.externalId;

    if (videoId.isEmpty) {
      videoId = _extractVideoId(widget.video.url) ?? '';
    }

    if (isYouTube) {
      return YouTubePlayer(
        videoId: videoId,
        isPlaying: isPlaying,
        onCurrentTime: (time) {
          // Sync timer
          _currentTimeNotifier.value = time;
          if (!_isVideoLoaded && time > 0 && mounted) {
            setState(() {
              _isVideoLoaded = true;
            });
          }
        },
        onStateChange: _onPlayerStateChange,
        onEnded: _onPlayerEnded,
        seekStream: _seekController.stream,
      );
    }

    return TikTokPlayer(
      videoId: videoId,
      isPlaying: isPlaying,
      onCurrentTime: (time) {
        _currentTimeNotifier.value = time;
      },
      onStateChange: _onPlayerStateChange,
      onEnded: _onPlayerEnded,
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color color, {
    bool isLike = false,
    VoidCallback? onTap,
    double size = 32,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: size,
              color: isLike ? Colors.red : color,
              shadows: [
                const Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldCheckTutorial = false; // Initialized in initState
  bool _isTutorialShowing = false;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // If key exists, we don't need to check anymore.
        _shouldCheckTutorial = !prefs.containsKey('has_shown_main_tutorial');
        if (_shouldCheckTutorial) {
          _currentTimeNotifier.addListener(_tutorialListener);
        }
      });
    }
  }

  void _tutorialListener() async {
    final currentTime = _currentTimeNotifier.value;
    bool hasCaption = false;

    // Check if any caption is currently active
    for (final caption in widget.video.captions) {
      if (caption.words.isNotEmpty) {
        final start = caption.words.first.start;
        final end = caption.words.last.end;
        if (currentTime >= start && currentTime <= end) {
          hasCaption = true;
          break;
        }
      }
    }

    if (hasCaption) {
      // 1. Found a caption, stop listening immediately
      _currentTimeNotifier.removeListener(_tutorialListener);
      _shouldCheckTutorial = false;

      // 2. Pause the video
      if (mounted) {
        setState(() {
          _isPaused = true;
        });
      }

      // Delay slightly to ensure UI is updated (paused state) before overlay
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      _createTutorial();

      setState(() {
        _isTutorialShowing = true;
      });
      tutorialCoachMark?.show(context: context);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_shown_main_tutorial', true);

      if (mounted) {
        setState(() {
          _shouldCheckTutorial = false;
        });
      }
    }
  }

  void _createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("finish");
        setState(() {
          _isTutorialShowing = false;
          _isPaused = false;
        });
      },
      onClickTarget: (target) {
        if (target.identify == 'start_exercise') {
          // widget.onStartQuiz();
        } else if (target.identify == 'next_video') {
          // widget.onSkip?.call();
        }
      },
      onSkip: () {
        print("skip");
        setState(() {
          _isTutorialShowing = false;
          _isPaused = false;
        });
        return true;
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    // 1. Captions
    targets.add(
      TargetFocus(
        identify: "captions",
        keyTarget: _captionsKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tap to Look Up! 👆",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tap on any Chinese character in the captions to see its meaning instantly.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 10,
      ),
    );

    // 2. Start Exercise
    targets.add(
      TargetFocus(
        identify: "start_exercise",
        keyTarget: _startExerciseKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return PointerInterceptor(
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ready to Practice? 🐼",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tap here to start a quick quiz based on this video.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 10,
      ),
    );

    // 3. Skip
    targets.add(
      TargetFocus(
        identify: "next_video",
        keyTarget: _nextButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return PointerInterceptor(
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Not interested? ⏭️",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tap here or swipe up to go to the next video.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 20, // Check if available, otherwise just larger radius?
      ),
    );

    return targets;
  }
}
