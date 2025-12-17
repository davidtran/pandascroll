import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/video_controller.dart';
import '../widgets/interaction_panel.dart';
import '../widgets/video_post.dart';
import '../widgets/quiz_panel.dart';
import '../widgets/comments_panel.dart';

class FeedView extends ConsumerStatefulWidget {
  const FeedView({super.key});

  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView> {
  final PageController _pageController = PageController();
  bool _isPanelOpen = false;
  Widget _panelContent = const SizedBox();
  String _panelTitle = "";

  void _openPanel(String title, Widget content) {
    setState(() {
      _panelTitle = title;
      _panelContent = content;
      _isPanelOpen = true;
    });
  }

  void _closePanel() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isPanelOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoFeedProvider);
    final videos = videoState.videos;
    final currentIndex = videoState.currentIndex;

    if (videoState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrand),
        ),
      );
    }

    if (videoState.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  videoState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(videoFeedProvider.notifier).fetchVideos();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background (for when video shrinks)
          Container(color: Colors.black),

          // Video Layer (Animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: -20, // Move down slightly or keep at top
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: GestureDetector(
              onTap: _closePanel,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  onPageChanged: (index) {
                    ref.read(videoFeedProvider.notifier).onPageChanged(index);
                  },
                  itemBuilder: (context, index) {
                    return VideoPost(
                      video: videos[index],
                      isPlaying: index == currentIndex && !_isPanelOpen,
                      hideContent: _isPanelOpen,
                      onStartQuiz: () =>
                          _openPanel("Quiz Time! 🎮", const QuizPanel()),
                      onShowComments: () =>
                          _openPanel("Comments 💬", const CommentsPanel()),
                    );
                  },
                ),
              ),
            ),
          ),

          // Top Bar (Overlay)
          if (!_isPanelOpen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        "For You",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Interaction Panel (Animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isPanelOpen
                ? 0
                : -MediaQuery.of(context).size.height * 0.65,
            height: MediaQuery.of(context).size.height * 0.65,
            child: InteractionPanel(
              title: _panelTitle,
              onClose: _closePanel,
              child: _panelContent,
            ),
          ),
        ],
      ),
    );
  }
}
