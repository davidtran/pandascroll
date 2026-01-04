import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class ExerciseReviewWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ExerciseReviewWidget({super.key, required this.onClose});

  @override
  State<ExerciseReviewWidget> createState() => _ExerciseReviewWidgetState();
}

class _ExerciseReviewWidgetState extends State<ExerciseReviewWidget> {
  // Mock data for the review
  final String nativeText = "I would like one iced coffee.";
  final String targetText = "Tôi muốn một ly cà phê đá.";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: AppColors.pandaBlack),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bambooLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bambooDark, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Streak: 12',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        color: AppColors.bambooDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Balance for close button
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Review',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w900,
                            color: AppColors.pandaBlack,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.pandaBlack,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.pandaBlack,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        '1/5',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.pandaBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.pandaBlack, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.pandaBlack,
                        offset: Offset(4, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Audio Button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.levelBlueLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.pandaBlack,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.pandaBlack,
                              offset: Offset(2, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text Content
                      Text(
                        nativeText,
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: AppColors.pandaBlack,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 2,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        targetText,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.bambooDark,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic for "I know this"
                        },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.pandaBlack,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: AppColors.pandaBlack,
                                  width: 3,
                                ),
                              ),
                              elevation: 0,
                            ).copyWith(
                              shadowColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                        child: const Text(
                          'Hard',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic for "Next"
                        },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.bambooGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: AppColors.pandaBlack,
                                  width: 3,
                                ),
                              ),
                              elevation: 0,
                            ).copyWith(
                              shadowColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                        child: const Text(
                          'Easy',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
