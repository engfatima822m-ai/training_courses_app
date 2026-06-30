import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/services/api_service.dart';
import 'package:training_courses_app/services/course_registrants_pdf.dart';

class RegistrantsDialog {
  static const Color darkPurple = Color(0xFF2D033B);

  static Future<void> show({
    required BuildContext context,
    required Course course,
    required VoidCallback onRefresh,
    required void Function(String message) showMessage,
  }) async {
    _showLoading(context);

    try {
      final registrants = await ApiService.fetchCourseRegistrants(
        courseId: course.id,
      );

      if (!context.mounted) return;

      Navigator.pop(context);

      await showDialog(
        context: context,
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final dialogWidth = width < 600 ? width * 0.92 : 760.0;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'المسجلون في ${course.title}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: dialogWidth,
                child: registrants.isEmpty
                    ? const Text(
                        'لا يوجد مسجلون حالياً في هذه الدورة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _registrantsSummary(course, registrants.length),
                            const SizedBox(height: 14),
                            ...registrants.map(
                              (person) => _registrantCard(person),
                            ),
                          ],
                        ),
                      ),
              ),
              actionsAlignment: MainAxisAlignment.start,
              actions: [
                if (registrants.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      _printRegistrantsPdf(
                        context: context,
                        course: course,
                        registrants: registrants,
                        showMessage: showMessage,
                      );
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('طباعة كشف المشاركين'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onRefresh();
                  },
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);
      showMessage('فشل في جلب بيانات المسجلين');
    }
  }

  static void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            content: SizedBox(
              height: 90,
              child: Center(
                child: CircularProgressIndicator(color: darkPurple),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _printRegistrantsPdf({
    required BuildContext context,
    required Course course,
    required List<Map<String, dynamic>> registrants,
    required void Function(String message) showMessage,
  }) async {
    try {
      await Printing.layoutPdf(
        name: 'كشف المشاركين - ${course.title}',
        onLayout: (_) async {
          return CourseRegistrantsPdfService.generate(
            course: course,
            registrants: registrants,
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessage('تعذر إنشاء أو طباعة الكشف: $e');
    }
  }

  static Widget _registrantsSummary(Course course, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            course.title,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عدد المسجلين: $count من ${course.capacity} | المتبقي: ${course.remainingSeats}',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _registrantCard(Map<String, dynamic> person) {
    final name = person['employee_name']?.toString() ?? '';
    final employeeId = person['employee_id']?.toString() ?? '';
    final grade = person['grade']?.toString() ?? '';
    final workPlace = person['work_place']?.toString() ?? '';
    final phone = person['phone']?.toString() ?? '';
    final date = person['registration_date']?.toString() ??
        person['created_at']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            name.isEmpty ? 'اسم غير متوفر' : name,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _registrantInfo('الرقم الوظيفي / البصمة', employeeId),
          _registrantInfo('الدرجة الوظيفية', grade),
          _registrantInfo('مكان العمل / القسم', workPlace),
          _registrantInfo('رقم الهاتف', phone),
          _registrantInfo('تاريخ التسجيل', date),
        ],
      ),
    );
  }

  static Widget _registrantInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'غير محدد' : value,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
