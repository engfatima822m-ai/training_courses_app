import 'package:flutter/material.dart';

class InstructorReportCard extends StatelessWidget {
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  final String title;
  final String value;
  final IconData icon;

  const InstructorReportCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFE7F7)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: deepPurple, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: deepPurple,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}