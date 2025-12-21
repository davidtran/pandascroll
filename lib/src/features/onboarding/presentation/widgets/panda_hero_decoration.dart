import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PandaHeroDecoration extends StatelessWidget {
  const PandaHeroDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    // Base logical size for the drawing coordinate system
    const double logicalWidth = 160;
    const double logicalHeight = 128;
    // Scale down factor
    const double scale = 0.5;

    return SizedBox(
      width: logicalWidth * scale,
      height: logicalHeight * scale,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: logicalWidth,
          height: logicalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left Ear
              Positioned(
                left: 0,
                top: -12,
                child: Transform.rotate(
                  angle: -15 * 3.14159 / 180,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: AppColors.pandaBlack,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Right Ear
              Positioned(
                right: 0,
                top: -12,
                child: Transform.rotate(
                  angle: 15 * 3.14159 / 180,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: AppColors.pandaBlack,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Face Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(64),
                    topRight: Radius.circular(64),
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                  border: Border.all(color: AppColors.pandaBlack, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Left Eye
                    Positioned(
                      left: 24,
                      top: 32,
                      child: _buildEye(isLeft: true),
                    ),
                    // Right Eye
                    Positioned(
                      right: 24,
                      top: 32,
                      child: _buildEye(isLeft: false),
                    ),
                    // Nose
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 76, // ~60%
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.pandaBlack,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Cheeks
                    Positioned(
                      left: 16,
                      top: 84, // ~65%
                      child: _buildCheek(),
                    ),
                    Positioned(
                      right: 16,
                      top: 84, // ~65%
                      child: _buildCheek(),
                    ),
                  ],
                ),
              ),

              // Paws (Bottom, peeking out)
              Positioned(
                bottom: -24,
                left: -32,
                child: Transform.rotate(
                  angle: 45 * 3.14159 / 180,
                  child: Container(
                    width: 64,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.pandaBlack,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -24,
                right: -32,
                child: Transform.rotate(
                  angle: -45 * 3.14159 / 180,
                  child: Container(
                    width: 64,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.pandaBlack,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEye({required bool isLeft}) {
    return Transform.rotate(
      angle: (isLeft ? -15 : 15) * 3.14159 / 180,
      child: Container(
        width: 40,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.pandaBlack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: isLeft ? 10 : null,
              right: isLeft ? null : 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheek() {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.pink[200]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)],
        ),
      ),
    );
  }
}
