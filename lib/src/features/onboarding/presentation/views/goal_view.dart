import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/panda_button.dart';
import '../../../../core/services/notification_service.dart';
import '../../../feed/presentation/views/feed_view.dart';

class GoalView extends StatefulWidget {
  const GoalView({super.key});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  double _currentSliderValue = 5;

  int get _videoCount => _currentSliderValue.round();

  Future<void> _commitGoal() async {
    final notificationService = NotificationService();
    await notificationService.requestPermissions();
    await notificationService.scheduleDailyReminders();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FeedView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_buildSquareBtn(Icons.arrow_back)],
                    ),
                  ),

                  const Spacer(),

                  // Panda Hero
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Image
                      SizedBox(
                        height: 100,
                        child: Image.asset(
                          'assets/images/panda.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Question Text (Moved below image)
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "How fast do you want to become fluent?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Goal Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(64),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 242, 242, 242),
                          width: 4,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 10),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "$_videoCount",
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                                fontFamily: 'Fredoka',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "videos",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                                fontFamily: 'Fredoka',
                              ),
                            ),
                          ],
                        ),

                        // Time Estimate Badge
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrand.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 16,
                                color: AppColors.bambooDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "~${(_videoCount)} mins / day", // Adjusted estimate
                                style: const TextStyle(
                                  color: AppColors.bambooDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryBrand,
                            inactiveTrackColor: Colors.grey[200],
                            thumbColor: Colors.white,
                            trackHeight: 16,
                            overlayColor: AppColors.primaryBrand.withOpacity(
                              0.2,
                            ),
                            thumbShape: _PandaThumbShape(),
                            trackShape: _CustomTrackShape(),
                          ),
                          child: Slider(
                            value: _currentSliderValue,
                            min: 1,
                            max: 30,
                            divisions: 29,
                            onChanged: (value) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Creating a habit is key! Picking a daily target helps you stay consistent.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gamification context
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.accentFun,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Earn 10 XP per video",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 0,
                      left: 24,
                      right: 24,
                    ),
                    child: PandaButton(
                      text: "Commit Goal",
                      onPressed: _commitGoal,
                      icon: Icons.arrow_forward,
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

  Widget _buildDot(Color color, double width) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSquareBtn(IconData icon) {
    return GestureDetector(
      onTap: () {
        if (icon == Icons.arrow_back) Navigator.of(context).pop();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textMain, size: 24),
      ),
    );
  }
}

class _PandaThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(40, 40);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Border
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = AppColors.primaryBrand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Fill
    canvas.drawCircle(center, 16, Paint()..color = Colors.white);

    // Icon
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: "O",
        style: TextStyle(
          fontFamily: 'MaterialIcons',
          fontSize: 20,
          color: AppColors.primaryBrand,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    // Easier to just fill white for now or implement icon drawing later.
    // The previous design had an icon. Let's try drawing two small lines.

    final Paint linePaint = Paint()
      ..color = AppColors.primaryBrand
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Line 1
    canvas.drawLine(
      Offset(center.dx - 6, center.dy),
      Offset(center.dx + 6, center.dy),
      linePaint,
    );
    // Actually the design had two vertical lines? "drag_handle"
    // drag_handle is typically horizontal lines. Let's assume standard burger or handle.
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
