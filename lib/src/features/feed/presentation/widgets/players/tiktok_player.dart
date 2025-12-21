import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class TikTokPlayer extends StatefulWidget {
  final String videoId; // The externalId
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange; // true: playing, false: paused
  final VoidCallback onEnded;

  const TikTokPlayer({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
  });

  @override
  State<TikTokPlayer> createState() => _TikTokPlayerState();
}

class _TikTokPlayerState extends State<TikTokPlayer> {
  late WebViewController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(TikTokPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      _applyState();
    }
    if (widget.videoId != oldWidget.videoId) {
      _loadNewVideo();
    }
  }

  void _loadNewVideo() {
    setState(() {
      _isInitialized = false;
    });
    // For WebView, reloading the HTML content is often checks for cleaner state,
    // but full Controller recreation might be safer to avoid cache issues
    // with iframe players. We can try just reloading content first.
    _initializeWebView();
  }

  void _initializeWebView() {
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
          src="https://www.tiktok.com/player/v1/${widget.videoId}?music_info=1&description=1&controls=0&progress_bar=0&play_button=0&native_context_menu=0&closed_caption=0&rel=0&timestamp=0&autoplay=1&loop=1" 
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
              widget.onCurrentTime(newTime);
            } else if (type == 'onStateChange') {
              final state = data['value'] as int?;
              // 1: playing, 2: paused, 0: ended
              if (state == 1) {
                widget.onStateChange(true);
              } else if (state == 2) {
                widget.onStateChange(false);
              } else if (state == 0) {
                widget.onEnded();
                // Loop? We currently have loop=1 in the URL, so it might not hit here often
                // or will hit here and restart.
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
              // Initial state sync
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

  void _applyState() {
    if (!_isInitialized) return;

    if (widget.isPlaying) {
      _sendMessage("play");
      _sendMessage("unMute");
    } else {
      _sendMessage("mute");
      // Don't necessarily force play/pause here, depends on UX.
      // But typically if we obscure it, we mute.
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
    return WebViewWidget(controller: _controller);
  }
}
