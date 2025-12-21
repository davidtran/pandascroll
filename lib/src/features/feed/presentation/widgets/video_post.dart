import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/progress_bar_painter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../domain/models/video_model.dart';
import '../../domain/models/dictionary_model.dart';
import 'captions_overlay.dart';
import 'dictionary_panel.dart';

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
  });

  @override
  ConsumerState<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends ConsumerState<VideoPost> {
  late WebViewController _controller;
  bool _isInitialized = false;
  bool _isPaused = false;
  Timer? _progressTimer;

  // Notifiers for UI updates
  final ValueNotifier<double> _currentTimeNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

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
    _sendMessage("pause");
    // No need to stop timer manually, the WebView will stop sending time updates
    if (mounted) {
      setState(() {
        _isPaused = true;
      });
    }

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
    if (_isPaused) {
      _sendMessage("pause");
    } else {
      _sendMessage("play");
    }
  }

  void _initializeWebView() {
    // ... existing iframe setup ...
    const double iframeWidth = 4000;

    final String htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; padding: 0; background-color: black; display: flex; justify-content: center; overflow: hidden; height: 100vh; }
          .video-container { width: ${iframeWidth}px; height: 100vh; overflow: hidden; position: relative; background: black; }
          iframe { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 4000px; height: 100vh; border: none; }
        </style>
      </head>
      <body>
      <div class="video-container">
        <iframe 
          id="tiktok-frame"
          src="https://www.tiktok.com/player/v1/${widget.video.externalId}?music_info=1&description=1&controls=0&progress_bar=0&play_button=0&native_context_menu=0&closed_caption=0&rel=0&timestamp=0&autoplay=1&loop=1" 
          allow="autoplay">
        </iframe>
      </div>
      <script>
        window.addEventListener('message', function(event) {
          if (event.origin === "https://www.tiktok.com") {
            const data = event.data;
            if (data && (data.type === "onStateChange" || data.type === "onCurrentTime")) {
               if (window.FlutterCaptions) {
                 window.FlutterCaptions.postMessage(JSON.stringify(data));
               }
            }
          }
        });
      </script>
      </body>
      </html>
    ''';
    // ... params setup ...
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const {},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'FlutterCaptions',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            final type = data['type'];

            if (type == 'onCurrentTime') {
              double newTime = 0.0;
              final value = data['value'];
              if (value is num) {
                newTime = value.toDouble();
              } else if (value is Map) {
                newTime = (value['currentTime'] as num? ?? 0.0).toDouble();
              }
              // Sync timer to avoid drift
              _currentTimeNotifier.value = newTime;
            } else if (type == 'onStateChange') {
              final state = data['value'] as int?;
              // 1: playing, 2: paused, 0: ended
              if (state == 1) {
                if (_isPaused && mounted) setState(() => _isPaused = false);
                _startTimer();
              } else if (state == 2) {
                if (!_isPaused && mounted) setState(() => _isPaused = true);
                _stopTimer();
              } else if (state == 0) {
                _currentTimeNotifier.value = 0.0;
                _stopTimer();
                // Loop behavior - start again if needed or wait for play
                _startTimer(); // TikTok player usually loops automatically
              }
            }
          } catch (e) {
            debugPrint('Error parsing JS message: $e');
          }
        },
      )
      ..loadHtmlString(htmlContent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              Future.delayed(const Duration(milliseconds: 500), _applyState);
            }
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  void didUpdateWidget(VideoPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      _applyState();
    }
    if (widget.video.url != oldWidget.video.url) {
      _handleVideoChanged();
    }
    if (widget.hideContent != oldWidget.hideContent) {
      if (widget.hideContent) {
        _sendMessage("pause");
        setState(() => _isPaused = true);
      } else if (widget.isPlaying) {
        _sendMessage("play");
        setState(() => _isPaused = false);
      }
    }
  }

  void _handleVideoChanged() {
    setState(() {
      _currentTimeNotifier.value = 0.0;
      _isInitialized = false;
      _isPaused = false;
    });
    // Reset captions
  }

  void _applyState() {
    if (!_isInitialized) return;

    if (widget.isPlaying) {
      _sendMessage("seekTo", value: 0);
      _sendMessage("play");
      _sendMessage("unMute");
      _currentTimeNotifier.value = 0.0;
      if (mounted) setState(() => _isPaused = false);
    } else {
      _sendMessage("mute");
      _sendMessage("play");
    }
  }

  void _sendMessage(String type, {dynamic value}) {
    final valuePart = value != null ? ', value: $value' : '';
    _controller.runJavaScript('''
      var iframe = document.getElementById('tiktok-frame');
      if (iframe) {
        iframe.contentWindow.postMessage({type: "$type", "x-tiktok-player": true $valuePart}, '*');
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final showCaptions = ref.watch(settingsProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (!_isInitialized)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBrand),
          ),
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        if (_isPaused)
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
        Positioned(
          right: AppSpacing.md,
          bottom: 120,
          child: Column(
            children: [
              _buildProfileButton(),
              const SizedBox(height: AppSpacing.lg),
              _buildActionButton(Icons.favorite_rounded, "24.5K", Colors.red),
              const SizedBox(height: AppSpacing.lg),
              _buildActionButton(
                Icons.comment_rounded,
                "1.2K",
                Colors.white,
                onTap: widget.onShowComments,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildActionButton(
                showCaptions
                    ? Icons.closed_caption
                    : Icons.closed_caption_disabled,
                "Captions",
                Colors.white,
                onTap: () {
                  ref.read(settingsProvider.notifier).toggleCaptions();
                },
              ),
            ],
          ),
        ),
        if (showCaptions)
          Positioned(
            left: AppSpacing.md,
            right: 80,
            bottom: 120,
            child: RepaintBoundary(
              child: CaptionsOverlay(
                currentTimeNotifier: _currentTimeNotifier,
                captions: widget.video.captions,
                onWordTap: _handleWordTap,
                translations: widget.video.translations,
              ),
            ),
          ),
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: 100,
          child: RepaintBoundary(
            child: SizedBox(
              height: 4,
              child: CustomPaint(
                painter: ProgressBarPainter(
                  timeNotifier: _currentTimeNotifier,
                  totalDuration: widget.video.durationSeconds.toDouble(),
                  backgroundColor: Colors.white24,
                  progressColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: AppSpacing.lg,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.hideContent ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: widget.hideContent,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onStartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5DD3), Color(0xFFFF754C)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.gamepad_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "START QUIZ ⚔️",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(widget.video.authorUrl),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
