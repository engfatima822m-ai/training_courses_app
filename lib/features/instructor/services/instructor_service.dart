import 'dart:convert';

import 'package:http/http.dart' as http;

import '../instructor_course.dart';

class InstructorService {
  static const String apiUrl =
      'http://localhost/training_api/get_instructor_courses.php';

  static Future<List<InstructorCourse>> fetchInstructorCourses({
    required String instructorId,
  }) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'instructor_id': instructorId,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'حدث خطأ أثناء جلب البيانات',
      );
    }

    final List list = data['courses'] ?? [];

    return list
        .map((e) => InstructorCourse.fromJson(e))
        .toList();
  }
}