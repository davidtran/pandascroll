import 'package:flutter/material.dart';

class ExpBadge extends StatelessWidget {
  final GlobalKey pandaKey;

  const ExpBadge({super.key, required this.pandaKey});

  // Colors extracted from your tailwind config
  static const Color pandaBlack = Color(0xFF2D2D2D);
  static const Color bambooGreen = Color(0xFF4ADE80);
  static const Color bambooDark = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allows the tilted background to poke out
      children: [
        // 1. The Darker "Shadow" Layer (Background)
        // correlates to: "absolute inset-0 bg-bamboo-dark rotate-2 translate-y-1 translate-x-1"
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(4, 4), // translate-x-1 translate-y-1 approx
            child: Transform.rotate(
              angle: 2 * 3.14159 / 180, // rotate-2 (2 degrees)
              child: Container(
                decoration: BoxDecoration(
                  color: bambooDark,
                  borderRadius: BorderRadius.circular(16), // rounded-2xl
                ),
              ),
            ),
          ),
        ),

        // 2. The Main Badge Layer (Foreground)
        // correlates to: "relative bg-bamboo-green ... -rotate-1"
        Transform.rotate(
          angle: -1 * 3.14159 / 180, // -rotate-1 (-1 degree)
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: bambooGreen,
              borderRadius: BorderRadius.circular(16), // rounded-2xl
              border: Border.all(
                color: pandaBlack,
                width: 3, // border-[3px]
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Hug content
              children: [
                Image.asset(
                  'assets/images/paw.png',
                  width: 28,
                  height: 28,
                  key: pandaKey,
                ),
                const SizedBox(width: 8),
                Text(
                  "Exp +10!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900, // font-black
                    fontFamily: 'Fredoka', // Or your app's font
                    letterSpacing: 0.5, // tracking-wide
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
