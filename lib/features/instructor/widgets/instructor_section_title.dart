import 'package:flutter/material.dart';

class InstructorSectionTitle extends StatelessWidget {
  static const Color darkPurple = Color(0xFF2D033B);

  final String title;
  final IconData icon;

  const InstructorSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          color: darkPurple,
          size: 25,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}