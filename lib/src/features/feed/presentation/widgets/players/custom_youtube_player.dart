import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class CustomYouTubePlayerMobile extends ConsumerStatefulWidget {
  final String videoId;
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange;
  final VoidCallback onEnded;
  final Stream<double>? seekStream;
  final Function(String error)? onError;
  final double? startSeconds;
  final double? endSeconds;

  const CustomYouTubePlayerMobile({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
    this.onError,
    this.seekStream,
    this.startSeconds,
    this.endSeconds,
  });

  @override
  ConsumerState<CustomYouTubePlayerMobile> createState() =>
      _CustomYouTubePlayerMobileState();
}

class _CustomYouTubePlayerMobileState
    extends ConsumerState<CustomYouTubePlayerMobile> {
  InAppWebViewController? _webViewController;
  bool _isPlayerReady = false;
  // Use a local variable to control visual visibility, but override with provider loading
  bool _isThumbnailVisible = true;
  StreamSubscription? _seekSubscription;

  @override
  void initState() {
    super.initState();
    _seekSubscription = widget.seekStream?.listen((seconds) {
      if (_isPlayerReady && mounted) {
        _seekTo(seconds);
      }
    });
  }

  void _seekTo(double seconds) async {
    if (_webViewController != null) {
      _webViewController?.evaluateJavascript(source: "seekTo($seconds, true)");
    }
  }

  @override
  void didUpdateWidget(CustomYouTubePlayerMobile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.seekStream != oldWidget.seekStream) {
      _seekSubscription?.cancel();
      _seekSubscription = widget.seekStream?.listen((seconds) {
        if (_isPlayerReady && mounted) {
          _seekTo(seconds);
        }
      });
    }

    if (widget.videoId != oldWidget.videoId) {
      _loadVideo(widget.videoId);
      _isThumbnailVisible = true; // Reset thumbnail on video change
    }

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _play();
      } else {
        _pause();
      }
    }

    // Check for start time change (e.g. window switch)
    if (widget.startSeconds != oldWidget.startSeconds &&
        widget.startSeconds != null) {
      if (_isPlayerReady) {
        _seekTo(widget.startSeconds!);
      }
    }
  }

  void _loadVideo(String videoId) {
    _webViewController?.evaluateJavascript(source: "loadById('$videoId')");
  }

  void _play() {
    _webViewController?.evaluateJavascript(source: "play()");
  }

  void _pause() {
    _webViewController?.evaluateJavascript(source: "pause()");
  }

  @override
  void dispose() {
    _seekSubscription?.cancel();
    super.dispose();
  }

  String boolean({required bool value}) => value == true ? "'1'" : "'0'";

  String get userAgent => '';

  String get _playerHtml =>
      '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            html,
            body {
                margin: 0;
                padding: 0;
                background-color: #000000;
                overflow: hidden;
                position: fixed;
                height: 100%;
                width: 100%;
                pointer-events: none;
            }
        </style>
        <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
    </head>
    <body>
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            var player;
            var timerId;
            var isWeb = ${kIsWeb};

            function onYouTubeIframeAPIReady() {
                if (isWeb) {
                     initPlayer();
                } else {
                    if (window.flutter_inappwebview) {
                        initPlayer();
                    } else {
                        window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
                            initPlayer();
                        });
                    }
                }
            }

            function initPlayer() {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '${widget.videoId}',
                    playerVars: {
                        'controls': 0,
                        'playsinline': 1,
                        'enablejsapi': 1,
                        'fs': 0,
                        'rel': 0,
                        'showinfo': 0,
                        'iv_load_policy': 3,
                        'modestbranding': 1,
                        'cc_lang_pref': 'en',
                        'loop': 1,
                        'autoplay': ${boolean(value: widget.isPlaying)},
                        'start': ${widget.startSeconds?.toInt() ?? 1}
                    },
                    events: {
                        onReady: function(event) { sendMessageToDart('Ready'); },
                        onStateChange: function(event) { sendPlayerStateChange(event.data); },
                        onPlaybackQualityChange: function(event) { sendMessageToDart('PlaybackQualityChange', event.data); },
                        onPlaybackRateChange: function(event) { sendMessageToDart('PlaybackRateChange', event.data); },
                        onError: function(error) { sendMessageToDart('Errors', error.data); }
                    },
                });
            }

            function sendMessageToDart(handlerName, ...args) {
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler(handlerName, ...args);
                } else {
                    // Fallback for Web/Missing Bridge
                    console.log(JSON.stringify({
                        'handler': handlerName,
                        'args': args
                    }));
                }
            }

            function sendPlayerStateChange(playerState) {
                clearTimeout(timerId);
                sendMessageToDart('StateChange', playerState);
                if (playerState == 1) {
                    startSendCurrentTimeInterval();
                    sendVideoData(player);
                }
            }

            function sendVideoData(player) {
                var videoData = {
                    'duration': player.getDuration(),
                    'title': player.getVideoData().title,
                    'author': player.getVideoData().author,
                    'videoId': player.getVideoData().video_id
                };
                sendMessageToDart('VideoData', videoData);
            }

            function startSendCurrentTimeInterval() {
                timerId = setInterval(function () {
                     sendMessageToDart('VideoTime', player.getCurrentTime(), player.getVideoLoadedFraction());
                }, 100);
            }

            function play() {
                if (player && typeof player.playVideo === 'function') {
                    player.playVideo();
                }
                return '';
            }

            function pause() {
                if (player && typeof player.pauseVideo === 'function') {
                    player.pauseVideo();
                }
                return '';
            }

            function loadById(videoId) {
                if (player && typeof player.loadVideoById === 'function') {
                    player.loadVideoById({videoId, startSeconds: ${widget.startSeconds?.toDouble() ?? 1}, endSeconds: ${widget.endSeconds?.toDouble() ?? 1}});
                }
                return '';
            }

            function seekTo(position, seekAhead) {
                if (player && typeof player.seekTo === 'function') {
                    player.seekTo(position, seekAhead);
                }
                return '';
            }

            function setSize(width, height) {
                if (player && typeof player.setSize === 'function') {
                    player.setSize(width, height);
                }
                return '';
            }
        </script>
    </body>
    </html>
  ''';

  void _handleJsMessage(String handlerName, List<dynamic> args) {
    if (!mounted) return;

    switch (handlerName) {
      case 'Ready':
        setState(() {
          _isPlayerReady = true;
        });
        // Only play if ready
        if (widget.isPlaying) {
          _play();
        } else {
          _pause();
        }
        break;
      case 'StateChange':
        if (args.isEmpty) return;
        final state = args.first as int;
        switch (state) {
          case 0:
            widget.onEnded();
            // Only loop if ready
            _play();
            break;
          case 1:
            widget.onStateChange(true);
            // Start playing
            // Hide thumbnail on first play
            if (mounted) {
              // Only remove thumbnail if not forced loading
              setState(() {
                _isThumbnailVisible = false;
              });
            }
            break;
          case 2:
            widget.onStateChange(false);
            break;
        }
        break;
      case 'VideoTime':
        if (args.isEmpty) return;
        final position = args.first;
        if (position is num) {
          widget.onCurrentTime(position.toDouble());
        }
        break;
      case 'Errors':
        if (args.isEmpty) return;
        print('on error ${args.first}');
        widget.onError?.call(args.first.toString());
        break;

      // Helpers mostly for debug/other data
      case 'VideoData':
        // Handle metadata if needed
        break;
      case 'PlaybackQualityChange':
      case 'PlaybackRateChange':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialData: InAppWebViewInitialData(
            data: _playerHtml,
            encoding: 'utf-8',
            baseUrl: WebUri.uri(Uri.https('youtube-nocookie.com')),
            mimeType: 'text/html',
          ),
          initialSettings: InAppWebViewSettings(
            userAgent: userAgent,
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: false,
            disableContextMenu: true,
            supportZoom: false,
            disableHorizontalScroll: false,
            disableVerticalScroll: false,
            allowsInlineMediaPlayback: true,
            allowsAirPlayForMediaPlayback: true,
            allowsPictureInPictureMediaPlayback: true,
            useWideViewPort: false,
            useHybridComposition: true,
          ),
          onConsoleMessage: (controller, consoleMessage) {
            // Handle Web fallback or generic debug
            if (kIsWeb) {
              try {
                final message = consoleMessage.message;
                // Simple check to ensure it looks like JSON we sent
                if (message.startsWith('{') && message.contains('"handler"')) {
                  final data = jsonDecode(message);
                  if (data is Map && data.containsKey('handler')) {
                    final handler = data['handler'] as String;
                    final args = (data['args'] as List?) ?? [];
                    _handleJsMessage(handler, args);
                  }
                }
              } catch (e) {
                // Not our JSON message
              }
            }
          },
          onWebViewCreated: (webController) {
            _webViewController = webController;

            // Only add JS Handlers on Mobile
            if (!kIsWeb) {
              webController
                ..addJavaScriptHandler(
                  handlerName: 'Ready',
                  callback: (_) => _handleJsMessage('Ready', []),
                )
                ..addJavaScriptHandler(
                  handlerName: 'StateChange',
                  callback: (args) => _handleJsMessage('StateChange', args),
                )
                ..addJavaScriptHandler(
                  handlerName: 'VideoTime',
                  callback: (args) => _handleJsMessage('VideoTime', args),
                )
                ..addJavaScriptHandler(
                  handlerName: 'Errors',
                  callback: (args) => _handleJsMessage('Errors', args),
                )
                ..addJavaScriptHandler(
                  handlerName: 'VideoData',
                  callback: (args) => _handleJsMessage('VideoData', args),
                )
                ..addJavaScriptHandler(
                  handlerName: 'PlaybackQualityChange',
                  callback: (args) =>
                      _handleJsMessage('PlaybackQualityChange', args),
                )
                ..addJavaScriptHandler(
                  handlerName: 'PlaybackRateChange',
                  callback: (args) =>
                      _handleJsMessage('PlaybackRateChange', args),
                );
            }
          },
        ),
        // Cover loading states (either player init OR translation loading)
        if (_isThumbnailVisible)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // If thumbnail is still valid (player not started), show it. Use black if not.
                Image.network(
                  'https://img.youtube.com/vi/${widget.videoId}/sddefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.black),
                ),
                // Loader
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBrand,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
