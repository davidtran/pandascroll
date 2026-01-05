import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class QuestionWidget extends StatelessWidget {
  final Widget child;
  final String title;

  const QuestionWidget({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Main Content Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.funBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.pandaBlack, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.pandaBlack,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: child,
              ),
              // Floating Label
              Positioned(
                top: -14,
                child: Transform.rotate(
                  angle: -0.02,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.pandaBlack, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pandaBlack,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
