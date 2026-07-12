import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:training_courses_app/features/instructor/services/course_material_service.dart';

import '../services/api_service.dart';

class InstructorCourseDetailsScreen extends StatefulWidget {
  final dynamic course;

  const InstructorCourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<InstructorCourseDetailsScreen> createState() =>
      _InstructorCourseDetailsScreenState();
}

class _InstructorCourseDetailsScreenState
    extends State<InstructorCourseDetailsScreen> {
  bool isLoading = true;
  String? errorMessage;
  List registrations = [];

  @override
  void initState() {
    super.initState();
    fetchRegistrations();
  }

  Future<void> fetchRegistrations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/get_course_registrations.php'
        '?course_id=${widget.course.id}',
      );

      final response = await http.get(url);

      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          registrations = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          registrations = [];
          errorMessage =
              data['message']?.toString() ?? 'حدث خطأ أثناء الجلب';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        registrations = [];
        errorMessage = 'تعذر الاتصال بالخادم';
        isLoading = false;
      });
    }
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'تقرير المسجلين في الدورة',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'اسم الدورة: ${widget.course.title}',
            ),
            pw.Text(
              'التاريخ: ${widget.course.date}',
            ),
            pw.Text(
              'الوقت: ${widget.course.time}',
            ),
            pw.Text(
              'المكان: ${widget.course.location}',
            ),
            pw.Text(
              'عدد المسجلين: ${registrations.length}',
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: [
                'ت',
                'اسم الموظف',
                'الرقم الوظيفي',
                'الدرجة',
                'مكان العمل',
                'الهاتف',
              ],
              data: registrations.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;

                return [
                  index.toString(),
                  item['employee_name']?.toString() ?? '',
                  item['employee_id']?.toString() ?? '',
                  item['grade']?.toString() ?? '',
                  item['workPlace']?.toString() ?? '',
                  item['phone']?.toString() ?? '',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printRegistrations() async {
    if (registrations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا توجد أسماء للطباعة حالياً',
            textAlign: TextAlign.right,
          ),
        ),
      );

      return;
    }

    await Printing.layoutPdf(
      onLayout: (format) async => _buildPdf(),
    );
  }

  Future<void> uploadMaterialPdf() async {
    try {
      final result =
          await CourseMaterialService.uploadCourseMaterial(
        courseId: widget.course.id.toString(),
        title: widget.course.title.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'تمت العملية',
            textAlign: TextAlign.right,
          ),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء رفع الملف',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F2FA),

        // شريط عنوان الصفحة
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'تفاصيل الدورة',
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF2D033B),
          foregroundColor: Colors.white,

          // السهم وزر التحديث يظهران في أعلى اليسار
          actions: [
            IconButton(
              tooltip: 'تحديث البيانات',
              onPressed: fetchRegistrations,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
            IconButton(
              tooltip: 'رجوع',
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: fetchRegistrations,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _courseDetailsCard(course),
              const SizedBox(height: 16),
              _actionsRow(),
              const SizedBox(height: 20),
              _registrationsTitle(),
              const SizedBox(height: 12),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage != null)
                _messageCard(
                  icon: Icons.error_outline,
                  message: errorMessage!,
                )
              else if (registrations.isEmpty)
                _messageCard(
                  icon: Icons.info_outline,
                  message:
                      'لا يوجد موظفون مسجلون في هذه الدورة حالياً',
                )
              else
                _registrationsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseDetailsCard(dynamic course) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              course.title.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D033B),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(
              'التاريخ',
              course.date.toString(),
            ),
            _infoRow(
              'الوقت',
              course.time.toString(),
            ),
            _infoRow(
              'المدة',
              course.duration.toString(),
            ),
            _infoRow(
              'المكان',
              course.location.toString(),
            ),
            _infoRow(
              'الفئة المشمولة',
              course.grade.toString(),
            ),
            _infoRow(
              'السعة',
              course.capacity.toString(),
            ),
            _infoRow(
              'عدد المسجلين',
              registrations.length.toString(),
            ),
            const SizedBox(height: 12),
            const Text(
              'وصف الدورة:',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              course.description.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: fetchRegistrations,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'تحديث',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B0082),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: printRegistrations,
                icon: const Icon(
                  Icons.print,
                ),
                label: const Text(
                  'طباعة الأسماء',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: uploadMaterialPdf,
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
            ),
            label: const Text(
              'رفع مادة الدورة PDF',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D033B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _registrationsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'العدد: ${registrations.length}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B0082),
          ),
        ),
        const Text(
          'الموظفون المسجلون',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D033B),
          ),
        ),
      ],
    );
  }

  Widget _registrationsList() {
    return Column(
      children: registrations.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE8DDF5),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF2D033B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item['employee_name']?.toString() ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'الرقم الوظيفي: ${item['employee_id'] ?? ''}\n'
              'الدرجة: ${item['grade'] ?? ''}\n'
              'مكان العمل: ${item['workPlace'] ?? ''}\n'
              'الهاتف: ${item['phone'] ?? ''}',
              textAlign: TextAlign.right,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Text(
        '$title: $value',
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _messageCard({
    required IconData icon,
    required String message,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4B0082),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}