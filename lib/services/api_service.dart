import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/models/course.dart';

class ApiService {
  // ✅ رابط الـ API حسب نوع التشغيل
  static String get baseUrl {
    // عند التشغيل على المتصفح
    if (kIsWeb) {
      return 'http://localhost/training_api';
    }

    // عند التشغيل على Windows Desktop
    // حالياً نشتغل على اللابتوب/الحاسبة، لذلك localhost هو الصحيح
    return 'http://localhost/training_api';

    // ملاحظة لاحقاً:
    // إذا رجعنا نشغل على Android Emulator نستعمل:
    // return 'http://10.0.2.2/training_api';
  }

  /// ==============================
  /// 📚 جلب الدورات
  /// ==============================
  static Future<List<Course>> fetchCourses() async {
    final url = Uri.parse('$baseUrl/get_courses.php');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => Course.fromJson(item))
          .where((course) =>
              course.title.trim().isNotEmpty &&
              course.instructor.trim().isNotEmpty &&
              course.date.year > 2000)
          .toList();
    } else {
      throw Exception('فشل في تحميل الدورات');
    }
  }

  /// ==============================
  /// 🔐 تسجيل الدخول
  /// ==============================
  static Future<Map<String, dynamic>> loginUser({
    required String fullName,
    required String fingerprintId,
  }) async {
    final url = Uri.parse('$baseUrl/login.php');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "full_name": fullName,
        "fingerprint_id": fingerprintId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل في تسجيل الدخول');
    }
  }

  /// ==============================
  /// 📝 تسجيل المستخدم في دورة
  /// ==============================
  static Future<bool> registerToCourse({
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['success'] == true;
    } else {
      throw Exception('فشل في الاتصال بالسيرفر');
    }
  }

  /// ==============================
  /// 👥 جلب المسجلين في دورة محددة
  /// ==============================
  static Future<List<Map<String, dynamic>>> fetchCourseRegistrants({
    required String courseId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/get_course_registrants.php?course_id=$courseId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }

      return [];
    } else {
      throw Exception('فشل في جلب بيانات المسجلين');
    }
  }
}