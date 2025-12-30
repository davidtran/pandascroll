import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomYouTubePlayerMobile extends StatefulWidget {
  final String videoId;
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange;
  final VoidCallback onEnded;
  final Stream<int>? seekStream;
  final Function(String error)? onError;

  const CustomYouTubePlayerMobile({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
    this.onError,
    this.seekStream,
  });

  @override
  State<CustomYouTubePlayerMobile> createState() =>
      _CustomYouTubePlayerMobileState();
}

class _CustomYouTubePlayerMobileState extends State<CustomYouTubePlayerMobile> {
  InAppWebViewController? _webViewController;
  bool _isPlayerReady = false;
  bool _isThumbnailVisible = true;
  StreamSubscription? _seekSubscription;

  @override
  void initState() {
    super.initState();
    _seekSubscription = widget.seekStream?.listen((seconds) {
      if (_isPlayerReady && mounted) {
        _seekRelative(seconds);
      }
    });
  }

  void _seekRelative(int seconds) async {
    if (_webViewController != null) {
      final currentTime = await _webViewController?.evaluateJavascript(
        source: "player.getCurrentTime()",
      );
      if (currentTime != null) {
        final double current = (currentTime is int)
            ? currentTime.toDouble()
            : currentTime;
        final newPos = current + seconds;
        _webViewController?.evaluateJavascript(source: "seekTo($newPos, true)");
      }
    }
  }

  @override
  void didUpdateWidget(CustomYouTubePlayerMobile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoId != oldWidget.videoId) {
      _loadVideo(widget.videoId);
    }

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _play();
      } else {
        _pause();
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
            function onYouTubeIframeAPIReady() {
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
                        'cc_load_policy': 0,
                        'cc_lang_pref': 'en',
                        'autoplay': ${boolean(value: widget.isPlaying)},
                        'start': 1
                    },
                    events: {
                        onReady: function(event) { window.flutter_inappwebview.callHandler('Ready'); },
                        onStateChange: function(event) { sendPlayerStateChange(event.data); },
                        onPlaybackQualityChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackQualityChange', event.data); },
                        onPlaybackRateChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackRateChange', event.data); },
                        onError: function(error) { window.flutter_inappwebview.callHandler('Errors', error.data); }
                    },
                });
            }

            function sendPlayerStateChange(playerState) {
                clearTimeout(timerId);
                window.flutter_inappwebview.callHandler('StateChange', playerState);
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
                window.flutter_inappwebview.callHandler('VideoData', videoData);
            }

            function startSendCurrentTimeInterval() {
                timerId = setInterval(function () {
                    window.flutter_inappwebview.callHandler('VideoTime', player.getCurrentTime(), player.getVideoLoadedFraction());
                }, 100);
            }

            function play() {
                player.playVideo();
                return '';
            }

            function pause() {
                player.pauseVideo();
                return '';
            }

            function loadById(videoId) {
                player.loadVideoById(videoId);
                return '';
            }

            function seekTo(position, seekAhead) {
                player.seekTo(position, seekAhead);
                return '';
            }

            function setSize(width, height) {
                player.setSize(width, height);
                return '';
            }
        </script>
    </body>
    </html>
  ''';

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
          onWebViewCreated: (webController) {
            _webViewController = webController;
            webController
              ..addJavaScriptHandler(
                handlerName: 'Ready',
                callback: (_) {
                  if (mounted) {
                    setState(() {
                      _isPlayerReady = true;
                    });
                  }
                  if (widget.isPlaying) {
                    _play();
                  }
                },
              )
              ..addJavaScriptHandler(
                handlerName: 'StateChange',
                callback: (args) {
                  final state = args.first as int;
                  switch (state) {
                    case 0:
                      widget.onEnded();
                      _play(); // Loop forever
                      break;
                    case 1:
                      widget.onStateChange(true);
                      if (mounted) {
                        setState(() {
                          _isThumbnailVisible = false;
                        });
                      }
                      break;
                    case 2:
                      widget.onStateChange(false);
                      break;
                  }
                },
              )
              ..addJavaScriptHandler(
                handlerName: 'VideoTime',
                callback: (args) {
                  final position = args.first;
                  if (position is num) {
                    widget.onCurrentTime(position.toDouble());
                  }
                },
              )
              ..addJavaScriptHandler(
                handlerName: 'Errors',
                callback: (args) {
                  print('on error ${args.first}');
                  widget.onError?.call(args.first.toString());
                },
              );
          },
        ),
        if (_isThumbnailVisible)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://img.youtube.com/vi/${widget.videoId}/sddefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.black),
                ),
                ColoredBox(color: Colors.black.withOpacity(0.3)),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
      ],
    );
  }
}
