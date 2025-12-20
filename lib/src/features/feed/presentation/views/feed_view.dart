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

  void _updateTitle(String title) {
    setState(() {
      _panelTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION 1: Only watch the loading/error state for the root scaffold
    final isLoading = ref.watch(videoFeedProvider.select((s) => s.isLoading));
    final error = ref.watch(videoFeedProvider.select((s) => s.error));

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrand),
        ),
      );
    }

    if (error != null) {
      return _buildErrorView(error);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // OPTIMIZATION 2: Extract PageView to a separate widget
          // so it handles its own index watching without rebuilding the panel/tabs
          _VideoPageFeed(
            pageController: _pageController,
            isPanelOpen: _isPanelOpen,
            onOpenPanel: _openPanel,
            onUpdateTitle: _updateTitle,
          ),

          // Top Tabs
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: const _TopTabs(),
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

  Widget _buildErrorView(String error) {
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
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
}

class _VideoPageFeed extends ConsumerWidget {
  final PageController pageController;
  final bool isPanelOpen;
  final Function(String, Widget) onOpenPanel;
  final Function(String) onUpdateTitle;

  const _VideoPageFeed({
    required this.pageController,
    required this.isPanelOpen,
    required this.onOpenPanel,
    required this.onUpdateTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION 3: Select specifically what we need.
    final videos = ref.watch(videoFeedProvider.select((s) => s.videos));
    final currentIndex = ref.watch(
      videoFeedProvider.select((s) => s.currentIndex),
    );

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      // Use allowImplicitScrolling to keep previous/next video ready in memory
      allowImplicitScrolling: true,
      onPageChanged: (index) {
        ref.read(videoFeedProvider.notifier).onPageChanged(index);
      },
      itemBuilder: (context, index) {
        return VideoPost(
          video: videos[index],
          isPlaying: index == currentIndex && !isPanelOpen,
          hideContent: isPanelOpen,
          onStartQuiz: () => onOpenPanel(
            "Loading...",
            QuizPanel(
              videoId: videos[index].id,
              audioUrl: videos[index].audioUrl,
              onTitleChanged: onUpdateTitle,
            ),
          ),
          onShowComments: () =>
              onOpenPanel("Comments 💬", const CommentsPanel()),
          onShowPanel: onOpenPanel,
        );
      },
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabItem("Learn", false),
        const SizedBox(width: 20),
        Container(width: 1, height: 16, color: Colors.white24),
        const SizedBox(width: 20),
        _buildTabItem("Feed", true),
      ],
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
          Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
