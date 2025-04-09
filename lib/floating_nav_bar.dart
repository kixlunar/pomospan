import 'package:flutter/material.dart';
// this file is named as such since there will be an implementation of a floating nav bar here at some
// point in the future

class AdaptiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? minSize; // Minimum icon size
  final double? maxSize; // Maximum icon size
  final Color color;
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.color,
    this.minSize = 8.0,
    this.maxSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate icon size as a fraction of the button height, clamped between min and max
        double iconSize = constraints.maxHeight * 1; // 90% of height
        iconSize = iconSize.clamp(minSize!, maxSize!);

        return IconButton(
          style: TextButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(icon),
          iconSize: iconSize,
          onPressed: onPressed,
          //constraints: const BoxConstraints(), // Remove default min constraints
          padding: EdgeInsets.zero, // Remove default padding
          splashColor: Colors.transparent,
        );
      },
    );
  }
}
