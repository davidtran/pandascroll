import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/joy_text.dart';
import '../widgets/landing_background_painter.dart';
import '../widgets/panda_button.dart';
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
      "step": "step 1: watch",
      "icon": Icons.ondemand_video_rounded,
      "titlePrefix": "immersion through",
      "joyText": "video!",
      "body":
          "scroll through millions of videos in the language you want to learn. it's fun and effective!",
      "image": "assets/images/panda_login.png",
    },
    {
      "step": "step 2: play",
      "icon": Icons.videogame_asset_rounded,
      "titlePrefix": "don't just watch.",
      "joyText": "interaction!",
      "body": "do the exercises to lock it in. it's fun, fast and effective!",
      "image": "assets/images/panda_thinking.png",
    },
    {
      "step": "step 3: fluency",
      "icon": Icons.psychology_rounded,
      "titlePrefix": "rot your brain with a",
      "imageWidth": 180,
      "joyText": "new language",
      "body":
          "dive into endless short videos and exercises until you achieve total fluency!",
      "image": "assets/images/panda_learn.png",
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

          // --- Background Decorations ---
          // Landing Background
          Positioned.fill(
            child: CustomPaint(painter: LandingBackgroundPainter()),
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
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Image.asset(
                                  slide['image'],
                                  fit: BoxFit.fill,
                                  width:
                                      (slide['imageWidth'] as num?)
                                          ?.toDouble() ??
                                      250.0,
                                ),
                              ),
                            ),
                          ),

                          // Text Content
                          Padding(
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
                                    color: Colors.white,
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
                                const SizedBox(height: 18),

                                // Title
                                Column(
                                  children: [
                                    Text(
                                      slide['titlePrefix'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: pandaDark,
                                        height: 1.1,
                                      ),
                                    ),
                                    JoyText(
                                      text: slide['joyText'],
                                      fontSize: 32,
                                      borderColor: Colors.amberAccent,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Body
                                Text(
                                  slide['body'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45, // gray-500
                                  ),
                                ),
                              ],
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
                            ? "let's start!"
                            : "next",
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
