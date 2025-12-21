import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class JoyText extends StatelessWidget {
  const JoyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        const Text(
          "joy!",
          style: TextStyle(
            fontSize: 48, // text-4xl/5xl equivalent
            fontWeight: FontWeight.bold,
            color: AppColors.bambooDark,
            fontFamily: 'Fredoka',
            height: 1.0,
          ),
        ),
        Positioned(
          bottom: -6,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 12),
            painter: _SmilePainter(),
          ),
        ),
      ],
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bambooGreen.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // M0 5
    path.moveTo(0, size.height / 2);
    // Q 50 10 100 5 -> Quadratic bezier to (width, height/2) with control point at (width/2, height)
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
