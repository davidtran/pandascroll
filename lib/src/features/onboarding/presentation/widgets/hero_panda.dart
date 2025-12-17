import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeroPanda extends StatelessWidget {
  final double size;

  const HeroPanda({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative Blob Background
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          // Placeholder for Panda Image
          // In a real app, this would be Image.asset('assets/images/panda_hero.png')
          Icon(
            Icons.pets, // Panda-ish icon
            size: size * 0.5,
            color: AppColors.textMain,
          ),
          // "Hachimaki" headband implication (just a colored strip for now if we were drawing shapes, but icon is enough for placeholder)
        ],
      ),
    );
  }
}
