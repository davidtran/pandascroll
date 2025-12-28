import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class StripeProgressBar extends StatefulWidget {
  final double progress;

  const StripeProgressBar({required this.progress});

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Progress Fill
        return Container(
          height: 12, // Match height

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Match previous
            color: Colors.grey[200],
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: widget.progress,
                  child: Container(color: AppColors.primaryBrand),
                ),

                // 2. Animated Stripes
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _stripeController,
                    builder: (context, child) {
                      return ClipRect(
                        child: FractionallySizedBox(
                          widthFactor: widget.progress,
                          child: CustomPaint(
                            painter: _FixedStripePainter(
                              offset: _stripeController.value * 20.0,
                              stripeWidth: 8.0,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FixedStripePainter extends CustomPainter {
  final double offset;
  final double stripeWidth;
  final Color color;

  _FixedStripePainter({
    required this.offset,
    required this.stripeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // period
    final double period = stripeWidth * 2;

    final path = Path();

    // Coverage
    // We want stripes ///
    // from left to right.

    int count = (size.width / stripeWidth).ceil() * 2 + 5;

    for (int i = -5; i < count; i++) {
      double startX =
          i * period +
          (offset % period) -
          period; // Shift left by period to cover entrance?

      // Draw parallelogram leaning ///
      // Bottom-left: (startX, h)
      // Bottom-right: (startX + w, h)
      // Top-right: (startX + w + h, 0) -> lean right involves adding h to x at top
      // Top-left: (startX + h, 0)

      path.moveTo(startX, size.height);
      path.lineTo(startX + stripeWidth, size.height);
      path.lineTo(startX + stripeWidth + size.height, 0);
      path.lineTo(startX + size.height, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FixedStripePainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.color != color;
  }
}
