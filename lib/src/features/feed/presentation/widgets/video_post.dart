import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class VideoPost extends StatefulWidget {
  final String videoUrl; // This is now the TikTok ID
  final bool isPlaying;
  final bool hideContent;
  final VoidCallback onStartQuiz;
  final VoidCallback onShowComments;

  const VideoPost({
    super.key,
    required this.videoUrl,
    required this.isPlaying,
    this.hideContent = false,
    required this.onStartQuiz,
    required this.onShowComments,
  });

  @override
  State<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
  late WebViewController _controller;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      _isLoading = true;
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double iframeWidth = 4000;
    final double iframeHeight = screenWidth * 16 / 9;

    final String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body {
            margin: 0;
            padding: 0;
            background-color: black;
            height: 100vh;
            width: 100vw;
            overflow: hidden;
            position: relative;
          }
          iframe {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            border: none;
          }
        </style>
      </head>
      <body>
        <iframe 
          id="tiktok-frame"
          width="$iframeWidth" 
          height="$iframeHeight" 
          src="https://www.tiktok.com/player/v1/${widget.videoUrl}?music_info=1&description=1&controls=0&progress_bar=0&play_button=0&native_context_menu=0&closed_caption=0&rel=0&timestamp=0&autoplay=1&loop=1" 
          allow="fullscreen; autoplay">
        </iframe>
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

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false)
      ..loadHtmlString(htmlContent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              // Apply initial state after a short delay to allow iframe to load
              Future.delayed(const Duration(milliseconds: 500), _applyState);
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
  }

  void _applyState() {
    if (!_isInitialized) return;

    if (widget.isPlaying) {
      _sendMessage("unMute");
      _sendMessage("seekTo", value: 0);
      _sendMessage("play");
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // WebView Layer
        WebViewWidget(controller: _controller),

        // Loading Indicator
        if (!_isInitialized)
          const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand)),

        // Gradient Overlay
        Container(
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

        // Right Side Actions
        Positioned(
          right: AppSpacing.md,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite_rounded, "24.5K", Colors.red),
              const SizedBox(height: AppSpacing.lg),
              _buildActionButton(
                Icons.comment_rounded, 
                "1.2K", 
                Colors.white,
                onTap: widget.onShowComments,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildActionButton(Icons.share_rounded, "450", Colors.white),
            ],
          ),
        ),

        // Bottom Info (Hidden when panel is open)
        Positioned(
          left: AppSpacing.md,
          bottom: 100,
          right: 80,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.hideContent ? 0.0 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@SenseiPanda",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Essential coffee shop phrases! ☕️ #japanese #study",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start Quiz Button (Hidden when panel is open)
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

  Widget _buildActionButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
