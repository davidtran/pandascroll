import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/exp_badge.dart';

class ExerciseCompleteWidget extends StatefulWidget {
  final VoidCallback onSemesterExercises;
  final VoidCallback onNextVideo;

  const ExerciseCompleteWidget({
    super.key,
    required this.onSemesterExercises,
    required this.onNextVideo,
  });

  @override
  State<ExerciseCompleteWidget> createState() => _ExerciseCompleteWidgetState();
}

class _ExerciseCompleteWidgetState extends State<ExerciseCompleteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

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
        const ExpBadge(),

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
                      color: isPrimary ? Colors.white : AppColors.pandaBlack,
                      shadows: isPrimary
                          ? const [
                              Shadow(
                                offset: Offset(1, 1),
                                color: Colors.black26,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrimary
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey,
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
