import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class PandaButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double height;
  final double fontSize;
  final Color? shadowColor;

  const PandaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor =
        AppColors.bambooGreen, // Default per previous AdventureButton
    this.textColor = AppColors.pandaBlack,
    this.borderColor = AppColors.pandaBlack,
    this.height = 64,
    this.fontSize = 20,
    this.shadowColor,
  });

  @override
  State<PandaButton> createState() => _PandaButtonState();
}

class _PandaButtonState extends State<PandaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        width: double.infinity,
        margin: EdgeInsets.only(
          top: _isPressed ? 4 : 0,
          bottom: _isPressed ? 0 : 4,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: widget.borderColor, width: 2),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color:
                    widget.shadowColor ??
                    Colors.black.withValues(
                      alpha: 1,
                    ), // Solid black shadow for cartoon look?
                // Wait, AdventureButton had withValues(alpha: 0.15) before.
                // But user asked for "border should be black" -> cartoon style?
                // Usually cartoon buttons have solid black shadows or opaque shadows.
                // I will use 100% black shadow if they asked for black border.
                // Or maybe just keeping the shadow as distinct.
                // Let's stick to the 3D effect shadow.
                // Using 1.0 alpha looks very "brutalist"/cartoon.
                // I'll stick to logic: border is black, text is black.
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka',
              ),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(widget.icon, color: widget.textColor, size: 28),
            ],
          ],
        ),
      ),
    );
  }
}
