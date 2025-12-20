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
          // Video PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            onPageChanged: ref.read(videoFeedProvider.notifier).onPageChanged,
            itemBuilder: (context, index) {
              return VideoPost(
                video: videos[index],
                isPlaying: index == currentIndex && !_isPanelOpen,
                hideContent: _isPanelOpen,
                onStartQuiz: () => _openPanel(
                      "Quiz Time! 🎮",
                      QuizPanel(
                        videoId: videos[index].id,
                        audioUrl: videos[index].audioUrl,
                      ),
                    ),
                onShowComments: () =>
                    _openPanel("Comments 💬", const CommentsPanel()),
                onShowPanel: (title, content) => _openPanel(title, content),
              );
            },
          ),

          // Top Tabs (Learn | Feed)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabItem("Learn", false),
                const SizedBox(width: 20),
                Container(width: 1, height: 16, color: Colors.white24),
                const SizedBox(width: 20),
                _buildTabItem("Feed", true),
              ],
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
                : -MediaQuery.of(context).size.height * 0.75,
            height: MediaQuery.of(context).size.height * 0.75,
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

  Widget _buildTabItem(String text, bool isSelected) {
    return Text(
      text,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.white60,
        fontSize: 18,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        shadows: const [
          Shadow(
            blurRadius: 4,
            color: Colors.black26,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
