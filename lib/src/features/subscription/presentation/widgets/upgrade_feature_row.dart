import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class UpgradeFeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const UpgradeFeatureRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.premiumBrand, // The green from design
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // Text Dark
              ),
            ),
          ),
        ],
      ),
    );
  }
}
