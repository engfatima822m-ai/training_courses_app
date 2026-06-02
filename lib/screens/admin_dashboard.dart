import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/add_course_screen_custom.dart';
import 'package:training_courses_app/screens/course_details_screen.dart';
import 'package:training_courses_app/screens/login_screen.dart';
import 'package:training_courses_app/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Course>> _coursesFuture;

  static const Color blackColor = Color(0xFF111111);
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

  Future<void> _openAddCourseScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCourseScreenCustom(),
      ),
    );

    if (result == true) {
      setState(_loadCourses);
      _showMessage('تم تحديث قائمة الدورات بنجاح');
    }
  }

  void _openCourseDetails(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(
          course: course,
          user: widget.user,
        ),
      ),
    );
  }

  void _showRegistrants(Course course) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'مراقبة المسجلين',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  course.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                _dialogInfo('المحاضر', course.instructor),
                _dialogInfo('الموقع', course.location),
                _dialogInfo('عدد المسجلين حالياً', '${course.registeredCount}'),
                const SizedBox(height: 12),
                const Text(
                  'ملاحظة: حالياً يتم عرض العدد فقط، وبعد ربط جدول التسجيلات نعرض أسماء المسجلين هنا.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$label: ${value.isEmpty ? 'غير محدد' : value}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
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
        content: Text(text, textAlign: TextAlign.right),
        backgroundColor: softPurple,
      ),
    );
  }

  Widget _buildHeader(List<Course> courses) {
    final totalRegistrations =
        courses.fold<int>(0, (sum, c) => sum + c.registeredCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [blackColor, darkPurple, blackColor],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            'مرحباً، ${widget.user.fullName}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لوحة شعبة التدريب لإدارة الدورات التدريبية',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.school_rounded,
                  title: 'الدورات',
                  value: '${courses.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.groups_rounded,
                  title: 'المسجلين',
                  value: '$totalRegistrations',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: darkPurple),
          const SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _actionButton(
          text: 'إضافة دورة',
          icon: Icons.add_rounded,
          onTap: _openAddCourseScreen,
        ),
        const SizedBox(width: 12),
        _actionButton(
          text: 'تحديث',
          icon: Icons.refresh_rounded,
          onTap: () => setState(_loadCourses),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F2FA),
        appBar: AppBar(
          backgroundColor: blackColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'شعبة التدريب',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: _logout,
            ),
          ],
        ),
        body: FutureBuilder<List<Course>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: deepPurple),
              );
            }

            final courses = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(courses),
                _sectionTitle('صلاحيات شعبة التدريب', Icons.verified_user),
                _buildActions(),
                _sectionTitle('إدارة الدورات المعلنة', Icons.menu_book_rounded),

                if (courses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'لا توجد دورات مضافة حالياً',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  ...courses.map(
                    (course) => AdminCourseItem(
                      course: course,
                      onDetails: () => _openCourseDetails(course),
                      onViewRegistrants: () => _showRegistrants(course),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddCourseScreen,
          backgroundColor: darkPurple,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة دورة'),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCourseItem extends StatelessWidget {
  final Course course;
  final VoidCallback onDetails;
  final VoidCallback onViewRegistrants;

  const AdminCourseItem({
    super.key,
    required this.course,
    required this.onDetails,
    required this.onViewRegistrants,
  });

  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 16, color: deepPurple),
          const SizedBox(width: 5),
          Text(
            text.isEmpty ? 'غير محدد' : text,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            course.title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            textDirection: TextDirection.rtl,
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.person_rounded, course.instructor),
              _chip(Icons.location_on_rounded, course.location),
              _chip(Icons.calendar_month_rounded, _formatDate(course.date)),
              _chip(Icons.access_time_rounded, course.time),
              _chip(Icons.people_rounded, 'المسجلين: ${course.registeredCount}'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('تفاصيل الدورة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewRegistrants,
                  icon: const Icon(Icons.groups_rounded),
                  label: const Text('مراقبة المسجلين'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: deepPurple,
                    side: const BorderSide(color: deepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}