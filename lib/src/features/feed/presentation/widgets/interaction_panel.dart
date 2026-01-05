import 'package:flutter/material.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/with_interceptor.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
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
    this.onBarrierTap,
  });

  final bool barrierDismissible;
  final VoidCallback? onBarrierTap;

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
    final maxPanelHeight = screenHeight * 0.8;

    return RepaintBoundary(
      child: Stack(
        children: [
          // Barrier
          if (widget.isVisible)
            Positioned.fill(
              child: withInterceptor(
                GestureDetector(
                  onTap:
                      widget.onBarrierTap ??
                      (widget.barrierDismissible ? handleClose : null),
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),
            ),

          // Sliding Panel
          AnimatedSlide(
            offset: widget.isVisible ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildPanelContent(maxPanelHeight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent(double maxHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(
          top: BorderSide(color: AppColors.pandaBlack, width: 3),
          left: BorderSide(color: AppColors.pandaBlack, width: 3),
          right: BorderSide(color: AppColors.pandaBlack, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pandaBlack.withOpacity(0.4),
            offset: const Offset(0, -4),
            blurRadius: 0, // Hard shadow for depth but upwards
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.pandaBlack.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: AppColors.pandaBlack.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Flexible(key: _contentKey, child: widget.child),
        ],
      ),
    );
  }
}
