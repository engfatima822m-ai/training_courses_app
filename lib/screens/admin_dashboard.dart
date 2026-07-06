import 'package:flutter/material.dart';
import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/core/widgets/admin_actions.dart';
import 'package:training_courses_app/core/widgets/admin_course_item.dart';
import 'package:training_courses_app/core/widgets/admin_error_view.dart';
import 'package:training_courses_app/core/widgets/common/app_page_header.dart';
import 'package:training_courses_app/core/widgets/dashboard_shell.dart';
import 'package:training_courses_app/core/widgets/registrants_dialog.dart';
import 'package:training_courses_app/core/widgets/section_title.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/add_course_screen_custom.dart';
import 'package:training_courses_app/screens/course_details_screen.dart';
import 'package:training_courses_app/screens/login_screen.dart';
import 'package:training_courses_app/screens/manage_instructors_screen.dart';
import 'package:training_courses_app/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Course>> _coursesFuture;
  int _selectedMenuIndex = 0;
  Course? _courseBeingEdited;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture = ApiService.fetchCourses();
  }

  void _refreshCourses() {
    setState(_loadCourses);
  }

  void _onMenuTap(int index) {
    setState(() {
      _selectedMenuIndex = index;
      _courseBeingEdited = null;
    });
  }

  Future<void> _openManageInstructorsScreen() async {
    setState(() {
      _selectedMenuIndex = 3;
    });
  }

  Future<void> _openAddCourseScreen() async {
    setState(() {
      _courseBeingEdited = null;
      _selectedMenuIndex = 6;
    });
  }

  Future<void> _openEditCourseScreen(Course course) async {
    setState(() {
      _courseBeingEdited = course;
      _selectedMenuIndex = 7;
    });
  }

  Future<void> _openCourseDetails(Course course) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(
          course: course,
          user: widget.user,
        ),
      ),
    );

    if (mounted) _refreshCourses();
  }

  Future<void> _showRegistrants(Course course) async {
    await RegistrantsDialog.show(
      context: context,
      course: course,
      onRefresh: _refreshCourses,
      showMessage: _showMessage,
    );
  }

  Future<void> _confirmDeleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
            ),
            title: const Text(
              'تأكيد حذف الدورة',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'هل أنتِ متأكدة من حذف دورة:\n${course.title}؟',
              textAlign: TextAlign.right,
              style: const TextStyle(height: 1.6),
            ),
            actionsAlignment: MainAxisAlignment.start,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.delete_rounded),
                label: const Text('حذف'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      await _deleteCourse(course);
    }
  }

  Future<void> _deleteCourse(Course course) async {
    try {
      final result = await ApiService.deleteCourse(courseId: course.id);

      if (!mounted) return;

      if (result['success'] == true) {
        _refreshCourses();
        _showMessage(result['message'] ?? 'تم حذف الدورة بنجاح');
      } else {
        _showMessage(result['message'] ?? 'فشل حذف الدورة');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل الاتصال بالسيرفر: $e');
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.softPurple,
      ),
    );
  }

  Widget _buildCoursesGrid(List<Course> courses, double maxWidth) {
    if (courses.isEmpty) {
      return _emptyCard('لا توجد دورات مضافة حالياً');
    }

    final itemWidth = maxWidth >= 1000 ? (maxWidth - AppSpacing.md) / 2 : maxWidth;

    return Wrap(
      textDirection: TextDirection.rtl,
      alignment: WrapAlignment.end,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: courses.map((course) {
        return SizedBox(
          width: itemWidth,
          child: AdminCourseItem(
            course: course,
            onDetails: () => _openCourseDetails(course),
            onViewRegistrants: () => _showRegistrants(course),
            onEdit: () => _openEditCourseScreen(course),
            onDelete: () => _confirmDeleteCourse(course),
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: AppColors.darkPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuContent(List<Course> courses, double contentWidth) {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildHomeContent(courses, contentWidth);

      case 1:
        return _buildCoursesContent(courses, contentWidth);

      case 2:
        return _buildRegistrantsContent(courses);

      case 3:
        return _buildInstructorsContent();

      case 4:
        return _buildReportsContent(courses);

      case 5:
        return _buildSettingsContent();

      case 6:
        return _buildAddCourseContent();

      case 7:
        return _buildEditCourseContent();

      default:
        return _buildHomeContent(courses, contentWidth);
    }
  }

  Widget _buildHomeContent(List<Course> courses, double contentWidth) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildHomeHeader(courses),
        const SizedBox(height: AppSpacing.lg),
        const SectionTitle(
          text: 'صلاحيات شعبة التدريب',
          icon: Icons.verified_user,
        ),
        AdminActions(
          onAddCourse: _openAddCourseScreen,
          onManageInstructors: _openManageInstructorsScreen,
          onRefresh: _refreshCourses,
        ),
        const SectionTitle(
          text: 'آخر الدورات التدريبية',
          icon: Icons.menu_book_rounded,
        ),
        _buildCoursesGrid(
          courses.take(4).toList(),
          contentWidth,
        ),
      ],
    );
  }

  Widget _buildHomeHeader(List<Course> courses) {
    final totalCourses = courses.length;
    final totalRegistrants = courses.fold<int>(
      0,
      (sum, course) => sum + course.registeredUsers.length,
    );
    final openCourses = courses.where((course) => course.isRegistrationOpen).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.darkPurple,
            AppColors.deepPurple,
            AppColors.darkPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 54,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'مرحباً، ${widget.user.fullName}',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'لوحة شعبة التدريب لإدارة الدورات التدريبية',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.75),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.end,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _headerStatCard(
                  title: 'الدورات',
                  value: '$totalCourses',
                  icon: Icons.school_rounded,
                ),
                _headerStatCard(
                  title: 'المسجلين',
                  value: '$totalRegistrants',
                  icon: Icons.groups_rounded,
                ),
                _headerStatCard(
                  title: 'المفتوحة',
                  value: '$openCourses',
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(
          color: AppColors.white.withOpacity(0.16),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                icon,
                color: AppColors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              value,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.80),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesContent(List<Course> courses, double contentWidth) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        AppPageHeader(
          title: 'الدورات التدريبية',
          subtitle: 'إدارة الدورات المعلنة والتعديل والحذف وعرض التفاصيل',
          icon: Icons.menu_book_rounded,
          action: _headerButton(
            text: 'إضافة دورة',
            onPressed: _openAddCourseScreen,
          ),
        ),
        const SizedBox(height: AppSpacing.cardPadding),
        _buildCoursesGrid(courses, contentWidth),
      ],
    );
  }

  Widget _buildRegistrantsContent(List<Course> courses) {
    if (courses.isEmpty) {
      return ListView(
        children: [
          const AppPageHeader(
            title: 'المسجلون',
            subtitle: 'اختاري دورة لعرض أسماء المسجلين فيها',
            icon: Icons.groups_rounded,
          ),
          const SizedBox(height: AppSpacing.cardPadding),
          _emptyCard('لا توجد دورات لعرض المسجلين'),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const AppPageHeader(
          title: 'المسجلون',
          subtitle: 'اضغطي على أي دورة لعرض المسجلين فيها',
          icon: Icons.groups_rounded,
        ),
        const SizedBox(height: AppSpacing.cardPadding),
        ...courses.map(
          (course) => _simpleListCard(
            icon: Icons.groups_rounded,
            title: course.title,
            subtitle: 'عرض قائمة المسجلين في هذه الدورة',
            buttonText: 'عرض المسجلين',
            onTap: () => _showRegistrants(course),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorsContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
      child: const ManageInstructorsScreen(),
    );
  }

  Widget _buildReportsContent(List<Course> courses) {
    final totalCourses = courses.length;
    final totalRegistrants = courses.fold<int>(
      0,
      (sum, course) => sum + course.registeredUsers.length,
    );

    return ListView(
      children: [
        const AppPageHeader(
          title: 'التقارير',
          subtitle: 'ملخص سريع عن الدورات والتسجيلات',
          icon: Icons.bar_chart_rounded,
        ),
        const SizedBox(height: AppSpacing.cardPadding),
        Wrap(
          textDirection: TextDirection.rtl,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _statCard(
              title: 'عدد الدورات',
              value: '$totalCourses',
              icon: Icons.menu_book_rounded,
            ),
            _statCard(
              title: 'إجمالي المسجلين',
              value: '$totalRegistrants',
              icon: Icons.groups_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddCourseContent() {
    return AddCourseScreenCustom(
      showScaffold: false,
      onSaved: () {
        _refreshCourses();
        setState(() {
          _selectedMenuIndex = 1;
          _courseBeingEdited = null;
        });
        _showMessage('تم تحديث قائمة الدورات بنجاح');
      },
    );
  }

  Widget _buildEditCourseContent() {
    final course = _courseBeingEdited;

    if (course == null) {
      return ListView(
        children: [
          const AppPageHeader(
            title: 'تعديل الدورة',
            subtitle: 'لم يتم اختيار دورة للتعديل',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: AppSpacing.cardPadding),
          _emptyCard('اختاري دورة من قائمة الدورات ثم اضغطي تعديل'),
        ],
      );
    }

    return AddCourseScreenCustom(
      course: course,
      showScaffold: false,
      onSaved: () {
        _refreshCourses();
        setState(() {
          _selectedMenuIndex = 1;
          _courseBeingEdited = null;
        });
        _showMessage('تم تعديل الدورة وتحديث القائمة بنجاح');
      },
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      children: [
        const AppPageHeader(
          title: 'الإعدادات',
          subtitle: 'إعدادات النظام ستضاف هنا لاحقاً',
          icon: Icons.settings_rounded,
        ),
        const SizedBox(height: AppSpacing.cardPadding),
        _emptyCard('هذه الصفحة مهيأة للإعدادات القادمة'),
      ],
    );
  }

  Widget _headerButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkPurple,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
      ),
    );
  }

  Widget _simpleListCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.lightPurple,
              child: Icon(icon, color: AppColors.softPurple),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: AppColors.darkPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.lightPurple,
              child: Icon(icon, color: AppColors.softPurple),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.darkPurple,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'شعبة التدريب',
      selectedIndex: _selectedMenuIndex,
      onMenuTap: _onMenuTap,
      onLogout: _logout,
      child: Stack(
        children: [
          FutureBuilder<List<Course>>(
            future: _coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.deepPurple),
                );
              }

              if (snapshot.hasError) {
                return AdminErrorView(
                  error: snapshot.error,
                  onRetry: _refreshCourses,
                );
              }

              final courses = snapshot.data ?? [];

              return LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    color: AppColors.deepPurple,
                    onRefresh: () async => _refreshCourses(),
                    child: _buildMenuContent(
                      courses,
                      constraints.maxWidth,
                    ),
                  );
                },
              );
            },
          ),
          if (_selectedMenuIndex == 0 || _selectedMenuIndex == 1)
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton.extended(
                onPressed: _openAddCourseScreen,
                backgroundColor: AppColors.darkPurple,
                foregroundColor: AppColors.white,
                icon: const Icon(Icons.add),
                label: const Text('إضافة دورة'),
              ),
            ),
        ],
      ),
    );
  }
}
