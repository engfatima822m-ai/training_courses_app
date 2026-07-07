import 'package:flutter/material.dart';
import 'package:training_courses_app/features/instructor/instructor_course.dart';
import 'package:training_courses_app/screens/instructor_course_details_screen.dart';

class InstructorCourseCard extends StatelessWidget {
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color selectedBg = Color(0xFFEDE3F8);

  final InstructorCourse course;
  final bool showRegisteredFocus;

  const InstructorCourseCard({
    super.key,
    required this.course,
    this.showRegisteredFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFE7F7)),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selectedBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded, color: deepPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  course.title,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 18,
                    color: darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selectedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${course.registeredCount} مسجل',
                  style: const TextStyle(
                    color: deepPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (showRegisteredFocus)
            _infoLine('عدد المسجلين', course.registeredCount.toString()),
          _infoLine('تاريخ الدورة', course.date),
          _infoLine('وقت الدورة', course.time),
          _infoLine('مكان الدورة', course.location),
          _infoLine('المدة', course.duration),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstructorCourseDetailsScreen(
                        course: course,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('عرض التفاصيل', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Text(
      '$label: $value',
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontSize: 13, height: 1.6),
    );
  }
}