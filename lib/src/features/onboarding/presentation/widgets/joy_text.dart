import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class JoyText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color borderColor;
  const JoyText({
    super.key,
    required this.text,
    this.fontSize = 48,
    this.borderColor = AppColors.bambooGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
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
            painter: _SmilePainter(borderColor: borderColor),
          ),
        ),
      ],
    );
  }
}

class _SmilePainter extends CustomPainter {
  final Color borderColor;
  _SmilePainter({required this.borderColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor.withOpacity(0.5)
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
