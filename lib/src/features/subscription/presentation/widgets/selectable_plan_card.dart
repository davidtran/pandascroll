import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SelectablePlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isBestValue;

  const SelectablePlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isBestValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            width: double.infinity,
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFEF08A)
                  : Colors.white, // Yellow-200 active
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.pandaBlack,
                width: 3, // Thicker border
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: AppColors.pandaBlack,
                        offset: Offset(6, 6), // Hard shadow
                        blurRadius: 0,
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: AppColors.pandaBlack,
                        offset: Offset(2, 2), // Smaller shadow when inactive
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Fredoka', // Fun font
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.pandaBlack.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          color: AppColors.pandaBlack,
                          height: 1.0,
                        ),
                        children: [
                          TextSpan(
                            text: price,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: "/$period",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pandaBlack.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pandaBlack,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isSelected)
                  Positioned(
                    right: 10,
                    top: 0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.pandaBlack,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFFFEF08A),
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.pandaBlack, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.pandaBlack,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
