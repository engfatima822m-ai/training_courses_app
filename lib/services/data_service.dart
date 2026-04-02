import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';

class DataService {
  /// ==============================
  /// معرف الأدمن
  /// ==============================
  static const String adminEmployeeId = 'ADMIN001';

  /// ==============================
  /// قوائم البيانات
  /// ==============================
  static List<User> employees = [];
  static List<Course> courses = [];

  /// ==============================
  /// تسجيل المستخدم في دورة
  /// ==============================
  static bool registerUserToCourse(User user, Course course) {
    // منع التسجيل مرتين
    if (course.registeredUsers.contains(user.employeeId)) {
      return false;
    }

    course.registeredUsers.add(user.employeeId);
    return true;
  }

  /// ==============================
  /// تحميل الموظفين (من assets)
  /// ==============================
  static Future<void> loadEmployeesFromExcel() async {
    print("🔹 بدء تحميل الموظفين");
// نقرا البيانات من ملف الاسسيت وترجعهم على شكل بايت وتحتاج وقت 
    final bytes = await rootBundle.load('assets/employees.xlsx');
    // يحول البيانات المحملة الى صيغة مناسبة لمكتبة الاكسل 
    final data = bytes.buffer.asUint8List();
// تفتح ملف الاكسل وتفك قراءته
    final excel = Excel.decodeBytes(data);
    // تعني اننا نأخذ اول شيت من ملف الاكسل 
    final sheet = excel.tables.values.first;
// قبل تحميل البيانت الجديدة يمسح القديمة
    employees.clear();

    print("عدد صفوف الموظفين: ${sheet.rows.length}");
// حلقة تمر على كل الصفوف  ويتجاهل الصف الاول لان هو غالبا صف العناوين 
    for (var row in sheet.rows.skip(1)) {
      // لازم ID و Name موجودين
      // في حال وجود صف او عمود فارغ تجاهله وحول على الي بعده

      if (row.isEmpty || row[0]?.value == null || row[1]?.value == null) {
        continue;
      }
// المتغير الخاص بالدرجة
      int grade = 0;

      // grade موجود عادةً بالعمود 2 (إذا عندك ترتيب مختلف خبريني)
      if (row.length > 2 &&
          row[2]?.value != null &&
          row[2]!.value.toString().trim().isNotEmpty) {
        grade = int.tryParse(row[2]!.value.toString().trim()) ?? 0;
      }

      final employeeId = row[0]!.value.toString().trim();
      final fullName = row[1]!.value.toString().trim();

      employees.add(
        User(
          fullName: fullName,
          employeeId: employeeId,
          grade: grade,
          isAdmin: employeeId == adminEmployeeId,
        ),
      );
    }

    print("✅ عدد الموظفين المحملين: ${employees.length}");
  }

  /// ==============================
  /// تحويل تاريخ Excel لأي صيغة
  /// ==============================
  static DateTime _parseExcelDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    // إذا جاء DateTime مباشرة
    if (dateValue is DateTime) return dateValue;

    // نحوله نص وننظفه
    final asString = dateValue.toString().trim();

    // إذا كان رقم (Excel serial date) مثل 45234
    final asNum = num.tryParse(asString);
    if (asNum != null) {
      // Excel serial: 1899-12-30 هو الأساس الشائع
      return DateTime(1899, 12, 30).add(Duration(days: asNum.toInt()));
    }

    // إذا كان نص تاريخ قابل للقراءة
    final parsed = DateTime.tryParse(asString);
    if (parsed != null) return parsed;

    // إذا فشل كل شيء
    return DateTime.now();
  }

  /// ==============================
  /// تحميل الدورات مباشرة من assets
  /// ==============================
  static Future<void> loadCoursesFromExcel() async {
    print("🔹 بدء تحميل الدورات من assets");

    final bytes = await rootBundle.load('assets/courses.xlsx');
    final data = bytes.buffer.asUint8List();

    final excel = Excel.decodeBytes(data);
    final sheet = excel.tables.values.first;

    courses.clear();

    print("عدد صفوف الدورات في الشيت: ${sheet.rows.length}");

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      // لازم ID و Title موجودين
      if (row.isEmpty || row[0]?.value == null || row[1]?.value == null) {
        continue;
      }

      try {
        final parsedDate = _parseExcelDate(row.length > 3 ? row[3]?.value : null);

        // Debug واضح (حسب أعمدتك)
        final debugGrade = row.length > 7 ? row[7]?.value : null;
        final debugDuration = row.length > 5 ? row[5]?.value : null;
        print("🧾 صف $i | grade=$debugGrade | duration=$debugDuration | date=$parsedDate");

        courses.add(
          Course(
            id: row[0]!.value.toString(),
            title: row[1]!.value.toString(),
            instructor: row.length > 2 ? (row[2]?.value?.toString() ?? '') : '',
            date: parsedDate,
            time: row.length > 4 ? (row[4]?.value?.toString() ?? '') : '',
            duration: row.length > 5 ? (row[5]?.value?.toString() ?? '') : '',
            description: row.length > 6 ? (row[6]?.value?.toString() ?? '') : '',
            grade: row.length > 7 ? (row[7]?.value?.toString() ?? '') : '',
            location: row.length > 8 ? (row[8]?.value?.toString() ?? '') : '',
            registeredUsers: [],
          ),
        );
      } catch (e) {
        print("⚠ خطأ في قراءة صف رقم $i: $row");
        print("🔴 التفاصيل: $e");
      }
    }

    print("✅ عدد الدورات المحملة النهائي: ${courses.length}");
  }

  /// ==============================
  /// تحميل كل البيانات
  /// ==============================
  static Future<void> initializeData() async {
    await loadEmployeesFromExcel();
    await loadCoursesFromExcel();
  }

  /// ==============================
  /// تسجيل الدخول
  /// ==============================
  static User? validateUser(String fullName, String employeeId) {
    final name = fullName.trim();
    final id = employeeId.trim();

    try {
      return employees.firstWhere(
        (user) => user.fullName.trim() == name && user.employeeId.trim() == id,
      );
    } catch (_) {
      return null;
    }
  }

  /// ==============================
  /// جلب الدورات الخاصة بدرجة الموظف
  /// ==============================
  static List<Course> getCoursesForUser(int userGrade) {
    final target = userGrade.toString();

    return courses.where((course) {
      final grades = course.grade
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      return grades.contains(target);
    }).toList();
  }

  /// ==============================
  /// جلب كل الدورات
  /// ==============================
  static List<Course> getCourses() {
    return courses;
  }
}