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
  static const Color lightBackground = Color(0xFFF6F2FA);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  bool get _alreadyRegistered {
    return widget.course.registeredUsers.contains(widget.user.employeeId) &&
        widget.user.employeeId != 'GUEST';
  }

  bool get _canRegister {
    return !_alreadyRegistered &&
        widget.course.isRegistrationOpen &&
        !widget.course.isFull &&
        !widget.course.isRegistrationExpired;
  }

  String get _disabledRegisterMessage {
    if (_alreadyRegistered) {
      return '✔ أنت مسجل في هذه الدورة';
    }

    if (widget.course.isFull) {
      return 'اكتمل عدد المقاعد لهذه الدورة';
    }

    if (widget.course.isRegistrationExpired) {
      return 'انتهت مدة التسجيل لهذه الدورة';
    }

    return 'التسجيل غير متاح حالياً';
  }

  Future<void> _showConfirmationDialog() async {
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
          content: Text(
            'هل تريد التسجيل في دورة:\n\n'
            '${widget.course.title}\n\n'
            'بعد الضغط على نعم سيتم نقلك إلى صفحة إدخال معلومات الموظف.',
            textAlign: TextAlign.right,
            style: const TextStyle(height: 1.6),
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
              child: const Text('نعم، متابعة'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
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

  Color _statusColor() {
    if (widget.course.isFull) return Colors.red;
    if (widget.course.isRegistrationExpired) return Colors.grey.shade700;
    if (widget.course.isEndingSoon) return Colors.orange.shade800;
    if (widget.course.isRegistrationOpen) return Colors.green.shade700;
    return deepPurple;
  }

  IconData _statusIcon() {
    if (widget.course.isFull) return Icons.event_busy_rounded;
    if (widget.course.isRegistrationExpired) return Icons.lock_clock_rounded;
    if (widget.course.isEndingSoon) return Icons.warning_amber_rounded;
    if (widget.course.isRegistrationOpen) return Icons.check_circle_rounded;
    return Icons.info_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightBackground,
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
                    _buildStatusCard(),
                    const SizedBox(height: 14),
                    DetailItem(
                      icon: Icons.person_rounded,
                      title: 'المحاضر',
                      value: widget.course.instructorsText,
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
                      icon: Icons.badge_rounded,
                      title: 'الدرجة المستهدفة',
                      value: widget.course.grade,
                    ),
                    DetailItem(
                      icon: Icons.event_seat_rounded,
                      title: 'عدد المقاعد',
                      value: '${widget.course.capacity}',
                    ),
                    DetailItem(
                      icon: Icons.groups_rounded,
                      title: 'عدد المسجلين',
                      value: '${widget.course.registeredCount} موظف',
                    ),
                    DetailItem(
                      icon: Icons.chair_alt_rounded,
                      title: 'المقاعد المتبقية',
                      value:
                          '${widget.course.remainingSeats < 0 ? 0 : widget.course.remainingSeats}',
                    ),
                    const SizedBox(height: 8),
                    _buildDescriptionCard(),
                    const SizedBox(height: 26),
                    _buildActionButton(),
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
            'الاطلاع على تفاصيل الدورة التدريبية والتسجيل بها',
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

  Widget _buildStatusCard() {
    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(_statusIcon(), color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.course.registrationStatusText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildActionButton() {
    if (_canRegister) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _showConfirmationDialog,
          icon: const Icon(Icons.how_to_reg_rounded),
          label: const Text('التسجيل في هذه الدورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPurple,
            foregroundColor: Colors.white,
            elevation: 5,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            _alreadyRegistered ? Colors.green.shade600 : Colors.grey.shade600,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _disabledRegisterMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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