import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../controllers/video_controller.dart';
import '../../data/video_status_repository.dart';

import '../widgets/daily_goal/language_level_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../widgets/interaction_panel.dart';
import '../widgets/video_post.dart';
import '../widgets/quiz_panel.dart';
import '../widgets/comments_panel.dart';
import 'package:pandascroll/src/features/roadmap/presentation/views/roadmap_view.dart';
import '../../../home/presentation/providers/main_navigation_provider.dart';

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
  bool _barrierDismissible = true;
  String _currentTab = "Feed";

  void _openPanel(String title, Widget content, {bool? barrierDismissible}) {
    setState(() {
      _panelTitle = title;
      _panelContent = content;
      _isPanelOpen = true;
      _barrierDismissible = barrierDismissible ?? true;
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
                  onClosePanel: _closePanel,
                )
              : const RoadmapView(),

          // Top Tabs
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Stack(
                alignment: Alignment.topCenter,

                children: [
                  // Language Level (Left)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LanguageLevelWidget(),
                  ),
                ],
              ),
            ),
          ),

          // Interaction Panel (Self-contained)
          Positioned.fill(
            child: InteractionPanel(
              title: _panelTitle,
              onClose: _closePanel,
              isVisible: _isPanelOpen,
              barrierDismissible: _barrierDismissible,
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
} // End class

class _VideoPageFeed extends ConsumerWidget {
  final PageController pageController;
  final bool isPanelOpen;
  final Function(String, Widget, {bool? barrierDismissible}) onOpenPanel;
  final Function(String) onUpdateTitle;
  final Function() onClosePanel;

  const _VideoPageFeed({
    required this.pageController,
    required this.isPanelOpen,
    required this.onOpenPanel,
    required this.onUpdateTitle,
    required this.onClosePanel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION 3: Select specifically what we need.
    final allVideos = ref.watch(videoFeedProvider.select((s) => s.videos));
    final blockedVideos = ref.watch(blockedVideosProvider);
    final videos = allVideos
        .where((v) => !blockedVideos.contains(v.id))
        .toList();
    final currentIndex = ref.watch(
      videoFeedProvider.select((s) => s.currentIndex),
    );
    final mainNavIndex = ref.watch(mainNavigationIndexProvider);
    final isFeedTabActive = mainNavIndex == 0;

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
          isPlaying: index == currentIndex && !isPanelOpen && isFeedTabActive,
          hideContent: isPanelOpen,
          onStartQuiz: () => onOpenPanel(
            "Loading...",
            QuizPanel(
              videoId: videos[index].id,
              audioUrl: videos[index].audioUrl,
              onTitleChanged: onUpdateTitle,
              onClose: () => onClosePanel(),
              language: videos[index].language,
              onNextVideo: () {
                onClosePanel();
                if (index < videos.length - 1) {
                  pageController.animateToPage(
                    index + 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            barrierDismissible: false,
          ),
          onShowComments: () => onOpenPanel(
            "Comments 💬",
            CommentsPanel(videoId: videos[index].id),
          ),
          onShowPanel: (title, widget) => onOpenPanel(title, widget),
          onSkip: () {
            if (index < videos.length - 1) {
              pageController.animateToPage(
                index + 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        );
      },
    );
  }
}
