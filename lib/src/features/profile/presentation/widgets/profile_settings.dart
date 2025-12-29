import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileSettings extends ConsumerWidget {
  const ProfileSettings({super.key});

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    // No need to navigate manually, RootView listens to auth state
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("General"),
        _buildSettingsContainer([
          _buildSettingsItem(
            icon: FontAwesomeIcons.discord,
            title: "support",
            color: const Color(0xFF5865F2), // Discord Blurple
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(height: 4, thickness: 2, color: Colors.black),
          _buildSettingsItem(
            icon: Icons.description_rounded,
            title: "terms",
            color: Colors.grey,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(height: 4, thickness: 2, color: Colors.black),
          _buildSettingsItem(
            icon: Icons.privacy_tip_rounded,
            title: "privacy",
            color: Colors.grey,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ]),

        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: const Offset(2, 2)),
            ],
          ),
          child: TextButton(
            onPressed: () => _logout(ref, context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Text(
              "logout",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red.shade50,
            ),
            child: const Text(
              "clear data",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: Colors.grey[500],
          fontFamily: 'Fredoka',
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [BoxShadow(color: Colors.black, offset: const Offset(4, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color color,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.pandaBlack,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
