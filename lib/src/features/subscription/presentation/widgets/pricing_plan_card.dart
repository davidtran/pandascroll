import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PricingPlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceAmount;
  final String pricePeriod;
  final String? oldPrice; // For strikethrough logic (e.g. $108/year value)
  final List<String> features;
  final String buttonText;
  final VoidCallback onTap;
  final bool isBestValue;
  final Color backgroundColor;
  final Color buttonColor;
  final Color buttonTextColor;

  const PricingPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priceAmount,
    required this.pricePeriod,
    this.oldPrice,
    required this.features,
    required this.buttonText,
    required this.onTap,
    this.isBestValue = false,
    this.backgroundColor = Colors.white,
    this.buttonColor = Colors.white,
    this.buttonTextColor = AppColors.pandaBlack,
  });

  @override
  Widget build(BuildContext context) {
    // Determine border width/radius based on vibe
    const double borderRadius = 32.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.pandaBlack, width: 4),
            boxShadow: [
              // Neo-brutalism shadow
              BoxShadow(
                color: AppColors.pandaBlack,
                offset: const Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Hug content
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: AppColors.pandaBlack,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isBestValue
                          ? AppColors.pandaBlack.withOpacity(0.7)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        color: AppColors.pandaBlack,
                        height: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: priceAmount,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: "/$pricePeriod",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isBestValue
                                ? AppColors.pandaBlack.withOpacity(0.7)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (oldPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        oldPrice!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          decorationColor: AppColors.pandaBlack,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Features List
              Column(
                children: features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        isBestValue
                            ? Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.pandaBlack,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star, // Simplified icon logic
                                  color: Colors.white,
                                  size: 12,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBrand,
                                size: 20,
                              ),
                        const SizedBox(width: 12),
                        // Text
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.pandaBlack.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onTap,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        elevation: 0,
                        side: const BorderSide(
                          color: AppColors.pandaBlack,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        shadowColor: Colors.transparent, // We want flat/neo
                      ).copyWith(
                        // Custom Shadow workaround if needed, but container shadow is usually enough.
                        // For the button itself to have neo-shadow like CSS:
                        elevation: MaterialStateProperty.resolveWith(
                          (states) => 0,
                        ),
                      ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Best Value Badge
        if (isBestValue)
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.05, // Slight rotation (-2deg)
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pandaBlack,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.accentYellow, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "BEST VALUE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
