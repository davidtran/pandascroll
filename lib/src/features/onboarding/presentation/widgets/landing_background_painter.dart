import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LandingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bambooGreen
          .withOpacity(0.3) // #BBF7D0 approx
      ..style = PaintingStyle.fill;

    const double gap = 32.0;
    const double radius = 2.0;

    for (double y = 0; y < size.height; y += gap) {
      for (double x = 0; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
