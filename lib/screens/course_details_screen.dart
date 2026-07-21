import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/core/widgets/common/app_page_header.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/course_registration_screen.dart';
import 'package:training_courses_app/services/api_service.dart';
import 'package:training_courses_app/services/course_material_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;
  final User user;

  const CourseDetailsScreen({
    super.key,
    required this.course,
    required this.user,
  });

  @override
  State<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState
    extends State<CourseDetailsScreen> {
  bool _isCheckingRegistration = false;
  bool _isWithdrawing = false;
  bool _isRegisteredFromApi = false;

  bool _isLoadingMaterials = true;
  String? _materialsError;
  List<Map<String, dynamic>> _courseMaterials = [];

  @override
  void initState() {
    super.initState();

    _checkRegistrationStatus();
    _loadCourseMaterials();
  }

  Future<void> _loadCourseMaterials() async {
    if (mounted) {
      setState(() {
        _isLoadingMaterials = true;
        _materialsError = null;
      });
    }

    try {
      final materials =
          await CourseMaterialService.getCourseMaterials(
        courseId: widget.course.id,
      );

      if (!mounted) return;

      setState(() {
        _courseMaterials = materials;
        _isLoadingMaterials = false;
        _materialsError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _courseMaterials = [];
        _isLoadingMaterials = false;
        _materialsError = 'تعذر جلب مواد الدورة';
      });
    }
  }

  Future<void> _openMaterial(
    Map<String, dynamic> material,
  ) async {
    final filePath =
        material['file_path']?.toString().trim() ?? '';

    if (filePath.isEmpty) {
      _showMessage(
        'مسار ملف المادة غير موجود',
        true,
      );
      return;
    }

    final fileUrl = _buildMaterialUrl(filePath);
    final uri = Uri.tryParse(fileUrl);

    if (uri == null) {
      _showMessage(
        'رابط الملف غير صحيح',
        true,
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage(
          'تعذر فتح ملف المادة',
          true,
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'حدث خطأ أثناء فتح الملف',
        true,
      );
    }
  }

  String _buildMaterialUrl(String filePath) {
    if (filePath.startsWith('http://') ||
        filePath.startsWith('https://')) {
      return filePath;
    }

    final baseUrl = ApiService.baseUrl.endsWith('/')
        ? ApiService.baseUrl.substring(
            0,
            ApiService.baseUrl.length - 1,
          )
        : ApiService.baseUrl;

    final cleanPath = filePath.startsWith('/')
        ? filePath.substring(1)
        : filePath;

    return '$baseUrl/$cleanPath';
  }

  String _formatUploadedDate(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return 'تاريخ الرفع غير محدد';
    }

    final date = DateTime.tryParse(text);

    if (date == null) {
      return text;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$year/$month/$day';
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
    return !_alreadyRegistered &&
        widget.course.isRegistrationOpen;
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

    if (widget.course.isRegistrationNotStarted) {
      return 'التسجيل لم يبدأ بعد';
    }

    return 'التسجيل غير متاح حالياً';
  }

  Future<void> _checkRegistrationStatus() async {
    if (!_hasRealEmployeeId) return;

    setState(() {
      _isCheckingRegistration = true;
    });

    try {
      final result = await ApiService.checkRegistration(
        employeeId: widget.user.employeeId,
        courseId: widget.course.id,
      );

      if (!mounted) return;

      setState(() {
        _isRegisteredFromApi =
            result['is_registered'] == true;

        _isCheckingRegistration = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isCheckingRegistration = false;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.largeRadius,
            ),
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
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
          builder: (context) =>
              CourseRegistrationScreen(
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
      _showMessage(
        'لا يمكن الانسحاب لأن بيانات الموظف غير معروفة',
        true,
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.largeRadius,
            ),
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
            'هل تريد الانسحاب من دورة:\n\n'
            '${widget.course.title}؟',
            textAlign: TextAlign.right,
            style: const TextStyle(height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
    setState(() {
      _isWithdrawing = true;
    });

    try {
      final result =
          await ApiService.withdrawFromCourse(
        employeeId: widget.user.employeeId,
        courseId: widget.course.id,
      );

      final success = result['success'] == true;

      final message =
          result['message']?.toString() ??
          'تعذر إكمال عملية الانسحاب';

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

      setState(() {
        _isWithdrawing = false;
      });

      _showMessage(
        'حدث خطأ أثناء الانسحاب: $e',
        true,
      );
    }
  }

  void _showMessage(
    String text,
    bool isError,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.right,
        ),
        backgroundColor: isError
            ? AppColors.danger
            : AppColors.success,
      ),
    );
  }

  Color _statusColor() {
    if (widget.course.isFull) {
      return AppColors.danger;
    }

    if (widget.course.isRegistrationExpired) {
      return Colors.grey.shade700;
    }

    if (widget.course.isEndingSoon) {
      return Colors.orange.shade800;
    }

    if (widget.course.isRegistrationOpen) {
      return AppColors.success;
    }

    return AppColors.deepPurple;
  }

  IconData _statusIcon() {
    if (widget.course.isFull) {
      return Icons.event_busy_rounded;
    }

    if (widget.course.isRegistrationExpired) {
      return Icons.lock_clock_rounded;
    }

    if (widget.course.isEndingSoon) {
      return Icons.warning_amber_rounded;
    }

    if (widget.course.isRegistrationOpen) {
      return Icons.check_circle_rounded;
    }

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppPageHeader(
                title: widget.course.title,
                subtitle:
                    'الاطلاع على تفاصيل الدورة التدريبية والتسجيل بها',
                icon: Icons.school_rounded,
              ),
              Padding(
                padding: const EdgeInsets.all(
                  AppSpacing.cardPadding,
                ),
                child: Column(
                  children: [
                    _buildStatusCard(),

                    const SizedBox(
                      height: AppSpacing.itemSpacing,
                    ),

                    DetailItem(
                      icon: Icons.person_rounded,
                      title: 'المحاضر',
                      value:
                          widget.course.instructorsText,
                    ),

                    DetailItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'تاريخ الدورة',
                      value: _formatDate(
                        widget.course.date,
                      ),
                    ),

                    DetailItem(
                      icon: Icons.play_circle_rounded,
                      title: 'بداية التسجيل',
                      value: _formatDate(
                        widget.course
                            .registrationStartDate,
                      ),
                    ),

                    DetailItem(
                      icon: Icons.stop_circle_rounded,
                      title: 'نهاية التسجيل',
                      value: _formatDate(
                        widget.course
                            .registrationEndDate,
                      ),
                    ),

                    DetailItem(
                      icon: Icons.access_time_rounded,
                      title: 'الوقت',
                      value: widget.course.time,
                    ),

                    DetailItem(
                      icon: Icons.timer_outlined,
                      title: 'مدة الدورة',
                      value:
                          widget.course.duration.isEmpty
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
                      value:
                          '${widget.course.capacity}',
                    ),

                    DetailItem(
                      icon: Icons.groups_rounded,
                      title: 'عدد المسجلين',
                      value:
                          '${widget.course.registeredCount} موظف',
                    ),

                    DetailItem(
                      icon: Icons.chair_alt_rounded,
                      title: 'المقاعد المتبقية',
                      value:
                          '${widget.course.remainingSeats}',
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    _buildDescriptionCard(),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    _buildMaterialsSection(),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

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
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            _statusIcon(),
            color: color,
            size: 26,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
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
      padding: const EdgeInsets.all(
        AppSpacing.cardPadding,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(
          AppSpacing.cardPadding,
        ),
        border: Border.all(
          color:
              AppColors.darkPurple.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.description_rounded,
                color: AppColors.darkPurple,
              ),
              SizedBox(
                width: AppSpacing.sm,
              ),
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
          const SizedBox(
            height: AppSpacing.itemSpacing,
          ),
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

  Widget _buildMaterialsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.cardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
        border: Border.all(
          color:
              AppColors.darkPurple.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.darkPurple,
              ),
              SizedBox(
                width: AppSpacing.sm,
              ),
              Text(
                'مواد الدورة',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPurple,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.itemSpacing,
          ),

          if (_isLoadingMaterials)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
              ),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.deepPurple,
                    ),
                    SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Text(
                      'جاري تحميل مواد الدورة...',
                      style: TextStyle(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_materialsError != null)
            _buildMaterialsError()
          else if (_courseMaterials.isEmpty)
            _buildEmptyMaterials()
          else
            ..._courseMaterials.map(
              (material) =>
                  _buildMaterialItem(material),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialsError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.07),
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.danger,
            size: 34,
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            _materialsError ??
                'تعذر جلب مواد الدورة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          OutlinedButton.icon(
            onPressed: _loadCourseMaterials,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'إعادة المحاولة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMaterials() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.darkPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.folder_off_rounded,
            color: AppColors.deepPurple,
            size: 38,
          ),
          SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            'لا توجد مواد مرفوعة لهذه الدورة حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(
    Map<String, dynamic> material,
  ) {
    final title =
        material['title']?.toString().trim() ?? '';

    final uploadedDate = _formatUploadedDate(
      material['uploaded_at'],
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.darkPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
        border: Border.all(
          color:
              AppColors.darkPurple.withOpacity(0.10),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(
              AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color:
                  AppColors.danger.withOpacity(0.10),
              borderRadius: BorderRadius.circular(
                AppSpacing.sm,
              ),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.danger,
              size: 28,
            ),
          ),

          const SizedBox(
            width: AppSpacing.itemSpacing,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty
                      ? 'مادة تدريبية'
                      : title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  'تاريخ الرفع: $uploadedDate',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          ElevatedButton.icon(
            onPressed: () {
              _openMaterial(material);
            },
            icon: const Icon(
              Icons.open_in_new_rounded,
              size: 18,
            ),
            label: const Text('فتح'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.darkPurple,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSpacing.sm,
                ),
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
          child: CircularProgressIndicator(
            color: AppColors.deepPurple,
          ),
        ),
      );
    }

    if (_alreadyRegistered) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _isWithdrawing
              ? null
              : _showWithdrawDialog,
          icon: _isWithdrawing
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child:
                      CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Icon(
                  Icons.logout_rounded,
                ),
          label: Text(
            _isWithdrawing
                ? 'جاري الانسحاب...'
                : 'الانسحاب من الدورة',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.borderRadius,
              ),
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
          icon: const Icon(
            Icons.how_to_reg_rounded,
          ),
          label: const Text(
            'التسجيل في هذه الدورة',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.darkPurple,
            foregroundColor: AppColors.white,
            elevation: 5,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.borderRadius,
              ),
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
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
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
        margin: const EdgeInsets.only(
          bottom: AppSpacing.itemSpacing,
        ),
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            AppSpacing.borderRadius,
          ),
          border: Border.all(
            color:
                AppColors.darkPurple.withOpacity(0.10),
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
              padding: const EdgeInsets.all(
                AppSpacing.itemSpacing,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkPurple
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(
                  AppSpacing.itemSpacing,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.deepPurple,
              ),
            ),
            const SizedBox(
              width: AppSpacing.itemSpacing,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Text(
                      value.isEmpty
                          ? 'غير محدد'
                          : value,
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