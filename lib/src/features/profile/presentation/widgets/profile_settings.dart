import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Turbo: auto-added
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileSettings extends ConsumerWidget {
  const ProfileSettings({super.key});

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    // No need to navigate manually, RootView listens to auth state
  }

  Future<void> _deleteAccount(WidgetRef ref, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        // Find repository - need to import it or use a provider if available
        // Easier: Use ApiClient directly or defined repository provider
        // Let's assume we can access repository via ref
        // We need to import profile_repository.dart first.
        // But cleaner is just to call the repository provider methods.
        await ref.read(profileRepositoryProvider).deleteUserData();

        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
          // Auth listener handles logout, but just to be sure
          await ref.read(authProvider.notifier).signOut();
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error deleting account: $e")));
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
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
            onTap: () => _launchUrl('https://discord.gg/NTazxUmaMG'),
          ),
          const Divider(height: 4, thickness: 2, color: Colors.black),
          _buildSettingsItem(
            icon: Icons.description_rounded,
            title: "terms",
            color: Colors.grey,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _launchUrl('https://langrot.com/terms'),
          ),
          const Divider(height: 4, thickness: 2, color: Colors.black),
          _buildSettingsItem(
            icon: Icons.privacy_tip_rounded,
            title: "privacy",
            color: Colors.grey,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _launchUrl('https://langrot.com/privacy'),
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
            onPressed: () => _deleteAccount(ref, context),
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
