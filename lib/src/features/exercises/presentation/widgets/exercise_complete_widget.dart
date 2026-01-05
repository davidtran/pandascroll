import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/exp_badge.dart';
import 'package:pandascroll/src/features/feed/presentation/providers/paw_provider.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';

class ExerciseCompleteWidget extends ConsumerStatefulWidget {
  final VoidCallback onSemesterExercises;
  final VoidCallback onNextVideo;
  final int correctCount;
  final String videoId;

  const ExerciseCompleteWidget({
    super.key,
    required this.onSemesterExercises,
    required this.onNextVideo,
    required this.correctCount,
    required this.videoId,
  });

  @override
  ConsumerState<ExerciseCompleteWidget> createState() =>
      _ExerciseCompleteWidgetState();
}

class _ExerciseCompleteWidgetState extends ConsumerState<ExerciseCompleteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  final GlobalKey pandaIconKey = GlobalKey();
  List<OverlayEntry> _flyingEntries = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: -10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      _handleClaim();
    });
  }

  void _handleClaim() {
    // 1. XP / Panda Animation
    final pandaTargetKey = ref.read(pandaIconKeyProvider);
    final RenderBox? pandaTargetBox =
        pandaTargetKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? pandaStartBox =
        pandaIconKey.currentContext?.findRenderObject() as RenderBox?;

    int animationsToComplete = 0;
    int completedAnimations = 0;

    // Check availability of animation targets
    if (pandaTargetBox != null && pandaStartBox != null) {
      animationsToComplete += widget.correctCount;
    }

    void checkCompletion() {
      completedAnimations++;
      if (completedAnimations >= animationsToComplete) {
        // All visual animations done.
        // Trigger Backend updates
        if (widget.correctCount > 0) {
          ref
              .read(userLanguageProfileProvider.notifier)
              .addXp(
                event: 'complete_exercise',
                value: widget.correctCount.toDouble(),
                videoId: widget.videoId,
              );
        }
      }
    }

    // Start Panda Animations
    if (pandaTargetBox != null && pandaStartBox != null) {
      final startPos = pandaStartBox.localToGlobal(Offset.zero);
      final targetPos = pandaTargetBox.localToGlobal(Offset.zero);

      for (int i = 0; i < widget.correctCount; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (!mounted) return;
          _spawnFlyingItem(
            startPos,
            targetPos,
            'assets/images/panda.png',
            onComplete: checkCompletion,
          );
        });
      }
    }
  }

  void _spawnFlyingItem(
    Offset startPos,
    Offset targetPos,
    String assetPath, {
    required VoidCallback onComplete,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingItemAnimation(
        startPos: startPos,
        targetPos: targetPos,
        assetPath: assetPath,
        onComplete: () {
          entry.remove();
          _flyingEntries.remove(entry);
          onComplete();
        },
      ),
    );

    Overlay.of(context).insert(entry);
    _flyingEntries.add(entry);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // Background Elements
          Positioned.fill(child: _buildBackgroundDecorations()),

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildPandaDisplay(),
                const SizedBox(height: 24),
                _buildScoreDisplay(),
                const Spacer(),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    // Static decorations for now, or simple animations
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: '100%'.hashCode % 100.0, // rough
          child: const Text(
            '✨',
            style: TextStyle(fontSize: 32, color: AppColors.accentYellow),
          ),
        ),
        // Add more if needed matching HTML roughly
      ],
    );
  }

  Widget _buildPandaDisplay() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.bambooLight.withOpacity(0.6),
                shape: BoxShape.circle,
                // blur radius simulated via shadow or just generic container
              ),
            ),
            // Main Circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.pandaBlack, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.pandaBlack,
                    offset: Offset(4, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text("🐼", style: TextStyle(fontSize: 100)),
              ),
            ),
            // Tag
            Positioned(
              top: -8,
              right: -8,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.pandaBlack, width: 3),
                  ),
                  child: const Center(
                    child: Text("🎉", style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreDisplay() {
    return Column(
      children: [
        Transform.rotate(
          angle: -0.02,
          child: const Text(
            "Exercise Complete!",
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.pandaBlack,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Paw Score Badge
        ExpBadge(pandaKey: pandaIconKey),

        const SizedBox(height: 12),
        const Text(
          "Great job! You are getting better every day.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildCustomButton(
          label: "Sentence Exercises",
          subLabel: "Continue practicing",
          icon: Icons.edit_note, // stylus_note replacement
          iconColor: AppColors.bambooDark,
          bgColor: AppColors.bambooGreen,
          endIcon: Icons.arrow_forward,
          onPressed: widget.onSemesterExercises,
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        _buildCustomButton(
          label: "Next Video",
          subLabel: "Watch more content",
          icon: Icons.play_circle,
          iconColor: Colors.white,
          bgColor: Colors.white,
          iconBg: AppColors.levelBlueLight,
          endIcon: Icons.skip_next,
          onPressed: widget.onNextVideo,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildCustomButton({
    required String label,
    required String subLabel,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    Color? iconBg,
    required IconData endIcon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pandaBlack, width: 3),
          boxShadow: [
            if (isPrimary)
              const BoxShadow(
                color: AppColors.pandaBlack,
                offset: Offset(4, 6),
                blurRadius: 0,
              )
            else
              const BoxShadow(
                color: AppColors.pandaBlack,
                offset: Offset(4, 6),
                blurRadius: 0,
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.pandaBlack, width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.pandaBlack, width: 2),
              ),
              child: Icon(endIcon, size: 18, color: AppColors.pandaBlack),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _FlyingItemAnimation extends StatefulWidget {
  final Offset startPos;
  final Offset targetPos;
  final String assetPath;
  final VoidCallback onComplete;

  const _FlyingItemAnimation({
    required this.startPos,
    required this.targetPos,
    required this.assetPath,
    required this.onComplete,
  });

  @override
  State<_FlyingItemAnimation> createState() => _FlyingItemAnimationState();
}

class _FlyingItemAnimationState extends State<_FlyingItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late double _randomOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Randomize path slightly for effect
    _randomOffset = (Random().nextDouble() - 0.5) * 100;

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Scale down as it flies away
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentX =
            widget.startPos.dx +
            (widget.targetPos.dx - widget.startPos.dx) * _animation.value +
            (_randomOffset * sin(_animation.value * pi)); // Arc effect

        final currentY =
            widget.startPos.dy +
            (widget.targetPos.dy - widget.startPos.dy) * _animation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Image.asset(widget.assetPath, width: 40, height: 40),
          ),
        );
      },
    );
  }
}
