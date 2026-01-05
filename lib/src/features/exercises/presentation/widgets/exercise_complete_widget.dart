import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/exp_badge.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';

class ExerciseCompleteWidget extends ConsumerStatefulWidget {
  final VoidCallback onSemesterExercises;
  final VoidCallback onNextVideo;
  final int correctCount;
  final String videoId;
  final List<String> learnedItems;

  const ExerciseCompleteWidget({
    super.key,
    required this.onSemesterExercises,
    required this.onNextVideo,
    required this.correctCount,
    required this.videoId,
    required this.learnedItems,
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
  final GlobalKey _avatarKey = GlobalKey();
  List<OverlayEntry> _flyingEntries = [];
  bool _xpAwarded = false;

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
      _startAnimation();
    });
  }

  void _startAnimation({bool awardXp = true}) {
    // 1. XP / Panda Animation
    final RenderBox? pandaStartBox =
        _avatarKey.currentContext?.findRenderObject() as RenderBox?;

    // We use the center of the screen/avatar as start for "learned items" if we want them to fly OUT?
    // Or fly IN to the avatar? The request says "fly into the center of avatar".
    // So target is Avatar. Start is random.

    // Let's assume start box is the screen edges or random, and target is pandaIconKey (which is the avatar now).

    int animationsToComplete = 0;
    int completedAnimations = 0;

    // We animate learned items + maybe some stars/confetti for correct count if desired.
    // Let's focus on learned items flying IN to the avatar.
    animationsToComplete = widget.learnedItems.length;

    // Check availability of animation targets
    if (pandaStartBox != null) {
      // Correct Count logic for XP is separate, handled by checkCompletion trigger maybe?
      // Or we just add XP immediately and visual is just for fun.
    }

    void checkCompletion() {
      completedAnimations++;
      if (completedAnimations >= animationsToComplete) {
        // All visual animations done.
        // Trigger Backend updates
        if (awardXp && !_xpAwarded && widget.correctCount > 0) {
          _xpAwarded = true;
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

    // Start Flying Items Animation
    // Target is the Avatar (pandaIconKey)
    if (pandaStartBox != null) {
      final targetPos = pandaStartBox.localToGlobal(
        Offset(pandaStartBox.size.width / 2, pandaStartBox.size.height / 2),
      );

      final screenSize = MediaQuery.of(context).size;
      final random = Random();

      for (int i = 0; i < widget.learnedItems.length; i++) {
        // "start from left 0 to right 0 of the container"
        // We'll spawn them at random X across the screen width.
        // And random Y around the avatar (e.g. +/- 100).

        final startX = random.nextDouble() * screenSize.width;
        // Keep Y somewhat near the avatar so it's not too far
        final startY = targetPos.dy + (random.nextDouble() - 0.5) * 200;

        final startPos = Offset(startX, startY);

        // All spawn immediately but have slight delay in appearing?
        // User said "wait for 2 secs then fly".
        // Let's spawn them now.
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (!mounted) return;
          _spawnFlyingItem(
            startPos,
            targetPos,
            widget.learnedItems[i],
            onComplete: checkCompletion,
          );
        });
      }

      // If no learned items, trigger completion immediately
      if (widget.learnedItems.isEmpty) {
        checkCompletion();
      }
    }
  }

  void _spawnFlyingItem(
    Offset startPos,
    Offset targetPos,
    String text, {
    required VoidCallback onComplete,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingItemAnimation(
        startPos: startPos,
        targetPos: targetPos,
        text: text,
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
                _buildProfileDisplay(),
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

  Widget _buildProfileDisplay() {
    final userProfileAsync = ref.watch(userProfileProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bambooLight.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.bambooGreen,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Avatar Circle
            Container(
              key: _avatarKey,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.pandaBlack, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.pandaBlack,
                    offset: Offset(2, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: userProfileAsync.when(
                  data: (data) {
                    final avatarUrl = data?['avatar_url'] as String?;
                    if (avatarUrl != null && avatarUrl.isNotEmpty) {
                      return Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text("🐼", style: TextStyle(fontSize: 80)),
                        ),
                      );
                    }
                    return const Center(
                      child: Text("🐼", style: TextStyle(fontSize: 80)),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Center(
                    child: Text("🐼", style: TextStyle(fontSize: 80)),
                  ),
                ),
              ),
            ),
            // Tag
            Positioned(
              top: -8,
              right: -8,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.pandaBlack, width: 3),
                  ),
                  child: const Center(
                    child: Text("🎉", style: TextStyle(fontSize: 16)),
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
        ExpBadge(
          pandaKey: pandaIconKey,
          onTap: () => _startAnimation(awardXp: false),
        ),

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
  final String text;
  final VoidCallback onComplete;

  const _FlyingItemAnimation({
    required this.startPos,
    required this.targetPos,
    required this.text,
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
  late double _rotation;
  late Color _bgColor;
  late Color _textColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final random = Random();
    _rotation = (random.nextDouble() - 0.5) * 0.4; // -0.2 to 0.2 rad

    // Random styling
    final colors = [
      AppColors.bambooLight,
      AppColors.accentYellow,
      AppColors.levelBlueLight,
      Colors.white,
    ];
    _bgColor = colors[random.nextInt(colors.length)];
    // Make text white for blue/darker bg if needed, or always black?
    // User sample: blue bg has white text. Others have panda-black.
    _textColor =
        (_bgColor ==
            AppColors
                .levelBlueLight) // Checking color value might differ if const
        ? Colors.white
        : AppColors.pandaBlack;

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Scale down as it flies in (to avatar)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    // Wait 2 seconds before flying
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.forward().then((_) => widget.onComplete());
      }
    });
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
            (widget.targetPos.dx - widget.startPos.dx) * _animation.value;

        final currentY =
            widget.startPos.dy +
            (widget.targetPos.dy - widget.startPos.dy) * _animation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.pandaBlack, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
