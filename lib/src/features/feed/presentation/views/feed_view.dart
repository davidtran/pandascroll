import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/video_controller.dart';
import '../widgets/interaction_panel.dart';
import '../widgets/video_post.dart';
import '../widgets/quiz_panel.dart';
import '../widgets/comments_panel.dart';
import 'package:pandascroll/src/features/roadmap/presentation/views/roadmap_view.dart';

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
  String _currentTab = "Feed";

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
          _currentTab == "Feed"
              ? _VideoPageFeed(
                  pageController: _pageController,
                  isPanelOpen: _isPanelOpen,
                  onOpenPanel: _openPanel,
                  onUpdateTitle: _updateTitle,
                )
              : const RoadmapView(),

          // Top Tabs
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: SafeArea(
              child: Stack(
                alignment: Alignment.topCenter,

                children: [
                  // Daily Goal (Left)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildDailyGoalBadge(),
                  ),
                ],
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

  Widget _buildDailyGoalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.pandaBlack, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.spa, color: AppColors.pandaBlack, size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Text + Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "DAILY PANDA GOAL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "3 / 5",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Progress Bar
              Container(
                width: 120, // Fixed width for badge consistency
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Stack(
                  children: [
                    // Fill
                    FractionallySizedBox(
                      widthFactor: 0.6, // 3/5
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} // End class

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
  final String selectedTab;
  final Function(String) onTabSelected;

  const _TopTabs({required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onTabSelected("Roadmap"),
          child: _buildTabItem("Roadmap", selectedTab == "Roadmap"),
        ),
        const SizedBox(width: 20),
        Container(width: 1, height: 16, color: Colors.white24),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => onTabSelected("Feed"),
          child: _buildTabItem("Feed", selectedTab == "Feed"),
        ),
      ],
    );
  }

  Widget _buildTabItem(String text, bool isSelected) {
    if (text == "Feed") text = "For You"; // Rename for display
    if (text == "Roadmap") text = "Following";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: isSelected ? 20 : 18,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 1)),
            ],
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
