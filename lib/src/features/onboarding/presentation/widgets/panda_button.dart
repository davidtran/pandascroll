import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
  final double? width;
  final Widget? leading;
  final Widget? trailing;
  final bool disabled;
  final Offset shadowOffset;

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
    this.width = double.infinity,
    this.leading,
    this.trailing,
    this.disabled = false,
    this.shadowOffset = const Offset(0, 4),
  });

  @override
  State<PandaButton> createState() => _PandaButtonState();
}

class _PandaButtonState extends State<PandaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.disabled
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.disabled
          ? null
          : () => setState(() => _isPressed = false),
      onTap: widget.disabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                color: widget.shadowColor ?? Colors.black.withValues(alpha: 1),
                offset: widget.shadowOffset,
                blurRadius: 0,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    (widget.leading != null ||
                        widget.trailing != null ||
                        widget.icon != null)
                    ? 32.0
                    : 0,
              ),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
            if (widget.leading != null)
              Align(alignment: Alignment.centerLeft, child: widget.leading!),
            if (widget.trailing != null)
              Align(alignment: Alignment.centerRight, child: widget.trailing!)
            else if (widget.icon != null)
              Align(
                alignment: Alignment.centerRight,
                child: Icon(widget.icon, color: widget.textColor, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}
