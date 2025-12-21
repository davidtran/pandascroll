import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../domain/models/video_model.dart';
import '../../domain/models/dictionary_model.dart';
import '../../../onboarding/presentation/widgets/panda_button.dart'; // Import PandaButton
import 'captions_overlay.dart';
import 'dictionary_panel.dart';
import 'players/tiktok_player.dart';
import 'players/youtube_player.dart';

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
    this.onProgress, // Add progress callback if needed for top bar
  });

  final Function(double)? onProgress;

  @override
  ConsumerState<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends ConsumerState<VideoPost> {
  bool _isPaused = false;
  Timer? _progressTimer;

  // Notifiers for UI updates
  final ValueNotifier<double> _currentTimeNotifier = ValueNotifier(0.0);

  @override
  void dispose() {
    _stopTimer();
    _currentTimeNotifier.dispose();
    super.dispose();
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
    // If we want to pause when tapping a word, we might need a way to tell the child player to pause.
    // However, the current architecture relies on passing 'isPlaying' down.
    // If we change local state here, we might need to notify the player.
    // Simply setting _isPaused here updates the UI (button), but to actually pause the player
    // we need to change the 'isPlaying' prop passed to the child.
    // BUT 'isPlaying' comes from the parent FeedView (based on index).

    // Workaround: We can't easily force the child to pause via props if the parent controls isPlaying.
    // But we can 'request' the parent to pause, or use a local override.
    // For now, let's assume the user just wants the dictionary.
    // Usually opening a dialog/panel covers the screen, effectively pausing or we want it to pause.

    // To properly pause, we should probably update a local "override" variable that we combine with widget.isPlaying.
    setState(() {
      _isPaused = true;
    });

    // We'll handle the actual pausing by passing `widget.isPlaying && !_isPaused` to the player.

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
          DictionaryPanel(data: dictionaryData),
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
      _handleVideoChanged();
    }

    // If we hide content (panel open), we treat it as paused.
    if (widget.hideContent != oldWidget.hideContent) {
      // logic handled in build via effectiveIsPlaying
    }
  }

  void _handleVideoChanged() {
    setState(() {
      _currentTimeNotifier.value = 0.0;
      _isPaused = false;
    });
  }

  void _onPlayerStateChange(bool isPlaying) {
    if (isPlaying) {
      // If the player reports it's playing, start our smoothing timer
      _startTimer();
      // Also ensure our UI reflects it (e.g. if autoplayed)
      if (_isPaused && mounted) setState(() => _isPaused = false);
    } else {
      _stopTimer();
      if (!_isPaused && mounted) setState(() => _isPaused = true);
    }
  }

  void _onPlayerEnded() {
    _stopTimer();
    _currentTimeNotifier.value = 0.0;
    // Loop logic is often handled by the player (TikTok/YouTube loop params),
    // but if we need to manually restart:
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final showCaptions = ref.watch(settingsProvider);

    // Effective playing state:
    // 1. Must be the active video (widget.isPlaying)
    // 2. Must not be manually paused (_isPaused)
    // 3. Must not have content hidden (panel open)
    final effectiveIsPlaying =
        widget.isPlaying && !_isPaused && !widget.hideContent;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPlayer(effectiveIsPlaying),

        // Removed: if (!_isInitialized) ... Loading indicator
        // We can add it back if the Players report "isLoaded" state,
        // but for now let's rely on the player's native loading or add a callback later.
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),
        if (_isPaused || !widget.isPlaying && !widget.hideContent)
          Center(
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
        // Actions Column (Right Side)
        Positioned(
          right: 16,
          bottom: 110, // Adjusted to sit above bottom nav area
          child: Column(
            children: [
              const SizedBox(height: 16),
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
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(widget.video.authorUrl),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.accent, // Orange
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.white, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
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

              // Comment
              _buildActionItem(
                Icons.chat_bubble_rounded,
                "342",
                Colors.white,
                onTap: widget.onShowComments,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Bottom Info Area (Left Side)
        Positioned(
          left: 16,
          right: 80, // Space for actions
          bottom: 24, // Bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Captions Overlay (Moved here)
              if (showCaptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RepaintBoundary(
                    child: CaptionsOverlay(
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
                    fontSize: 16, // Big text
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

              const SizedBox(height: 10),

              // Start Exercise Button
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.hideContent ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: widget.hideContent,
                  child: SizedBox(
                    width: double.infinity,
                    child: PandaButton(
                      text: "START EXERCISE",
                      onPressed: widget.onStartQuiz,
                      icon: Icons.pets,
                      backgroundColor: AppColors.accent, // Orange
                      textColor: Colors.white,
                      borderColor: AppColors.accent,

                      shadowColor: const Color(
                        0xFFB45309,
                      ), // Dark orange shadow
                      // Provide font override if needed or rely on default
                    ),
                  ),
                ),
              ),
            ],
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
          // Only update if difference is significant to avoid jitter from async JS updates?
          // Actually, just updating value is fine, it corrects drift.
          _currentTimeNotifier.value = time;
        },
        onStateChange: _onPlayerStateChange,
        onEnded: _onPlayerEnded,
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
              size: 32,
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

  Widget _buildMusicDisc() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[800]!, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Center(
        child: ClipOval(
          child: Image.network(
            widget.video.authorUrl,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ),
    );
  }
}
