import 'package:flutter/material.dart';
import 'package:training_courses_app/core/widgets/stat_card.dart';
import 'package:training_courses_app/models/course.dart';

class AdminHeader extends StatelessWidget {
  final String userName;
  final List<Course> courses;

  const AdminHeader({
    super.key,
    required this.userName,
    required this.courses,
  });

  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);

  @override
  Widget build(BuildContext context) {
    final totalRegistrations =
        courses.fold<int>(0, (sum, c) => sum + c.registeredCount);

    final openCourses = courses.where((c) => c.isRegistrationOpen).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [blackColor, darkPurple, blackColor],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'مرحباً، $userName',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لوحة شعبة التدريب لإدارة الدورات التدريبية',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 560
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;

              return Wrap(
                textDirection: TextDirection.rtl,
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      icon: Icons.school_rounded,
                      title: 'الدورات',
                      value: '${courses.length}',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      icon: Icons.groups_rounded,
                      title: 'المسجلين',
                      value: '$totalRegistrations',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: StatCard(
                      icon: Icons.check_circle_rounded,
                      title: 'المفتوحة',
                      value: '$openCourses',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
