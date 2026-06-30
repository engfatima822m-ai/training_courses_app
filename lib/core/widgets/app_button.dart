import 'package:flutter/material.dart';

enum AppButtonType {
  filled,
  outlined,
  danger,
}

class AppButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final AppButtonType type;
  final double height;
  final double borderRadius;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.height = 50,
    this.borderRadius = 16,
    this.width,
  });

  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  bool get _isFilled => type == AppButtonType.filled;
  bool get _isDanger => type == AppButtonType.danger;

  @override
  Widget build(BuildContext context) {
    final filledColor = _isDanger ? Colors.red : darkPurple;
    final outlinedColor = _isDanger ? Colors.red : deepPurple;

    final Widget button = _isFilled || _isDanger
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: filledColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: outlinedColor,
              side: BorderSide(color: outlinedColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          );

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}
