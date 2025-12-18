import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/video_model.dart';
import '../../domain/models/dictionary_model.dart';
import 'captions_overlay.dart';
import 'dictionary_panel.dart';

class VideoPost extends StatefulWidget {
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
  State<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
  late WebViewController _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPaused = false;
  double _currentTime = 0.0;
  Timer? _captionTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      _isLoading = true;
      _initializeWebView();
    }
  }

  @override
  void dispose() {
    _captionTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _captionTimer?.cancel();
    _captionTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _currentTime += 0.05;
        });
      }
    });
  }

  void _stopTimer() {
    _captionTimer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    if (mounted) {
      setState(() {
        _currentTime = -1.0;
      });
    }
  }

  void _handleWordTap(String word) async {
    // Pause video immediately
    _sendMessage("pause");
    _stopTimer();
    if (mounted) {
      setState(() {
        _isPaused = true;
      });
    }

    try {
      // Show loading panel
      widget.onShowPanel(
        "Loading...",
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrand),
        ),
      );

      print('Look up word: $word');

      final data = await ApiClient.post('/dictionary', body: {'word': word});
      final dictionaryData = DictionaryModel.fromJson(data['data'][0]);

      if (mounted) {
        widget.onShowPanel(
          "Dictionary 📖",
          DictionaryPanel(data: dictionaryData),
        );
      }
    } catch (e) {
      debugPrint("Error fetching dictionary data: $e");
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
      _stopTimer();
    } else {
      _sendMessage("play");
      // Timer will start via onStateChange
    }
  }

  void _initializeWebView() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    const double iframeWidth = 4000;
    final double iframeHeight = screenWidth * 16 / 9;

    final String htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        
        <style>
          body {
            margin: 0;
            padding: 0;
            background-color: black;
            display: flex;
            justify-content: center;
            padding-top: 0;
            overflow: hidden;
          }

          .video-container {            
            width: ${iframeWidth}px;
            height: ${screenHeight}px; 
            overflow: hidden;      
            position: relative;       
            background: black;            
          }
          iframe {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 4000px;
            height: ${screenHeight}px;
            border: none;
          }
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
              if (data && data.type === "onStateChange") {
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

    // Platform-specific creation params
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

            if (data['type'] == 'onStateChange') {
              final state = data['value'] as int?;
              // 1: playing, 2: paused, 0: ended
              if (state == 1) {
                _startTimer();
                // Ensure UI reflects playing state if it was triggered externally
                if (_isPaused && mounted) {
                  setState(() {
                    _isPaused = false;
                  });
                }
              } else if (state == 2) {
                _stopTimer();
                // Ensure UI reflects paused state
                if (!_isPaused && mounted) {
                  setState(() {
                    _isPaused = true;
                  });
                }
              } else if (state == 0) {
                _resetTimer();
              }
            }
          } catch (e) {
            debugPrint('Error parsing JS message: $e');
            debugPrint('Raw message: ${message.message}');
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
              // Apply initial state after a short delay to allow iframe to load
              Future.delayed(const Duration(milliseconds: 100), _applyState);
            }
          },
        ),
      );

    // Android-specific configuration
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
    // If panel state changed (hideContent), pause/resume video
    if (widget.hideContent != oldWidget.hideContent) {
      if (widget.hideContent) {
        // Panel is open, pause video
        _sendMessage("pause");
        _stopTimer();
        setState(() {
          _isPaused = true;
        });
      } else if (widget.isPlaying) {
        // Panel closed and this video is active, resume
        _sendMessage("play");
        setState(() {
          _isPaused = false;
        });
        // Timer will start via onStateChange
      }
    }
  }

  void _applyState() {
    if (!_isInitialized) return;

    if (widget.isPlaying) {
      _sendMessage("unMute");
      _sendMessage("seekTo", value: 0);
      _sendMessage("play");
      // Reset timer when re-playing from start (implied by seekTo 0)
      if (mounted) {
        setState(() {
          _currentTime = 0.0;
          _isPaused = false;
        });
      }
    } else {
      _sendMessage("mute");
      _sendMessage("play"); // Keep playing but muted (preloading)
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
    final progress = widget.video.durationSeconds > 0
        ? (_currentTime / widget.video.durationSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // WebView Layer
        WebViewWidget(controller: _controller),

        // Loading Indicator
        if (!_isInitialized)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBrand),
          ),

        // Gradient Overlay & Tap Detector
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

        // Play Icon (Centered)
        if (_isPaused)
          Center(
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

        // Right Side Actions
        Positioned(
          right: AppSpacing.md,
          bottom: 120, // Adjusted for progress bar and button
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
                Icons.closed_caption,
                "Captions",
                Colors.white,
              ),
            ],
          ),
        ),

        // Left Side Content (Captions & Title)
        Positioned(
          left: AppSpacing.md,
          right: 80, // Space for right actions
          bottom: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Captions Overlay
              CaptionsOverlay(
                video: widget.video,
                currentTime: _currentTime,
                onWordTap: _handleWordTap,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Title / Description
              Text(
                widget.video.description, // Using description as title for now
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Progress Bar
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4,
            ),
          ),
        ),

        // Start Quiz Button
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
