import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/course_details_screen.dart';
import 'package:training_courses_app/services/api_service.dart';

class CoursesListScreen extends StatelessWidget {
  final User user;

  const CoursesListScreen({
    super.key,
    required this.user,
  });

  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color softPurple = Color(0xFF7B2CBF);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            deepPurple,
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 54,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'الدورات التدريبية المعلنة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'شركة توزيع المنتجات النفطية / فرع البصرة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
              ),
            ),
            child: const Text(
              'دورات هذا الشهر',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: softPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: deepPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'قائمة الدورات المتاحة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'عدد الدورات المعلنة حالياً: $count',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: darkPurple.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 17, color: deepPurple),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: darkPurple.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [darkPurple, deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  course.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.person_rounded,
                text: course.instructor,
              ),
              _buildInfoChip(
                icon: Icons.location_on_rounded,
                text: course.location,
              ),
              _buildInfoChip(
                icon: Icons.calendar_month_rounded,
                text: _formatDate(course.date),
              ),
              _buildInfoChip(
                icon: Icons.access_time_rounded,
                text: course.time,
              ),
              _buildInfoChip(
                icon: Icons.timelapse_rounded,
                text: course.duration,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsScreen(
                      course: course,
                      user: user,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('عرض تفاصيل الدورة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView(
      children: [
        _buildHeader(),
        const SizedBox(height: 60),
        const Center(
          child: CircularProgressIndicator(
            color: deepPurple,
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'جاري تحميل الدورات المعلنة...',
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(Object? error) {
    return ListView(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.20),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red,
                  size: 42,
                ),
                const SizedBox(height: 12),
                const Text(
                  'تعذر تحميل الدورات حالياً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return ListView(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: darkPurple.withOpacity(0.10),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color: deepPurple,
                  size: 48,
                ),
                SizedBox(height: 14),
                Text(
                  'لا توجد دورات معلنة حالياً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'سيتم عرض الدورات هنا عند إضافتها من قبل شعبة التدريب.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
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
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الدورات التدريبية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder<List<Course>>(
          future: ApiService.fetchCourses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingView();
            }

            if (snapshot.hasError) {
              return _buildErrorView(snapshot.error);
            }

           final courses = (snapshot.data ?? []).where((course) {
  return course.title.trim().isNotEmpty &&
      course.instructor.trim().isNotEmpty &&
      course.date.year > 2000;
}).toList();

            if (courses.isEmpty) {
              return _buildEmptyView();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 18),
              itemCount: courses.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader();

                if (index == 1) {
                  return _buildSectionTitle(courses.length);
                }

                final course = courses[index - 2];
                return _buildCourseCard(context, course);
              },
            );
          },
        ),
      ),
    );
  }
}