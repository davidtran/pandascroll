import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/dictionary_model.dart';

class DictionaryPanel extends StatelessWidget {
  final DictionaryModel data;

  const DictionaryPanel({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word & Pronunciation
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.word,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                data.pronunciation,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Type & Translation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryBrand.withOpacity(0.5),
              ),
            ),
            child: Text(
              data.type.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryBrand,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.translation,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 24),

          // How to use
          _buildSectionTitle(context, "How to use"),
          const SizedBox(height: 8),
          Text(
            data.howToUse,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Examples
          if (data.examples.isNotEmpty) ...[
            _buildSectionTitle(context, "Examples"),
            const SizedBox(height: 16),
            ...data.examples.map(
              (example) => _buildExampleCard(context, example),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExampleCard(BuildContext context, Example example) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            example.pronunciation,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            example.translation,
            style: const TextStyle(color: AppColors.primaryBrand, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
