import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/course_registration_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;
  final User user;

  const CourseDetailsScreen({
    super.key,
    required this.course,
    required this.user,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  bool get _isGuestUser => widget.user.employeeId == 'GUEST';

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'تأكيد التسجيل',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من التسجيل في هذه الدورة؟\n\n'
            'بعد إتمام التسجيل بنجاح، ستظهر لك صيغة طلب جاهزة بصيغة PDF يمكنك طباعتها أو مشاركتها.',
            textAlign: TextAlign.right,
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('نعم'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseRegistrationScreen(
            course: widget.course,
            user: widget.user,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool alreadyRegistered =
        widget.course.registeredUsers.contains(widget.user.employeeId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F2FA),
        appBar: AppBar(
          backgroundColor: blackColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'تفاصيل الدورة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    DetailItem(
                      icon: Icons.person_rounded,
                      title: 'المحاضر',
                      value: widget.course.instructor,
                    ),
                    DetailItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'تاريخ الدورة',
                      value: _formatDate(widget.course.date),
                    ),
                    DetailItem(
                      icon: Icons.access_time_rounded,
                      title: 'الوقت',
                      value: widget.course.time,
                    ),
                    DetailItem(
                      icon: Icons.timer_outlined,
                      title: 'مدة الدورة',
                      value: widget.course.duration.isEmpty
                          ? 'غير محددة'
                          : widget.course.duration,
                    ),
                    DetailItem(
                      icon: Icons.location_on_rounded,
                      title: 'المكان',
                      value: widget.course.location,
                    ),
                    DetailItem(
                      icon: Icons.groups_rounded,
                      title: 'عدد المسجلين',
                      value: '${widget.course.registeredCount} موظف',
                    ),
                    const SizedBox(height: 8),
                    _buildDescriptionCard(),
                    const SizedBox(height: 26),
                    _buildActionButton(alreadyRegistered),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            blackColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.school_rounded,
              size: 58,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.course.title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الاطلاع على تفاصيل الدورة التدريبية',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: darkPurple.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.description_rounded, color: darkPurple),
              SizedBox(width: 8),
              Text(
                'وصف الدورة',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.course.description.isEmpty
                  ? 'لا يوجد وصف مضاف لهذه الدورة حالياً.'
                  : widget.course.description,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool alreadyRegistered) {
    if (_isGuestUser) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: darkPurple.withOpacity(0.12),
          ),
        ),
        child: const Text(
          'هذه الصفحة مخصصة لعرض تفاصيل الدورة فقط. سيتم إضافة آلية طلب التسجيل لاحقاً من خلال شعبة التدريب.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: alreadyRegistered
          ? Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '✔ أنت مسجل في هذه الدورة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: () => _showConfirmationDialog(context),
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('التسجيل في الدورة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple,
                foregroundColor: Colors.white,
                elevation: 5,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: darkPurple.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: darkPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: deepPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isEmpty ? 'غير محدد' : value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}