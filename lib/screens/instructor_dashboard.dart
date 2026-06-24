
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/models/user.dart';

class InstructorCourse {
  final String id;
  final String title;
  final String date;
  final String time;
  final String duration;
  final String location;
  final String description;
  final String grade;
  final String capacity;
  final int registeredCount;

  InstructorCourse({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.location,
    required this.description,
    required this.grade,
    required this.capacity,
    required this.registeredCount,
  });

  factory InstructorCourse.fromJson(Map<String, dynamic> json) {
    return InstructorCourse(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '0',
      registeredCount: int.tryParse(json['registered_count'].toString()) ?? 0,
    );
  }
}

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
  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  bool isLoading = true;
  String? errorMessage;
  List<InstructorCourse> courses = [];

  String get apiUrl {
    return 'http://localhost/training_api/get_instructor_courses.php';
  }

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
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'instructor_id': widget.user.employeeId,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['success'] == true) {
        final List list = data['courses'] ?? [];

        setState(() {
          courses = list.map((item) => InstructorCourse.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'حدث خطأ أثناء جلب البيانات';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'تعذر الاتصال بالخادم';
        isLoading = false;
      });
    }
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
        backgroundColor: const Color(0xFFF6F2FA),
        appBar: AppBar(
          backgroundColor: blackColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'واجهة المحاضر',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: fetchInstructorCourses,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSectionTitle('إحصائيات سريعة'),
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.menu_book_rounded,
                    title: 'الدورات',
                    value: totalCourses.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.groups_rounded,
                    title: 'المسجلين',
                    value: totalRegistered.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.event_available_rounded,
                    title: 'القادمة',
                    value: upcomingCourses.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('صلاحيات المحاضر'),
            const SizedBox(height: 12),
            _buildPermissionCard(
              Icons.visibility_rounded,
              'عرض الدورات المكلف بها',
            ),
            _buildPermissionCard(
              Icons.groups_rounded,
              'متابعة أعداد المسجلين',
            ),
            _buildPermissionCard(
              Icons.info_outline_rounded,
              'عرض تفاصيل الدورة التدريبية',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('الدورات المكلف بها'),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              _buildMessageCard(
                icon: Icons.error_outline_rounded,
                message: errorMessage!,
              )
            else if (courses.isEmpty)
              _buildMessageCard(
                icon: Icons.info_outline_rounded,
                message: 'لا توجد دورات مرتبطة بهذا المحاضر حالياً',
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 520,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: courses.map((course) {
                      return _buildCourseCard(course: course);
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            blackColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'مرحباً ${widget.user.fullName}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لوحة المحاضر لمتابعة الدورات التدريبية المكلف بها',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: darkPurple,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 135,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkPurple,
            deepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPermissionCard(
    IconData icon,
    String text,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            color: deepPurple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMessageCard({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCourseInfoLine({
    required String label,
    required String value,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        '$label: $value',
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  static Widget _buildCourseCard({
    required InstructorCourse course,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              course.title,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 17,
                color: darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildCourseInfoLine(
              label: 'تاريخ الدورة',
              value: course.date,
            ),
            const SizedBox(height: 4),
            _buildCourseInfoLine(
              label: 'وقت الدورة',
              value: course.time,
            ),
            const SizedBox(height: 4),
            _buildCourseInfoLine(
              label: 'مكان الدورة',
              value: course.location,
            ),
            const SizedBox(height: 4),
            _buildCourseInfoLine(
              label: 'عدد المسجلين',
              value: course.registeredCount.toString(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text(
                  'عرض التفاصيل',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}