import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_dictionary_model.dart';
import '../../../feed/presentation/widgets/quiz/tts_player.dart';

class DictionaryEntryCard extends StatelessWidget {
  final UserDictionaryEntry entry;
  final VoidCallback onTap;

  const DictionaryEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final data = entry.dictionary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.pandaBlack, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.pandaBlack,
              offset: Offset(2, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              data.word,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                                fontFamily: 'Fredoka', // Display font
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                data.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.translation, // Using translation as short def
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TtsPlayer(
              id: entry.dictionaryId.toString(), // Using dictionaryId as ID
              type: 'dictionary', // Assuming 'word' type for simple playback
              size: 34, // w-11 h-11 ~= 44
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String word) {
    // Mimicking the colorful box with character
    // For now, allow random colors or hash based
    final color = [
      AppColors.bambooLight,
      AppColors.accentYellow,
      Colors.purple[200]!,
      Colors.blue[200]!,
    ][word.length % 4];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pandaBlack, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.pandaBlack,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        word.isNotEmpty ? word[0] : '?',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.pandaBlack,
          fontFamily: 'Fredoka',
        ),
      ),
    );
  }
}
