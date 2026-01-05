import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/utils/language_utils.dart';
import 'package:pandascroll/src/features/profile/data/profile_repository.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';

class ExercisePickerWidget extends ConsumerWidget {
  final VoidCallback onWordExerciseTap;
  final VoidCallback onSentenceExerciseTap;
  final VoidCallback? onMaybeLaterTap;

  const ExercisePickerWidget({
    super.key,
    required this.onWordExerciseTap,
    required this.onSentenceExerciseTap,
    this.onMaybeLaterTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.read(userProfileProvider).value;
    final languageName =
        LanguageUtils.getLanguageName(profile?['target_language'] as String) ??
        '';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pandaBlack, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.pandaBlack,
                        offset: Offset(4, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐼', style: TextStyle(fontSize: 48)),
                  ),
                ),
                Positioned(
                  bottom: -12,
                  child: Transform.rotate(
                    angle: 3 * 3.14159 / 180, // 3 degrees
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.pandaBlack,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.pandaBlack,
                            offset: Offset(2, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'PICK ONE!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: AppColors.pandaBlack,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Title
            Text(
              'Practice Time',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w900,
                color: AppColors.pandaBlack,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Master $languageName with a quick session.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Cards
            _ExerciseCard(
              title: 'Word Exercise',
              subtitle: 'VOCABULARY',
              xp: '+15 XP',
              icon: Icons.school_outlined, // Fallback icon
              color: AppColors.bambooGreen,
              xpColor: AppColors.bambooDark,
              xpBgColor: AppColors.bambooLight,
              onTap: onWordExerciseTap,
              hoverColor: AppColors.funBg,
              rotateIcon: 6,
            ),
            const SizedBox(height: 16),
            _ExerciseCard(
              title: 'Sentence Exercise',
              subtitle: 'GRAMMAR',
              xp: '+30 XP',
              icon: Icons.forum_outlined, // Fallback icon
              color: AppColors.accentOrange,
              xpColor: Colors.deepOrange, // Approximate
              xpBgColor: Colors.orange.shade100, // Approximate
              onTap: onSentenceExerciseTap,
              hoverColor: Colors.orange.shade50,
              rotateIcon: -6,
            ),

            const SizedBox(height: 16),
            if (onMaybeLaterTap != null)
              TextButton(
                onPressed: onMaybeLaterTap,
                child: Text(
                  'MAYBE LATER',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[400],
                    letterSpacing: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String xp;
  final IconData icon;
  final Color color;
  final Color xpColor;
  final Color xpBgColor;
  final VoidCallback onTap;
  final Color hoverColor;
  final double rotateIcon;

  const _ExerciseCard({
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.icon,
    required this.color,
    required this.xpColor,
    required this.xpBgColor,
    required this.onTap,
    required this.hoverColor,
    required this.rotateIcon,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.pandaBlack, width: 3),
          boxShadow: [
            if (!_isPressed)
              const BoxShadow(
                color: AppColors.pandaBlack,
                offset: Offset(4, 6),
                blurRadius: 0,
              ),
            if (_isPressed)
              const BoxShadow(
                color: AppColors.pandaBlack,
                offset: Offset(2, 3),
                blurRadius: 0,
              ),
          ],
        ),
        padding: const EdgeInsets.all(4), // Outer padding for border effect
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isPressed ? widget.hoverColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Icon Box
              Transform.rotate(
                angle: (_isPressed ? widget.rotateIcon : 0) * 3.14159 / 180,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.pandaBlack, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.pandaBlack,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // XP Badge
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 10,
              //     vertical: 4,
              //   ),
              //   decoration: BoxDecoration(
              //     color: widget.xpBgColor,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: widget.xpColor, width: 2),
              //   ),
              //   child: Text(
              //     widget.xp,
              //     style: TextStyle(
              //       fontFamily: 'Nunito',
              //       fontWeight: FontWeight.w900,
              //       fontSize: 12,
              //       color: widget.xpColor,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
