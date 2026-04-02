import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/models/course.dart';

class ApiService {
  // ✅ يحدد الرابط حسب نوع التشغيل
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/training_api';
    } else {
      return 'http://10.0.2.2/training_api';
    }
  }

  /// ===== جلب الدورات =====
  static Future<List<Course>> fetchCourses() async {
    final url = Uri.parse('$baseUrl/get_courses.php');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('فشل في تحميل الدورات');
    }
  }

  /// ===== تسجيل المستخدم في دورة =====
  static Future<bool> registerToCourse({
    required String employeeId,
    required String courseId,
  }) async {
    final url = Uri.parse('$baseUrl/register_course.php');

    final response = await http.post(
      url,
      body: {
        'employee_id': employeeId,
        'course_id': courseId,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['success'] == true;
    } else {
      throw Exception('فشل في الاتصال بالسيرفر');
    }
  }
}