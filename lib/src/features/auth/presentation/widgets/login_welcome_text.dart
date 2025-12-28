import 'package:flutter/material.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/joy_text.dart';
import '../../../../core/theme/app_colors.dart';

class LoginWelcomeText extends StatelessWidget {
  const LoginWelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "welcome ",
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.pandaBlack,
                height: 1.1,
              ),
            ),
            const JoyText(text: "Back!", fontSize: 32),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 280,
          child: Text(
            "pick up right where you left off with your daily lessons!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
