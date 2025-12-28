import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../controllers/comments_controller.dart';
import '../../domain/models/comment_model.dart';
import '../../../../core/services/service_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class CommentsPanel extends ConsumerStatefulWidget {
  final String videoId;

  const CommentsPanel({super.key, required this.videoId});

  @override
  ConsumerState<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends ConsumerState<CommentsPanel> {
  final TextEditingController _commentController = TextEditingController();
  // Map to store translated text for each comment ID
  final Map<String, String> _translations = {};
  // Map to store translation loading state
  final Map<String, bool> _isTranslating = {};

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    FocusScope.of(context).unfocus();

    // 0. Check Length (Min 2 chars)
    if (content.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Comment must be at least 2 characters long."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 1. Check Language
    final userProfile = ref.read(userLanguageProfileProvider).value;
    final targetLanguage = userProfile?.language;

    if (targetLanguage != null) {
      final detectionService = ref.read(languageDetectionServiceProvider);
      final detectedLang = await detectionService.identifyLanguage(content);

      if (detectedLang != 'und' && detectedLang != targetLanguage) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Please comment in ${targetLanguage == 'zh' ? 'Chinese' : targetLanguage}",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // 2. Moderate Content
    final moderationService = ref.read(contentModerationServiceProvider);
    final isSafe = await moderationService.moderate(content);
    if (!isSafe) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your comment contains inappropriate content."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _commentController.clear(); // Clear immediately for UX (only if successful)

    await ref
        .read(commentsProvider(widget.videoId).notifier)
        .addComment(content);
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.videoId));

    return Column(
      children: [
        // Header Stats (from design)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Comments",
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryBrand.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      "${commentsAsync.value?.length ?? 0}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ),
                ],
              ),
              // Close button is handled by parent panel usually, but we can have one locally if needed
              // The parent InteractionPanel has the drag handle.
            ],
          ),
        ),

        const Divider(height: 1, color: Colors.grey),

        // List
        Expanded(
          child: commentsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrand),
            ),
            error: (e, _) => Center(
              child: Text(
                "Error: $e",
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return _buildCommentItem(comments[index]);
                },
              );
            },
          ),
        ),

        // Input Area
        _buildInputArea(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.comments,
                size: 48,
                color: AppColors.primaryBrand,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No comments yet!",
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.pandaBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Be the first to share your thoughts. It's a great way to improve your language skills! 🐼",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: comment.userAvatarUrl != null
                ? NetworkImage(comment.userAvatarUrl!)
                : null,
            child: comment.userAvatarUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name & Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.username ?? "User",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                  Text(
                    timeago.format(comment.createdAt, locale: 'en_short'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pandaBlack,
                  height: 1.3,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),

              // Actions (Translate)
              if (!_translations.containsKey(comment.id))
                Row(
                  children: [
                    _buildMiniButton(
                      icon: Icons.translate,
                      label: "Translate",
                      isLoading: _isTranslating[comment.id] ?? false,
                      onTap: () async {
                        if (_translations.containsKey(comment.id)) {
                          // Toggle or just keep showing? Let's just return for now or toggle logic could be added
                          return;
                        }

                        setState(() {
                          _isTranslating[comment.id] = true;
                        });

                        final translationService = ref.read(
                          translationServiceProvider,
                        );
                        final result = await translationService.translate(
                          type: 'comment',
                          id: comment.id,
                        );

                        if (mounted) {
                          setState(() {
                            _isTranslating[comment.id] = false;
                            if (result != null) {
                              _translations[comment.id] = result;
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              if (_translations.containsKey(comment.id)) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _translations[comment.id]!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Like Button (Visual) - REMOVED
      ],
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.grey[100]!, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBrand,
                ),
              )
            else
              Icon(icon, size: 14, color: AppColors.primaryBrand),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pandaBlack,
                ),
                decoration: const InputDecoration(
                  hintText: "Say something... (Chinese Only)",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button
          InkWell(
            onTap: _submitComment,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16),

                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFb45309), // Darker orange
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
