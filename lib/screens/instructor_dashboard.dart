import 'package:flutter/material.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/features/instructor/instructor_course.dart';
import 'package:training_courses_app/features/instructor/services/instructor_service.dart';
import 'package:training_courses_app/screens/login_screen.dart';

import 'package:training_courses_app/features/instructor/widgets/instructor_action_button.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_course_card.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_header.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_info_card.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_message_card.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_page_header.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_report_card.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_section_title.dart';
import 'package:training_courses_app/features/instructor/widgets/instructor_stat_card.dart';

export 'package:training_courses_app/features/instructor/instructor_course.dart';

class InstructorDashboard extends StatefulWidget {
  final User user;

  const InstructorDashboard({
    super.key,
    required this.user,
  });

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  static const Color pageBg = Color(0xFFF6F2FA);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color selectedBg = Color(0xFFEDE3F8);
  static const double sideBarWidth = 280;

  bool isLoading = true;
  String? errorMessage;
  List<InstructorCourse> courses = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchInstructorCourses();
  }

  Future<void> fetchInstructorCourses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedCourses = await InstructorService.fetchInstructorCourses(
        instructorId: widget.user.employeeId,
      );

      if (!mounted) return;

      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'تعذر الاتصال بالخادم';
        isLoading = false;
      });
    }
  }

  void _goToLoginScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  int get totalCourses => courses.length;

  int get totalRegistered {
    int total = 0;
    for (final course in courses) {
      total += course.registeredCount;
    }
    return total;
  }

  int get upcomingCourses {
    final today = DateTime.now();
    int count = 0;

    for (final course in courses) {
      final date = DateTime.tryParse(course.date);
      if (date != null) {
        final courseDate = DateTime(date.year, date.month, date.day);
        final currentDate = DateTime(today.year, today.month, today.day);

        if (courseDate.isAfter(currentDate) ||
            courseDate.isAtSameMomentAs(currentDate)) {
          count++;
        }
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBg,
        body: Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: _buildPageContent(),
            ),
            _buildSideBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return SafeArea(
      child: IndexedStack(
        index: selectedIndex,
        children: [
          _buildHomePage(),
          _buildCoursesPage(),
          _buildRegisteredPage(),
          _buildReportsPage(),
          _buildSettingsPage(),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: fetchInstructorCourses,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          InstructorHeader(
            user: widget.user,
            totalCourses: totalCourses,
            totalRegistered: totalRegistered,
            upcomingCourses: upcomingCourses,
          ),
          const SizedBox(height: 26),
          const InstructorSectionTitle(
            title: 'إحصائيات سريعة',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: InstructorStatCard(
                  icon: Icons.menu_book_rounded,
                  title: 'الدورات',
                  value: totalCourses.toString(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InstructorStatCard(
                  icon: Icons.groups_rounded,
                  title: 'المسجلين',
                  value: totalRegistered.toString(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InstructorStatCard(
                  icon: Icons.event_available_rounded,
                  title: 'القادمة',
                  value: upcomingCourses.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const InstructorSectionTitle(
            title: 'صلاحيات المحاضر',
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: InstructorActionButton(
                  icon: Icons.visibility_rounded,
                  text: 'عرض الدورات المكلف بها',
                  onTap: () => setState(() => selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InstructorActionButton(
                  icon: Icons.groups_rounded,
                  text: 'متابعة أعداد المسجلين',
                  onTap: () => setState(() => selectedIndex = 2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InstructorActionButton(
                  icon: Icons.refresh_rounded,
                  text: 'تحديث البيانات',
                  onTap: fetchInstructorCourses,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const InstructorSectionTitle(
            title: 'آخر الدورات المكلف بها',
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 14),
          _buildCoursesPreview(maxItems: 3),
        ],
      ),
    );
  }

  Widget _buildCoursesPage() {
    return RefreshIndicator(
      onRefresh: fetchInstructorCourses,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const InstructorPageHeader(
            title: 'الدورات المكلف بها',
            subtitle: 'هنا تظهر جميع الدورات المرتبطة بحساب المحاضر',
            icon: Icons.menu_book_rounded,
          ),
          const SizedBox(height: 20),
          _buildCoursesList(),
        ],
      ),
    );
  }

  Widget _buildRegisteredPage() {
    return RefreshIndicator(
      onRefresh: fetchInstructorCourses,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const InstructorPageHeader(
            title: 'المسجلون',
            subtitle: 'متابعة أعداد المسجلين داخل كل دورة تدريبية',
            icon: Icons.groups_rounded,
          ),
          const SizedBox(height: 20),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: InstructorStatCard(
                  icon: Icons.groups_rounded,
                  title: 'إجمالي المسجلين',
                  value: totalRegistered.toString(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InstructorStatCard(
                  icon: Icons.school_rounded,
                  title: 'عدد الدورات',
                  value: totalCourses.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCoursesList(showRegisteredFocus: true),
        ],
      ),
    );
  }

  Widget _buildReportsPage() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const InstructorPageHeader(
          title: 'التقارير',
          subtitle: 'ملخص سريع عن دورات المحاضر وأعداد المسجلين',
          icon: Icons.bar_chart_rounded,
        ),
        const SizedBox(height: 20),
        InstructorReportCard(
          title: 'إجمالي الدورات',
          value: totalCourses.toString(),
          icon: Icons.menu_book_rounded,
        ),
        InstructorReportCard(
          title: 'إجمالي المسجلين',
          value: totalRegistered.toString(),
          icon: Icons.groups_rounded,
        ),
        InstructorReportCard(
          title: 'الدورات القادمة',
          value: upcomingCourses.toString(),
          icon: Icons.event_available_rounded,
        ),
      ],
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const InstructorPageHeader(
          title: 'الإعدادات',
          subtitle: 'معلومات حساب المحاضر',
          icon: Icons.settings_rounded,
        ),
        const SizedBox(height: 20),
        InstructorInfoCard(
          title: 'اسم المحاضر',
          value: widget.user.fullName,
          icon: Icons.person_rounded,
        ),
        InstructorInfoCard(
          title: 'الرقم الوظيفي',
          value: widget.user.employeeId,
          icon: Icons.badge_rounded,
        ),
        const InstructorInfoCard(
          title: 'الصلاحية',
          value: 'محاضر',
          icon: Icons.verified_user_rounded,
        ),
      ],
    );
  }

  Widget _buildSideBar() {
    return Container(
      width: sideBarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Color(0xFFE6DDF0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    deepPurple,
                    Color(0xFF7B1FC7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'الرجوع إلى تسجيل الدخول',
                      onPressed: _goToLoginScreen,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'نظام الدورات التدريبية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'واجهة المحاضر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildMenuItem(
              index: 0,
              title: 'الرئيسية',
              icon: Icons.home_rounded,
            ),
            _buildMenuItem(
              index: 1,
              title: 'الدورات التدريبية',
              icon: Icons.menu_book_rounded,
            ),
            _buildMenuItem(
              index: 2,
              title: 'المسجلون',
              icon: Icons.groups_rounded,
            ),
            _buildMenuItem(
              index: 3,
              title: 'التقارير',
              icon: Icons.bar_chart_rounded,
            ),
            _buildMenuItem(
              index: 4,
              title: 'الإعدادات',
              icon: Icons.settings_rounded,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: fetchInstructorCourses,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('تحديث'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: deepPurple,
                    side: const BorderSide(color: Color(0xFFE6DDF0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                icon,
                color: isSelected ? deepPurple : Colors.grey.shade600,
                size: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isSelected ? deepPurple : Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesPreview({required int maxItems}) {
    if (isLoading || errorMessage != null || courses.isEmpty) {
      return _buildCoursesList();
    }

    final visibleCourses = courses.take(maxItems).toList();

    return Column(
      children: [
        ...visibleCourses.map((course) {
          return InstructorCourseCard(course: course);
        }),
        if (courses.length > maxItems)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => selectedIndex = 1),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('عرض جميع الدورات'),
              style: TextButton.styleFrom(
                foregroundColor: deepPurple,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCoursesList({bool showRegisteredFocus = false}) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(35),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return InstructorMessageCard(
        icon: Icons.error_outline_rounded,
        message: errorMessage!,
      );
    }

    if (courses.isEmpty) {
      return const InstructorMessageCard(
        icon: Icons.info_outline_rounded,
        message: 'لا توجد دورات مرتبطة بهذا المحاضر حالياً',
      );
    }

    return Column(
      children: courses.map((course) {
        return InstructorCourseCard(
          course: course,
          showRegisteredFocus: showRegisteredFocus,
        );
      }).toList(),
    );
  }
}
