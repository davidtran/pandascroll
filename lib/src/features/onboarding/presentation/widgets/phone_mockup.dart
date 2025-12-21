import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PhoneMockup extends StatelessWidget {
  final double width;
  final double height;

  const PhoneMockup({super.key, this.width = 280, this.height = 500});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 2 * 3.14159 / 180, // Rotate 2 degrees
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // rounded-[3rem]
          border: Border.all(color: Colors.white, width: 0),
          boxShadow: [
            // Ring
            BoxShadow(
              color: AppColors.pandaBlack.withValues(alpha: 0.05),
              spreadRadius: 4,
            ),
            // Shadow Cartoon
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            const Image(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBhcOx2jfTS_l78OPraKcahJh8rE_0Smi-hbHe2M79zBiWtIW3FmQ3ZyPiRdHAP4eUC_WqfsEEFSJBktbCR-YMSY28gt0HknEh5UEPiUtxFFsGPZRuDO2spdA2-0sS1HmtnIL5raPGPDBcXeFYa70gaBHJM_dT7qAqmYqX8NrgL0gxWMgOWZnCQOdelH5pbVDFomuD6S1ZreJ1Hv6FOu9OmizJcIMg4fhPxM_ENbXcOKG15qTNhYQ5fpS1UxP6p65pF791o9y2eTIE',
              ),
              fit: BoxFit.cover,
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

            // Right Side Buttons
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCircleBtn(Icons.favorite, Colors.red),
                    const SizedBox(height: 12),
                    _buildCircleBtn(Icons.chat_bubble, AppColors.pandaBlack),
                  ],
                ),
              ),
            ),

            // Bottom "Daily Goal" Card
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.bambooGreen,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDZGzPoT9AyCAaEiHxxQVnkEN8jq3Dn6kOx4xyFFzmmEZfFB8QOdpeb8Z4kWX6pYVOl3rgZimd41kRnoZEOUOX1OiLgiKd4vTBYU2bxr720wtbsV2AINHW9p0Auf_rbek6Bp1AzGjVxJPhjFfdwhI3TE4HeR5jzikPqPn4No4drw76PiedCccQeMR12dPUerApQs54ZXSABlIfpUSUOpWuJ969J0o0KCevwhD1C3XWjl-I5bPObpZv2T81Y6uetux9geGL5zfr4BLY',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DAILY GOAL",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              "Learning 🐼 !",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pandaBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 0.75,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bambooGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Center(child: Icon(icon, color: color, size: 24)),
    );
  }
}
