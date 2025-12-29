import 'package:flutter/material.dart';

class StripeProgressBar extends StatefulWidget {
  final double progress;
  // Make these customizable or constants
  final Color color;
  final Color stripeColor;

  const StripeProgressBar({
    super.key,
    required this.progress,
    this.color = Colors.blue, // Replace with AppColors.primaryBrand
    this.stripeColor = const Color(0x4DFFFFFF), // White with 0.3 opacity
  });

  @override
  State<StripeProgressBar> createState() => _StripeProgressBarState();
}

class _StripeProgressBarState extends State<StripeProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _stripeController;

  @override
  void initState() {
    super.initState();
    _stripeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _stripeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Static Container Setup
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // 2. Solid Fill
            FractionallySizedBox(
              widthFactor: widget.progress,
              child: Container(color: widget.color),
            ),

            // 3. Animated Stripes (Optimized)
            // Note: No AnimatedBuilder here. The repaint listener is inside the painter.
            FractionallySizedBox(
              widthFactor: widget.progress,
              child: ClipRect(
                child: CustomPaint(
                  painter: _OptimizedStripePainter(
                    animation: _stripeController,
                    stripeWidth: 8.0,
                    color: widget.stripeColor,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptimizedStripePainter extends CustomPainter {
  final Animation<double> animation;
  final double stripeWidth;
  final Color color;

  // Cache the paint object to avoid allocation per frame
  final Paint _paint;

  _OptimizedStripePainter({
    required this.animation,
    required this.stripeWidth,
    required this.color,
  }) : _paint = Paint()..color = color,
       super(repaint: animation); // Triggers paint() when animation ticks

  // Cache the path so we don't recalculate geometry every frame
  Path? _cachedPath;
  Size? _cachedSize;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Generate path only if size changes
    if (_cachedPath == null || size != _cachedSize) {
      _cachedSize = size;
      _cachedPath = _createStripePath(size);
    }

    final period = stripeWidth * 2;

    // 2. Calculate shift based on animation value (0.0 to 1.0)
    // We shift *right* by one period length over the course of 1 second
    final double shift = animation.value * period;

    // 3. Draw
    canvas.save();
    canvas.translate(shift, 0); // Cheap GPU operation
    canvas.drawPath(_cachedPath!, _paint);
    canvas.restore();
  }

  Path _createStripePath(Size size) {
    final path = Path();
    final double period = stripeWidth * 2;

    // We draw extra stripes on the left (-period) so that when we
    // translate the canvas to the right, we don't see a gap.
    final int count = (size.width / stripeWidth).ceil() * 2 + 2;

    for (int i = -2; i < count; i++) {
      // Logic for drawing the parallelogram
      double startX = i * period;

      path.moveTo(startX, size.height);
      path.lineTo(startX + stripeWidth, size.height);
      path.lineTo(startX + stripeWidth + size.height, 0);
      path.lineTo(startX + size.height, 0);
      path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _OptimizedStripePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.stripeWidth != stripeWidth;
  }
}
