import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
// import 'dart:io'; // Not needed anymore
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../data/profile_repository.dart';

import '../../../../core/constants/language_constants.dart';
import '../../../onboarding/domain/models/language_option.dart';
import '../../../feed/presentation/widgets/interaction_panel.dart';
import '../../../onboarding/presentation/widgets/language_selector_widget.dart';
import '../../../onboarding/presentation/widgets/panda_button.dart';

class EditProfilePanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const EditProfilePanel({super.key, required this.onClose});

  @override
  ConsumerState<EditProfilePanel> createState() => _EditProfilePanelState();
}

class _EditProfilePanelState extends ConsumerState<EditProfilePanel> {
  late TextEditingController _nameController;
  String _selectedNativeLang = 'en';
  String _selectedTargetLang = 'zh';
  String? _avatarUrl =
      "https://lh3.googleusercontent.com/aida-public/AB6AXuANlJyF7pvtcA0vFRyJEQFa7XkoUIgUyQWhE4Gc5CZE8a4qkbeRdMDmCCNIqHtI5LhZkzSGSyBvbeCZz0oq0FcN3KL1M-MvQ2l4sJ1mjtyIoIfghT_RcENVTfhs5UmfWeF3Hy_lunl8MS3gOi6healG8WlHFAwKXJvg1o-2dbVwZ9NWy5seJpd-Y0ppzUuDydRuCBKS8aXs7q-0XAYayTXRuct4XnkgMaCvJzy8ef9tfS5sXuoBtbz3tcoEn-kaFdYvJebPEUqDxoE";
  bool _isUploading = false;

  Uint8List? _pendingAvatarBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      // Read bytes directly (Cross-platform)
      final bytes = await image.readAsBytes();

      // Decode image
      final img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        // Resize to 128x128
        final img.Image resizedImage = img.copyResize(
          originalImage,
          width: 128,
          height: 128,
        );

        // Encode back to jpg
        final resizedBytes = img.encodeJpg(resizedImage, quality: 85);

        setState(() {
          _pendingAvatarBytes = resizedBytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    final data = await repo.getUserProfile();

    if (data != null) {
      setState(() {
        if (data['username'] != null) _nameController.text = data['username'];
        if (data['native_language'] != null) {
          _selectedNativeLang = data['native_language'];
        }
        if (data['target_language'] != null) {
          _selectedTargetLang = data['target_language'];
        }
        if (data['avatar_url'] != null) _avatarUrl = data['avatar_url'];
        _isLoadingData = false;
      });
    } else {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    final imageProvider = _pendingAvatarBytes != null
        ? MemoryImage(_pendingAvatarBytes!) as ImageProvider
        : NetworkImage(
            _avatarUrl ??
                "https://lh3.googleusercontent.com/aida-public/AB6AXuANlJyF7pvtcA0vFRyJEQFa7XkoUIgUyQWhE4Gc5CZE8a4qkbeRdMDmCCNIqHtI5LhZkzSGSyBvbeCZz0oq0FcN3KL1M-MvQ2l4sJ1mjtyIoIfghT_RcENVTfhs5UmfWeF3Hy_lunl8MS3gOi6healG8WlHFAwKXJvg1o-2dbVwZ9NWy5seJpd-Y0ppzUuDydRuCBKS8aXs7q-0XAYayTXRuct4XnkgMaCvJzy8ef9tfS5sXuoBtbz3tcoEn-kaFdYvJebPEUqDxoE",
          );

    return InteractionPanel(
      title: "edit",
      onClose: widget.onClose,
      isVisible: true,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _isUploading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryBrand,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name Field
                  _buildSectionLabel("Display Name"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBrand,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Native Language
                  _buildSectionLabel("I speak..."),
                  const SizedBox(height: 8),
                  _buildLanguageTile(
                    context,
                    label: "Native Language",
                    selectedCode: _selectedNativeLang,
                    options: LanguageConstants.nativeLanguages,
                    onChanged: (code) {
                      setState(() => _selectedNativeLang = code);
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Target Language
                  _buildSectionLabel("I'm learning..."),
                  const SizedBox(height: 8),
                  _buildLanguageTile(
                    context,
                    label: "Target Language",
                    selectedCode: _selectedTargetLang,
                    options: LanguageConstants.targetLanguages,
                    onChanged: (code) {
                      setState(() => _selectedTargetLang = code);
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),

          // Save Button (Fixed at bottom)
          Padding(
            padding: const EdgeInsets.all(24),
            child: PandaButton(
              text: _isUploading ? "Uploading..." : "Save Changes",
              disabled: _isUploading,
              onPressed: () async {
                final repo = ref.read(profileRepositoryProvider);

                String? newAvatarUrl = _avatarUrl;

                // Upload avatar if changed
                if (_pendingAvatarBytes != null) {
                  if (mounted) setState(() => _isUploading = true);
                  newAvatarUrl = await repo.uploadAvatarBytes(
                    _pendingAvatarBytes!,
                    'jpg',
                  );
                  if (mounted) setState(() => _isUploading = false);

                  if (newAvatarUrl == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to upload avatar"),
                        ),
                      );
                      return;
                    }
                  }
                }

                await repo.updateProfileData(
                  username: _nameController.text,
                  nativeLanguage: _selectedNativeLang,
                  targetLanguage: _selectedTargetLang,
                  avatarUrl: newAvatarUrl,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Updated!")),
                  );
                }
              },
              icon: Icons.check_circle_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String label,
    required String selectedCode,
    required List<LanguageOption> options,
    required ValueChanged<String> onChanged,
  }) {
    // Find selected option
    final selectedOption = options.firstWhere(
      (opt) => opt.code == selectedCode,
      orElse: () => options.first,
    );

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => InteractionPanel(
            title: "Select $label",
            onClose: () => Navigator.pop(context),
            isVisible: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LanguageSelectorWidget(
                languages: options,
                selectedLanguageCode: selectedCode,
                onSelected: onChanged,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[100]!, width: 1),
                image: DecorationImage(
                  image: NetworkImage(selectedOption.flagUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedOption.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                  Text(
                    selectedOption.subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}
