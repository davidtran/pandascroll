import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/edit_profile_panel.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_providers.dart';
import '../../../../core/constants/language_constants.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final languageProfileAsync = ref.watch(userLanguageProfileProvider);

    final profileData = profileAsync.value;
    final level = languageProfileAsync.value?.level ?? 1;

    final avatarUrl = profileData?['avatar_url'] as String?;
    final username = profileData?['username'] as String? ?? 'User';
    final targetLangCode = profileData?['target_language'] as String?;

    final targetLangName = targetLangCode != null
        ? LanguageConstants.targetLanguages
              .firstWhere(
                (l) => l.code == targetLangCode,
                orElse: () => LanguageConstants.targetLanguages.first,
              )
              .name
        : 'Language';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Decorative dots (Behind)
            Positioned(top: -8, left: -8, child: _buildDot()),
            Positioned(top: -8, right: -8, child: _buildDot()),

            // Avatar Container
            Container(
              width: 120,
              height: 120,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.network(
                  avatarUrl ??
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuANlJyF7pvtcA0vFRyJEQFa7XkoUIgUyQWhE4Gc5CZE8a4qkbeRdMDmCCNIqHtI5LhZkzSGSyBvbeCZz0oq0FcN3KL1M-MvQ2l4sJ1mjtyIoIfghT_RcENVTfhs5UmfWeF3Hy_lunl8MS3gOi6healG8WlHFAwKXJvg1o-2dbVwZ9NWy5seJpd-Y0ppzUuDydRuCBKS8aXs7q-0XAYayTXRuct4XnkgMaCvJzy8ef9tfS5sXuoBtbz3tcoEn-kaFdYvJebPEUqDxoE",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Level Badge
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Lvl $level",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Name & Info
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.pandaBlack,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "learn $targetLangName",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Edit Button
        Material(
          color: AppColors.pandaBlack,
          borderRadius: BorderRadius.circular(16),

          // ... Inside build method ...
          child: InkWell(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    EditProfilePanel(onClose: () => Navigator.pop(context)),
              );
              // Refresh profile on close
              ref.refresh(userProfileProvider);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.pandaBlack,
        shape: BoxShape.circle,
      ),
    );
  }
}
