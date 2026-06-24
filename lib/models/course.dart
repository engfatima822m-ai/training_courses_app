class Course {
  final String id;
  final String title;

  /// نخليها تبقى موجودة حتى لا تنكسر الصفحات القديمة
  final String instructor;

  /// المحاضرين المتعددين
  final List<String> instructors;

  final DateTime date;
  final String time;
  final String duration;
  final String description;

  /// مثال: "2,3" أو "7,6,5"
  final String grade;

  final String location;

  /// عدد المقاعد المسموح بها
  final int capacity;

  /// عدد المسجلين القادم من قاعدة البيانات
  final int registeredCountFromApi;

  /// تاريخ بداية التسجيل
  final DateTime registrationStartDate;

  /// تاريخ نهاية التسجيل
  final DateTime registrationEndDate;

  final List<String> registeredUsers;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    List<String>? instructors,
    required this.date,
    required this.time,
    required this.duration,
    required this.description,
    required this.grade,
    required this.location,
    this.capacity = 30,
    this.registeredCountFromApi = 0,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    List<String>? registeredUsers,
  })  : instructors = List.unmodifiable(
          instructors ??
              (instructor.trim().isEmpty ? const [] : [instructor.trim()]),
        ),
        registrationStartDate = registrationStartDate ?? DateTime.now(),
        registrationEndDate =
            registrationEndDate ?? DateTime.now().add(const Duration(days: 9)),
        registeredUsers = List.unmodifiable(registeredUsers ?? const []);

  factory Course.fromJson(Map<String, dynamic> json) {
    final mainInstructor = json['instructor'] ?? '';

    return Course(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      instructor: mainInstructor,
      instructors: _parseInstructors(json['instructors'], mainInstructor),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      grade: json['grade'] ?? '',
      location: json['location'] ?? '',
      capacity: int.tryParse(json['capacity']?.toString() ?? '') ?? 30,
      registeredCountFromApi:
          int.tryParse(json['registered_count']?.toString() ?? '') ?? 0,
      registrationStartDate:
          DateTime.tryParse(json['registration_start_date'] ?? '') ??
              DateTime.now(),
      registrationEndDate:
          DateTime.tryParse(json['registration_end_date'] ?? '') ??
              DateTime.now().add(const Duration(days: 9)),
      registeredUsers: const [],
    );
  }

  /// تحويل المحاضرين من JSON إلى List
  static List<String> _parseInstructors(dynamic value, String fallback) {
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (fallback.trim().isNotEmpty) {
      return [fallback.trim()];
    }

    return [];
  }

  /// عرض أسماء المحاضرين كنص واحد
  String get instructorsText {
    if (instructors.isEmpty) return instructor;
    return instructors.join('، ');
  }

  /// عدد المسجلين في الدورة
  int get registeredCount {
    if (registeredUsers.isNotEmpty) {
      return registeredUsers.length;
    }

    return registeredCountFromApi;
  }

  /// المقاعد المتبقية
  int get remainingSeats {
    final remaining = capacity - registeredCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// هل العدد اكتمل؟
  bool get isFull => registeredCount >= capacity;

  /// تاريخ اليوم بدون ساعة
  DateTime get _todayOnly {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// تاريخ بداية التسجيل بدون ساعة
  DateTime get _startDateOnly {
    return DateTime(
      registrationStartDate.year,
      registrationStartDate.month,
      registrationStartDate.day,
    );
  }

  /// تاريخ نهاية التسجيل بدون ساعة
  DateTime get _endDateOnly {
    return DateTime(
      registrationEndDate.year,
      registrationEndDate.month,
      registrationEndDate.day,
    );
  }

  /// هل فترة التسجيل انتهت؟
  bool get isRegistrationExpired {
    return _todayOnly.isAfter(_endDateOnly);
  }

  /// هل التسجيل لم يبدأ بعد؟
  bool get isRegistrationNotStarted {
    return _todayOnly.isBefore(_startDateOnly);
  }

  /// هل التسجيل مفتوح؟
  bool get isRegistrationOpen {
    return !_todayOnly.isBefore(_startDateOnly) &&
        !_todayOnly.isAfter(_endDateOnly) &&
        !isFull;
  }

  /// هل التسجيل ينتهي قريباً؟ آخر يومين
  bool get isEndingSoon {
    final difference = _endDateOnly.difference(_todayOnly).inDays;
    return isRegistrationOpen && difference <= 2;
  }

  /// حالة التسجيل كنص
  String get registrationStatusText {
    if (isFull) return 'اكتمل العدد';
    if (isRegistrationExpired) return 'انتهى التسجيل';
    if (isRegistrationNotStarted) return 'لم يبدأ التسجيل';
    if (isEndingSoon) return 'ينتهي قريباً';
    if (isRegistrationOpen) return 'التسجيل مفتوح';

    return 'مغلق';
  }

  /// هل هذا المستخدم مسجل؟
  bool isUserRegistered(String employeeId) {
    return registeredUsers.contains(employeeId);
  }

  /// نسخة جديدة من الدورة مع إضافة مستخدم
  Course addRegisteredUser(String employeeId) {
    if (registeredUsers.contains(employeeId)) return this;
    if (isFull) return this;

    return copyWith(
      registeredUsers: [...registeredUsers, employeeId],
    );
  }

  /// نسخة جديدة من الدورة مع حذف مستخدم
  Course removeRegisteredUser(String employeeId) {
    if (!registeredUsers.contains(employeeId)) return this;

    final updated = registeredUsers.where((id) => id != employeeId).toList();

    return copyWith(registeredUsers: updated);
  }

  /// copyWith لتحديث حقول محددة بدون تعديل الأصل
  Course copyWith({
    String? id,
    String? title,
    String? instructor,
    List<String>? instructors,
    DateTime? date,
    String? time,
    String? duration,
    String? description,
    String? grade,
    String? location,
    int? capacity,
    int? registeredCountFromApi,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    List<String>? registeredUsers,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      instructors: instructors ?? this.instructors,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      grade: grade ?? this.grade,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      registeredCountFromApi:
          registeredCountFromApi ?? this.registeredCountFromApi,
      registrationStartDate:
          registrationStartDate ?? this.registrationStartDate,
      registrationEndDate: registrationEndDate ?? this.registrationEndDate,
      registeredUsers: registeredUsers ?? this.registeredUsers,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, title: $title, instructors: $instructorsText, date: $date, grade: $grade, registered: $registeredCount/$capacity, status: $registrationStatusText)';
  }
}