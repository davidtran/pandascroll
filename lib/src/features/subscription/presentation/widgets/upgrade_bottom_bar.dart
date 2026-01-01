import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class UpgradeBottomBar extends StatelessWidget {
  final String selectedPlan;
  final VoidCallback onTap;

  const UpgradeBottomBar({
    super.key,
    required this.selectedPlan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = selectedPlan == 'monthly' ? "\$9/mo" : "\$59/yr";

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(color: Colors.white),
      child: ClipRRect(
        // Clip for blur if we want, but Container color handles it.
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism
          child: PandaButton(
            text: "Unlock Panda Premium ($priceText)",
            onPressed: onTap,
            height: 64,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
