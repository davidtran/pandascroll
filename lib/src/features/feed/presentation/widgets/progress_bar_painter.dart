import 'package:flutter/material.dart';

class ProgressBarPainter extends CustomPainter {
  final ValueNotifier<double> timeNotifier;
  final double totalDuration;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBarPainter({
    required this.timeNotifier,
    required this.totalDuration,
    required this.backgroundColor,
    required this.progressColor,
  }) : super(
         repaint: timeNotifier,
       ); // <--- Key: Repaints only when notifier changes

  @override
  void paint(Canvas canvas, Size size) {
    final double currentTime = timeNotifier.value;

    // Prevent division by zero
    final double progress = totalDuration > 0
        ? (currentTime / totalDuration).clamp(0.0, 1.0)
        : 0.0;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Draw Background
    paint.color = backgroundColor;
    final RRect backgroundRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(2),
    );
    canvas.drawRRect(backgroundRect, paint);

    // Draw Progress
    if (progress > 0) {
      paint.color = progressColor;
      final RRect progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress, size.height),
        const Radius.circular(2),
      );
      canvas.drawRRect(progressRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressBarPainter oldDelegate) {
    return oldDelegate.totalDuration != totalDuration;
  }
}
