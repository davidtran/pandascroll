import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../controllers/video_controller.dart';
import '../controllers/daily_goal_controller.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
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
                  // Daily Goal (Left)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PointerInterceptor(child: _buildDailyGoalBadge()),
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
            child: PointerInterceptor(
              child: InteractionPanel(
                title: _panelTitle,
                onClose: _closePanel,
                child: _panelContent,
              ),
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
    final dailyGoal = ref.watch(dailyGoalProvider);
    final goalKey = ref.watch(dailyGoalKeyProvider);

    return Container(
      key: goalKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/paw.png', width: 24, height: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Daily Goal",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    "${dailyGoal.currentProgress}/${dailyGoal.target}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: _StripeProgressBar(
                      progress: (dailyGoal.currentProgress / dailyGoal.target)
                          .clamp(0.0, 1.0),
                    ),
                  ),
                ],
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
              onClose: () => onClosePanel(),
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
          ),
          onShowComments: () =>
              onOpenPanel("Comments 💬", const CommentsPanel()),
          onShowPanel: onOpenPanel,
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

class _StripeProgressBar extends StatefulWidget {
  final double progress;

  const _StripeProgressBar({required this.progress});

  @override
  State<_StripeProgressBar> createState() => _StripeProgressBarState();
}

class _StripeProgressBarState extends State<_StripeProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _stripeController;

  @override
  void initState() {
    super.initState();
    _stripeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _stripeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Progress Fill
        return Container(
          height: 8, // Match height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), // Match previous
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: widget.progress,
                  child: Container(color: AppColors.primaryBrand),
                ),

                // 2. Animated Stripes
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _stripeController,
                    builder: (context, child) {
                      return ClipRect(
                        child: FractionallySizedBox(
                          widthFactor: widget.progress,
                          child: CustomPaint(
                            painter: _FixedStripePainter(
                              offset: _stripeController.value * 20.0,
                              stripeWidth: 8.0,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FixedStripePainter extends CustomPainter {
  final double offset;
  final double stripeWidth;
  final Color color;

  _FixedStripePainter({
    required this.offset,
    required this.stripeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // period
    final double period = stripeWidth * 2;

    final path = Path();

    // Coverage
    // We want stripes ///
    // from left to right.

    int count = (size.width / stripeWidth).ceil() * 2 + 5;

    for (int i = -5; i < count; i++) {
      double startX =
          i * period +
          (offset % period) -
          period; // Shift left by period to cover entrance?

      // Draw parallelogram leaning ///
      // Bottom-left: (startX, h)
      // Bottom-right: (startX + w, h)
      // Top-right: (startX + w + h, 0) -> lean right involves adding h to x at top
      // Top-left: (startX + h, 0)

      path.moveTo(startX, size.height);
      path.lineTo(startX + stripeWidth, size.height);
      path.lineTo(startX + stripeWidth + size.height, 0);
      path.lineTo(startX + size.height, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FixedStripePainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.color != color;
  }
}
