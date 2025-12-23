import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimens.dart';

class InteractionPanel extends StatelessWidget {
  final VoidCallback onClose;
  final String title;
  final Widget child;

  const InteractionPanel({
    super.key,
    required this.onClose,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar with Swipe to Close
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300) {
                onClose();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // Header removed (moved to children)
          // Padding(
          //   padding: const EdgeInsets.all(AppSpacing.md),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         title,
          //         style: Theme.of(
          //           context,
          //         ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.close_rounded),
          //         onPressed: onClose,
          //       ),
          //     ],
          //   ),
          // ),
          // const Divider(height: 1),

          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
