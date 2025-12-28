import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../../../core/theme/app_dimens.dart';

class InteractionPanel extends StatefulWidget {
  final VoidCallback onClose;
  final String title;
  final Widget child;
  final String? videoId;
  final bool isVisible; // Added isVisible property

  const InteractionPanel({
    super.key,
    required this.onClose,
    required this.title,
    required this.child,
    this.videoId,
    required this.isVisible,
    this.barrierDismissible = true,
  });

  final bool barrierDismissible;

  @override
  InteractionPanelWidget createState() => InteractionPanelWidget();
}

class InteractionPanelWidget extends State<InteractionPanel> {
  Key _contentKey = UniqueKey();

  void handleClose() {
    setState(() {
      _contentKey = UniqueKey();
    });
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.75;

    return Stack(
      children: [
        // Barrier
        if (widget.isVisible)
          Positioned.fill(
            child: PointerInterceptor(
              child: GestureDetector(
                onTap: widget.barrierDismissible ? handleClose : null,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black54),
              ),
            ),
          ),

        // Sliding Panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          bottom: widget.isVisible ? 0 : -panelHeight,
          height: panelHeight,
          child: PointerInterceptor(
            child: _buildPanelContent(), // Call the new method for content
          ),
        ),
      ],
    );
  }

  // Moved existing content logic to a new private method
  Widget _buildPanelContent() {
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
                handleClose();
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

          Expanded(key: _contentKey, child: widget.child),
        ],
      ),
    );
  }
}
