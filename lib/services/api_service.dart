import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/models/course.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/training_api';
    }

    return 'http://localhost/training_api';

    // لاحقاً عند Android Emulator:
    // return 'http://10.0.2.2/training_api';
  }

  static Future<List<Course>> fetchCourses() async {
    final url = Uri.parse('$baseUrl/get_courses.php');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('فشل في تحميل الدورات');
    }

    final decoded = jsonDecode(response.body);

    List<dynamic> coursesData;

    if (decoded is List) {
      coursesData = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      coursesData = decoded['data'];
    } else if (decoded is Map<String, dynamic> && decoded['courses'] is List) {
      coursesData = decoded['courses'];
    } else {
      coursesData = [];
    }

    return coursesData
        .map((item) => Course.fromJson(Map<String, dynamic>.from(item)))
        .where(
          (course) =>
              course.title.trim().isNotEmpty && course.date.year > 2000,
        )
        .toList();
  }

  static Future<Map<String, dynamic>> loginUser({
    required String fullName,
    required String fingerprintId,
  }) async {
    final url = Uri.parse('$baseUrl/login.php');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "fingerprint_id": fingerprintId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في تسجيل الدخول');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>> registerToCourse({
    required String employeeId,
    required String employeeName,
    required String grade,
    required String workPlace,
    required String phone,
    required String courseId,
  }) async {
    final url = Uri.parse('$baseUrl/register_course.php');

    final response = await http.post(
      url,
      body: {
        'employee_id': employeeId,
        'employee_name': employeeName,
        'grade': grade,
        'work_place': workPlace,
        'phone': phone,
        'course_id': courseId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في الاتصال بالسيرفر');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {
      'success': false,
      'message': 'رد غير مفهوم من السيرفر',
    };
  }

  static Future<List<Map<String, dynamic>>> fetchCourseRegistrants({
    required String courseId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/get_course_registrants.php?course_id=$courseId',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('فشل في جلب بيانات المسجلين');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic> &&
        decoded['success'] == true &&
        decoded['data'] is List) {
      return List<Map<String, dynamic>>.from(decoded['data']);
    }

    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    }

    return [];
  }

  static Future<Map<String, dynamic>> checkRegistration({
    required String employeeId,
    required String courseId,
  }) async {
    final url = Uri.parse('$baseUrl/check_registration.php');

    final response = await http.post(
      url,
      body: {
        'employee_id': employeeId,
        'course_id': courseId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في التحقق من حالة التسجيل');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {
      'success': false,
      'is_registered': false,
      'message': 'رد غير مفهوم من السيرفر',
    };
  }

  static Future<Map<String, dynamic>> withdrawFromCourse({
    required String employeeId,
    required String courseId,
  }) async {
    final url = Uri.parse('$baseUrl/withdraw_course.php');

    final response = await http.post(
      url,
      body: {
        'employee_id': employeeId,
        'course_id': courseId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في الاتصال بالسيرفر');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {
      'success': false,
      'message': 'رد غير مفهوم من السيرفر',
    };
  }
}