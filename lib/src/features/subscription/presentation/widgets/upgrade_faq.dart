import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UpgradeFAQ extends StatelessWidget {
  const UpgradeFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
          child: Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.pandaBlack,
            ),
          ),
        ),
        _buildFAQItem(
          "Is this suitable for beginners?",
          "Absolutely! Our lessons adapt to your level. Whether you're just starting or looking to polish your skills, we've got you covered.",
          AppColors.primaryBrand.withOpacity(0.2), // Light Green bg
        ),
        _buildFAQItem(
          "Can I switch learning languages?",
          "Yes! You can add and switch between multiple languages at any time without losing your progress.",
          const Color(0xFFE9D5FF), // Light Purple bg
        ),
        _buildFAQItem(
          "How does the 7-day free trial work?",
          "You get full access to all Premium features for 7 days. You won't be charged until the trial ends, and you can cancel anytime.",
          const Color(0xFFBAE6FD), // Light Blue bg
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pandaBlack, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardSecondaryShadow,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.pandaBlack,
          collapsedIconColor: AppColors.pandaBlack,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            question,
            style: const TextStyle(
              fontFamily: 'Fredoka', // Fun font for questions
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.pandaBlack,
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.pandaBlack.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
