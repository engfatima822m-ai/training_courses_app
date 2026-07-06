import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/course_registration_screen.dart';
import 'package:training_courses_app/services/api_service.dart';
import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/core/widgets/common/app_page_header.dart';

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
  bool _isCheckingRegistration = false;
  bool _isWithdrawing = false;
  bool _isRegisteredFromApi = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  bool get _hasRealEmployeeId {
    return widget.user.employeeId.trim().isNotEmpty &&
        widget.user.employeeId != 'GUEST';
  }

  bool get _alreadyRegistered {
    return _isRegisteredFromApi;
  }

  bool get _canRegister {
    return !_alreadyRegistered && widget.course.isRegistrationOpen;
  }

  String get _disabledRegisterMessage {
    if (_alreadyRegistered) return '✔ أنت مسجل في هذه الدورة';
    if (widget.course.isFull) return 'اكتمل عدد المقاعد لهذه الدورة';
    if (widget.course.isRegistrationExpired) {
      return 'انتهت مدة التسجيل لهذه الدورة';
    }
    if (widget.course.isRegistrationNotStarted) return 'التسجيل لم يبدأ بعد';
    return 'التسجيل غير متاح حالياً';
  }

  Future<void> _checkRegistrationStatus() async {
    if (!_hasRealEmployeeId) return;

    setState(() => _isCheckingRegistration = true);

    try {
      final result = await ApiService.checkRegistration(
        employeeId: widget.user.employeeId,
        courseId: widget.course.id,
      );

      if (!mounted) return;

      setState(() {
        _isRegisteredFromApi = result['is_registered'] == true;
        _isCheckingRegistration = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCheckingRegistration = false);
    }
  }

  Future<void> _showConfirmationDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
          ),
          title: const Text(
            'تأكيد التسجيل',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.darkPurple,
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
                backgroundColor: AppColors.darkPurple,
                foregroundColor: AppColors.white,
              ),
              child: const Text('نعم، متابعة'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseRegistrationScreen(
            course: widget.course,
            user: widget.user,
          ),
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _showWithdrawDialog() async {
    if (!_hasRealEmployeeId) {
      _showMessage('لا يمكن الانسحاب لأن بيانات الموظف غير معروفة', true);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
          ),
          title: const Text(
            'تأكيد الانسحاب',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل تريد الانسحاب من دورة:\n\n${widget.course.title}؟',
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
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
              ),
              child: const Text('نعم، انسحاب'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _withdrawFromCourse();
    }
  }

  Future<void> _withdrawFromCourse() async {
    setState(() => _isWithdrawing = true);

    try {
      final result = await ApiService.withdrawFromCourse(
        employeeId: widget.user.employeeId,
        courseId: widget.course.id,
      );

      final success = result['success'] == true;
      final message =
          result['message']?.toString() ?? 'تعذر إكمال عملية الانسحاب';

      if (!mounted) return;

      setState(() {
        _isWithdrawing = false;
        if (success) {
          _isRegisteredFromApi = false;
        }
      });

      _showMessage(message, !success);

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isWithdrawing = false);
      _showMessage('حدث خطأ أثناء الانسحاب: $e', true);
    }
  }

  void _showMessage(String text, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.right),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Color _statusColor() {
    if (widget.course.isFull) return AppColors.danger;
    if (widget.course.isRegistrationExpired) return Colors.grey.shade700;
    if (widget.course.isEndingSoon) return Colors.orange.shade800;
    if (widget.course.isRegistrationOpen) return AppColors.success;
    return AppColors.deepPurple;
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.darkPurple,
          foregroundColor: AppColors.white,
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
              AppPageHeader(
                title: widget.course.title,
                subtitle: 'الاطلاع على تفاصيل الدورة التدريبية والتسجيل بها',
                icon: Icons.school_rounded,
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: AppSpacing.itemSpacing),
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
                      icon: Icons.play_circle_rounded,
                      title: 'بداية التسجيل',
                      value: _formatDate(widget.course.registrationStartDate),
                    ),
                    DetailItem(
                      icon: Icons.stop_circle_rounded,
                      title: 'نهاية التسجيل',
                      value: _formatDate(widget.course.registrationEndDate),
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
                      value: '${widget.course.remainingSeats}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildDescriptionCard(),
                    const SizedBox(height: AppSpacing.lg),
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


  Widget _buildStatusCard() {
    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(_statusIcon(), color: color, size: 26),
          const SizedBox(width: AppSpacing.sm),
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
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppSpacing.cardPadding),
        border: Border.all(
          color: AppColors.darkPurple.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.description_rounded, color: AppColors.darkPurple),
              SizedBox(width: AppSpacing.sm),
              Text(
                'وصف الدورة',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.itemSpacing),
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
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isCheckingRegistration) {
      return const SizedBox(
        height: 58,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.deepPurple),
        ),
      );
    }

    if (_alreadyRegistered) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _isWithdrawing ? null : _showWithdrawDialog,
          icon: _isWithdrawing
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(_isWithdrawing ? 'جاري الانسحاب...' : 'الانسحاب من الدورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (_canRegister) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _showConfirmationDialog,
          icon: const Icon(Icons.how_to_reg_rounded),
          label: const Text('التسجيل في هذه الدورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPurple,
            foregroundColor: AppColors.white,
            elevation: 5,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
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
        color: Colors.grey.shade600,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Text(
        _disabledRegisterMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          border: Border.all(
            color: AppColors.darkPurple.withOpacity(0.10),
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
              padding: const EdgeInsets.all(AppSpacing.itemSpacing),
              decoration: BoxDecoration(
                color: AppColors.darkPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
              ),
              child: Icon(
                icon,
                color: AppColors.deepPurple,
              ),
            ),
            const SizedBox(width: AppSpacing.itemSpacing),
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value.isEmpty ? 'غير محدد' : value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
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