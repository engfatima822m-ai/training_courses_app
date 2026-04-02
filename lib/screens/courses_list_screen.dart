import 'package:flutter/material.dart';
import 'package:training_courses_app/screens/course_details_screen.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/services/api_service.dart';

class CoursesListScreen extends StatelessWidget {
  final User user;

  const CoursesListScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدورات التدريبية المتاحة'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: ApiService.fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ: ${snapshot.error}'),
            );
          }

          final courses = snapshot.data ?? [];

          final filteredCourses = courses.where((course) {
            final grades = course.grade
                .split(',')
                .map((e) => e.trim())
                .toList();

            return grades.contains(user.grade.toString());
          }).toList();

          if (filteredCourses.isEmpty) {
            return const Center(
              child: Text('لا توجد دورات متاحة لهذه الدرجة'),
            );
          }

          return ListView.builder(
            itemCount: filteredCourses.length,
            itemBuilder: (context, index) {
              final course = filteredCourses[index];

              print("COURSE ID: ${course.id}");

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(course.title),
                  subtitle: Text(
                    '${course.instructor} - ${course.location}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}