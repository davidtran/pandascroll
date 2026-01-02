import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/theme/app_dimens.dart';
import 'package:pandascroll/src/features/feed/domain/models/exercise_model.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import '../../../../profile/presentation/providers/profile_providers.dart';
import '../../providers/paw_provider.dart';

class QuizCompletionScreen extends ConsumerStatefulWidget {
  final List<ExerciseModel> exercises;
  final int correctCount;
  final VoidCallback onContinue;
  final VoidCallback onClaim;
  final String videoId;

  const QuizCompletionScreen({
    super.key,
    required this.exercises,
    required this.correctCount,
    required this.onContinue,
    required this.onClaim,
    required this.videoId,
  });

  @override
  ConsumerState<QuizCompletionScreen> createState() =>
      _QuizCompletionScreenState();
}

class _QuizCompletionScreenState extends ConsumerState<QuizCompletionScreen> {
  final GlobalKey _pawIconKey = GlobalKey();
  final GlobalKey _pandaIconKey = GlobalKey();
  List<OverlayEntry> _flyingEntries = [];

  void _handleClaim() {
    // 1. XP / Panda Animation
    final pandaTargetKey = ref.read(pandaIconKeyProvider);
    final RenderBox? pandaTargetBox =
        pandaTargetKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? pandaStartBox =
        _pandaIconKey.currentContext?.findRenderObject() as RenderBox?;

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

        widget.onClaim();
      }
    }

    // If no animations possible (e.g. 0 score and no refund, or layout missing), just finish
    if (animationsToComplete == 0) {
      widget.onClaim();
      return;
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
    for (var entry in _flyingEntries) {
      entry.remove();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.exercises.isNotEmpty
        ? (widget.correctCount / widget.exercises.length * 100).round()
        : 0;

    final bool isSuccess =
        widget.exercises.isNotEmpty &&
        (widget.correctCount / widget.exercises.length) > 0.5;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            isSuccess ? "Awesome! 🎉" : "Good Try!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "You answered ${widget.correctCount}/${widget.exercises.length} correctly ($percentage%).",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          if (isSuccess) ...[
            const SizedBox(height: AppSpacing.xl),
            const Text(
              "Total Reward",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.pandaBlack,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Panda XP Reward
                if (widget.correctCount > 0) ...[
                  Image.asset(
                    'assets/images/panda.png',
                    width: 40,
                    height: 40,
                    key: _pandaIconKey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "x ${widget.correctCount}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PandaButton(width: 200, onPressed: _handleClaim, text: "Claim"),
          ] else ...[
            const SizedBox(height: AppSpacing.xl),
            PandaButton(
              width: 200,
              onPressed: widget.onContinue,
              text: "Continue",
            ),
          ],
        ],
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
