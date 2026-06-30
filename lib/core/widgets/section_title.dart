import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final double topPadding;
  final double bottomPadding;

  const SectionTitle({
    super.key,
    required this.text,
    required this.icon,
    this.color = const Color(0xFF2D033B),
    this.topPadding = 24,
    this.bottomPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
