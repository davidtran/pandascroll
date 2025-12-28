import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';

class SelectableOptionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectableOptionCard> createState() => _SelectableOptionCardState();
}

class _SelectableOptionCardState extends State<SelectableOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color primary = AppColors.bambooGreen;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          bottom: widget.isSelected ? 12 : 12, // Maintain standard spacing
          top: _isPressed ? 4 : 0,
        ),
        // To offset the layout shift from margin top, we might want a transform instead,
        // but margin is safer for list correctness if we don't mind the slight shift of following items.
        // Actually, for a list item, `transform` is better to avoid janking other items.
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: widget.isSelected
              ? const Border(
                  top: BorderSide(color: Color(0xFF5ED176), width: 2.0),
                  left: BorderSide(color: Color(0xFF5ED176), width: 2.0),
                  right: BorderSide(color: Color(0xFF5ED176), width: 2.0),
                  // MUCH THICKER for the Bottom side
                  bottom: BorderSide(color: Color(0xFF5ED176), width: 6.0),
                )
              : const Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 210, 210, 210),
                    width: 2.0,
                  ),
                  left: BorderSide(
                    color: Color.fromARGB(255, 210, 210, 210),
                    width: 2.0,
                  ),
                  right: BorderSide(
                    color: Color.fromARGB(255, 210, 210, 210),
                    width: 2.0,
                  ),
                  // MUCH THICKER for the Bottom side
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 210, 210, 210),
                    width: 6.0,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Image/Flag
            if (widget.imageUrl != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[100]!, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title.toLowerCase(),
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!.toLowerCase(),
                      style: AppTheme.lightTheme.textTheme.bodyLarge,
                    ),
                ],
              ),
            ),

            // Check Circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.isSelected ? primary : Colors.transparent,
                shape: BoxShape.circle,
                border: widget.isSelected
                    ? null
                    : Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: widget.isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
