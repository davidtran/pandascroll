import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class UpgradeBottomBar extends StatelessWidget {
  final Package? selectedPackage;
  final VoidCallback onTap;

  const UpgradeBottomBar({
    super.key,
    required this.selectedPackage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPackage == null) {
      return const SizedBox.shrink();
    }

    final product = selectedPackage!.storeProduct;
    final priceString = product.priceString;
    final introPrice = product.introductoryPrice;

    // Check if there is a free trial
    // RevenueCat: introPrice != null check usually sufficient implies some intro offer.
    // Ideally check paymentMode == PaymentMode.freeTrial
    final hasTrial = introPrice != null && introPrice.price == 0;

    String buttonText = "Subscribe for $priceString";
    String helperText = "Cancel anytime in settings.";

    if (hasTrial) {
      final unit = introPrice.periodUnit;
      final count = introPrice.periodNumberOfUnits;
      String duration = "$count ";
      switch (unit) {
        case PeriodUnit.day:
          duration += count > 1 ? "days" : "day";
          break;
        case PeriodUnit.week:
          duration += count > 1 ? "weeks" : "week";
          break;
        case PeriodUnit.month:
          duration += count > 1 ? "months" : "month";
          break;
        case PeriodUnit.year:
          duration += count > 1 ? "years" : "year";
          break;
        case PeriodUnit.unknown:
          duration = "";
          break;
      }

      buttonText = "Start $duration free trial";
      helperText =
          "We'll remind you 2 days before your trial ends. $priceString after. Cancel anytime in settings.";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism
          child: Column(
            children: [
              PandaButton(
                text: buttonText,
                onPressed: onTap,
                height: 64,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Text(
                helperText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
