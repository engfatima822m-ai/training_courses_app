import 'package:flutter/material.dart';
import 'package:training_courses_app/core/theme/app_colors.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/courses_list_screen.dart';
import 'package:training_courses_app/screens/registration_request_preview_screen.dart';
import 'package:training_courses_app/services/api_service.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final Course course;
  final User user;

  const CourseRegistrationScreen({
    super.key,
    required this.course,
    required this.user,
  });

  @override
  State<CourseRegistrationScreen> createState() =>
      _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState
    extends State<CourseRegistrationScreen> {
  bool _isRegistered = false;
  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bool success = await ApiService.registerToCourse(
        employeeId: widget.user.employeeId,
        courseId: widget.course.id,
      );

      setState(() {
        _isLoading = false;
        _isRegistered = success;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر التسجيل أو أنك مسجل مسبقًا في هذه الدورة'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء التسجيل: $e'),
        ),
      );
    }
  }

  void _openRequestPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationRequestPreviewScreen(
          user: widget.user,
          course: widget.course,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد التسجيل'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isRegistered
              ? _buildSuccessView()
              : _buildConfirmationView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'تم التسجيل بنجاح!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  'تم تسجيلك في دورة:',
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.18),
              ),
            ),
            child: const Text(
              'تم تسجيلك في النظام، ويمكنك الآن فتح طلب PDF الجاهز لطباعته أو مشاركته مع قسم الموارد البشرية / شعبة التدريب والتطوير.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openRequestPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'فتح طلب التسجيل PDF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursesListScreen(user: widget.user),
                  ),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.home),
              label: const Text(
                'العودة للصفحة الرئيسية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline,
          size: 60,
          color: AppColors.darkBlue,
        ),
        const SizedBox(height: 20),
        const Text(
          'تأكيد التسجيل',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.course.title,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'بعد إتمام التسجيل بنجاح، سيظهر لك طلب جاهز بصيغة PDF.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'تأكيد التسجيل',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}