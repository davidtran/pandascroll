import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/panda_button.dart';
import '../widgets/phone_mockup.dart';
import 'native_language_view.dart';
import 'dart:math' as math;

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Colors from design
  static const Color creamBg = Color(0xFFFEFDF5);
  static const Color pandaGreen = Color(0xFF4ADE80);
  static const Color pandaDark = Color(0xFF1F2937);
  static const Color pandaBorder = Color(0xFF134E4A);
  static const Color accentYellow = Color(0xFFFCD34D);

  final List<Map<String, dynamic>> _slides = [
    {
      "step": "Step 1: Immersion",
      "icon": Icons.school_rounded,
      "title": "Don't Just Watch. Do.",
      "body": "Learn real languages from real videos. Swipe up to learn.",
    },
    {
      "step": "Step 2: Interaction",
      "icon": Icons.touch_app_rounded,
      "title": "Quizzes Inside Action.",
      "body": "Tap the right answer while the video plays. Miss it? Try again.",
    },
    {
      "step": "Step 3: Mastery",
      "icon": Icons.sports_kabaddi_rounded,
      "title": "Defeat the Boss.",
      "body": "Prove your skills in epic boss battles and earn loot.",
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NativeLanguageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // --- Background Decorations ---

          // Dots Pattern (Custom Painter for "bg-dots")
          Positioned.fill(
            child: CustomPaint(
              painter: DotsPainter(color: pandaBorder.withOpacity(0.08)),
            ),
          ),

          // Blurred Blobs
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlurBlob(pandaGreen.withOpacity(0.1), 300),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildBlurBlob(accentYellow.withOpacity(0.2), 250),
          ),

          // Leaf Shapes
          Positioned(
            top: 48,
            left: -16,
            child: _buildLeaf(pandaGreen.withOpacity(0.4), 48, 30),
          ),
          Positioned(
            top: 96,
            right: -8,
            child: _buildLeaf(pandaGreen.withOpacity(0.3), 32, -120),
          ),

          // --- Main Content ---
          SafeArea(
            child: Column(
              children: [
                // Header (Progress + Skip)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress Indicators
                      Row(
                        children: List.generate(_slides.length, (index) {
                          bool isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 12,
                            width: isActive ? 40 : 12,
                            decoration: BoxDecoration(
                              color: isActive ? pandaGreen : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              border: isActive
                                  ? Border.all(color: pandaBorder, width: 2)
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 2,
                                    ),
                              boxShadow: isActive
                                  ? [
                                      const BoxShadow(
                                        color: pandaBorder,
                                        offset: Offset(2, 2),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : [],
                            ),
                          );
                        }),
                      ),

                      // Skip Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NativeLanguageView(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: pandaBorder,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: const Text("SKIP"),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration Area
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // Decorative Emojis
                                  const Positioned(
                                    top: -20,
                                    right: 10,
                                    child: Text(
                                      "🐼",
                                      style: TextStyle(fontSize: 60),
                                    ),
                                    // Add bounce animation if time permits
                                  ),
                                  const Positioned(
                                    bottom: 30,
                                    left: -10,
                                    child: Text(
                                      "🎋",
                                      style: TextStyle(fontSize: 48),
                                    ),
                                  ),

                                  // Phone Mockup (Rotated)
                                  Transform.rotate(
                                    angle: -2 * math.pi / 180, // -2 degrees
                                    child: const PhoneMockup(
                                      width: 260,
                                      height:
                                          500, // Slightly smaller to fit layout
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Text Content
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 32,
                              ),
                              child: Column(
                                children: [
                                  // Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pandaGreen,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: pandaBorder,
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: pandaBorder,
                                          offset: Offset(2, 2),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    transform: Matrix4.rotationZ(
                                      -1 * math.pi / 180,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          slide['icon'],
                                          size: 16,
                                          color: pandaDark,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          slide['step'].toUpperCase(),
                                          style: const TextStyle(
                                            color: pandaDark,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Title
                                  Text(
                                    slide['title'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily:
                                          'Nunito', // Or 'Cartoon' font from HTML
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: pandaDark,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Body
                                  Text(
                                    slide['body'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey, // gray-500
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Footer Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    children: [
                      PandaButton(
                        text: _currentPage == _slides.length - 1
                            ? "Let's Start!"
                            : "Next",
                        icon: Icons.pets,
                        backgroundColor: pandaGreen,
                        textColor: pandaDark,
                        borderColor: pandaBorder,
                        height: 64,
                        fontSize: 20,
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return SizedBox(width: size, height: size).chainBlur(60, color);
  }

  Widget _buildLeaf(Color color, double size, double angleDeg) {
    return Transform.rotate(
      angle: angleDeg * math.pi / 180,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(100),
            bottomLeft: Radius.circular(100),
          ),
        ),
      ),
    );
  }
}

// Extension to easily blur a widget (requires ui import but we can use BackdropFilter wrapper logic or just blur the decoration if possible,
// but Flutter MaskFilter.blur is for drawing.
// A simple way is ImageFilter.blur.
extension BlurExt on Widget {
  Widget chainBlur(double sigma, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: sigma, spreadRadius: 10),
        ],
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  final Color color;
  DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double spacing = 24;
    const double radius = 1;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
