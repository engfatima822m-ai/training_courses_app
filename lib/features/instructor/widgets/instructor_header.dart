import 'package:flutter/material.dart';
import 'package:training_courses_app/models/user.dart';

class InstructorHeader extends StatelessWidget {
  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  final User user;
  final int totalCourses;
  final int totalRegistered;
  final int upcomingCourses;

  const InstructorHeader({
    super.key,
    required this.user,
    required this.totalCourses,
    required this.totalRegistered,
    required this.upcomingCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            deepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.record_voice_over_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'مرحباً ${user.fullName}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لوحة المحاضر لمتابعة الدورات التدريبية المكلف بها',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 26),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: _statCard(
                  Icons.menu_book_rounded,
                  totalCourses.toString(),
                  'الدورات',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statCard(
                  Icons.groups_rounded,
                  totalRegistered.toString(),
                  'المسجلين',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statCard(
                  Icons.event_available_rounded,
                  upcomingCourses.toString(),
                  'القادمة',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}