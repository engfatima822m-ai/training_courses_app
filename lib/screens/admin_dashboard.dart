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

  Future<void> _showRegistrants(Course course) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            content: SizedBox(
              height: 90,
              child: Center(
                child: CircularProgressIndicator(color: darkPurple),
              ),
            ),
          ),
        );
      },
    );

    try {
      final registrants = await ApiService.fetchCourseRegistrants(
        courseId: course.id,
      );

      if (!mounted) return;

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'المسجلون في ${course.title}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 720,
                child: registrants.isEmpty
                    ? const Text(
                        'لا يوجد مسجلون حالياً في هذه الدورة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _registrantsSummary(course, registrants.length),
                            const SizedBox(height: 14),
                            ...registrants.map(
                              (person) => _registrantCard(person),
                            ),
                          ],
                        ),
                      ),
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
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      _showMessage('فشل في جلب بيانات المسجلين');
    }
  }

  Widget _registrantsSummary(Course course, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            course.title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عدد المسجلين: $count من ${course.capacity} | المتبقي: ${course.remainingSeats}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registrantCard(Map<String, dynamic> person) {
    final name = person['employee_name']?.toString() ?? '';
    final employeeId = person['employee_id']?.toString() ?? '';
    final grade = person['grade']?.toString() ?? '';
    final workPlace = person['work_place']?.toString() ?? '';
    final phone = person['phone']?.toString() ?? '';
    final date = person['registration_date']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            name.isEmpty ? 'اسم غير متوفر' : name,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _registrantInfo('الرقم الوظيفي / البصمة', employeeId),
          _registrantInfo('الدرجة الوظيفية', grade),
          _registrantInfo('مكان العمل / القسم', workPlace),
          _registrantInfo('رقم الهاتف', phone),
          _registrantInfo('تاريخ التسجيل', date),
        ],
      ),
    );
  }

  Widget _registrantInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'غير محدد' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        ],
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

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: course.isRegistrationOpen
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: course.isRegistrationOpen ? Colors.green : Colors.red,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            course.isRegistrationOpen
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 16,
            color: course.isRegistrationOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 5),
          Text(
            course.registrationStatusText,
            style: TextStyle(
              color: course.isRegistrationOpen ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seatInfoBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: darkPurple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkPurple.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: deepPurple, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: darkPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = course.capacity == 0
        ? 0.0
        : (course.registeredCount / course.capacity).clamp(0.0, 1.0);

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
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            textDirection: TextDirection.rtl,
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.person_rounded, course.instructorsText),
              _chip(Icons.location_on_rounded, course.location),
              _chip(Icons.calendar_month_rounded, _formatDate(course.date)),
              _chip(Icons.access_time_rounded, course.time),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _seatInfoBox(
                title: 'المقاعد',
                value: '${course.capacity}',
                icon: Icons.event_seat_rounded,
              ),
              const SizedBox(width: 10),
              _seatInfoBox(
                title: 'المسجلين',
                value: '${course.registeredCount}',
                icon: Icons.groups_rounded,
              ),
              const SizedBox(width: 10),
              _seatInfoBox(
                title: 'المتبقي',
                value: '${course.remainingSeats}',
                icon: Icons.how_to_reg_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: darkPurple.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                course.isFull ? Colors.red : deepPurple,
              ),
            ),
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