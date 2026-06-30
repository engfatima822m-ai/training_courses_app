import 'package:flutter/material.dart';
import 'package:training_courses_app/core/widgets/admin_actions.dart';
import 'package:training_courses_app/core/widgets/admin_course_item.dart';
import 'package:training_courses_app/core/widgets/admin_error_view.dart';
import 'package:training_courses_app/core/widgets/admin_header.dart';
import 'package:training_courses_app/core/widgets/registrants_dialog.dart';
import 'package:training_courses_app/core/widgets/responsive_page.dart';
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

  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color softPurple = Color(0xFF7B2CBF);

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

  Future<void> _openManageInstructorsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageInstructorsScreen(),
      ),
    );

    if (mounted) _refreshCourses();
  }

  Future<void> _openAddCourseScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCourseScreenCustom(),
      ),
    );

    if (result == true && mounted) {
      _refreshCourses();
      _showMessage('تم تحديث قائمة الدورات بنجاح');
    }
  }

  Future<void> _openEditCourseScreen(Course course) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourseScreenCustom(course: course),
      ),
    );

    if (result == true && mounted) {
      _refreshCourses();
      _showMessage('تم تعديل الدورة وتحديث القائمة بنجاح');
    }
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
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'تأكيد حذف الدورة',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: darkPurple,
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
        backgroundColor: softPurple,
      ),
    );
  }

  Widget _buildCoursesGrid(List<Course> courses, double maxWidth) {
    if (courses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          'لا توجد دورات مضافة حالياً',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final itemWidth = maxWidth >= 1000 ? (maxWidth - 16) / 2 : maxWidth;

    return Wrap(
      textDirection: TextDirection.rtl,
      alignment: WrapAlignment.end,
      spacing: 16,
      runSpacing: 16,
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

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      title: 'شعبة التدريب',
      enableScroll: false,
      maxWidth: 1200,
      actions: [
        IconButton(
          tooltip: 'تسجيل الخروج',
          icon: const Icon(Icons.logout_rounded),
          onPressed: _logout,
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCourseScreen,
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة دورة'),
      ),
      child: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: deepPurple),
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
              final contentWidth = constraints.maxWidth;

              return RefreshIndicator(
                color: deepPurple,
                onRefresh: () async => _refreshCourses(),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: [
                    AdminHeader(
                      userName: widget.user.fullName,
                      courses: courses,
                    ),
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
                      text: 'إدارة الدورات المعلنة',
                      icon: Icons.menu_book_rounded,
                    ),
                    _buildCoursesGrid(courses, contentWidth),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
