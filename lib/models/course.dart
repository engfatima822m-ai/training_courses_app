class Course {
  final String id;
  final String title;
  final String instructor;
  final DateTime date;
  final String time;
  final String duration;
  final String description;
  final String grade; // مثال: "2,3" أو "7,6,5"
  final String location;

  final List<String> registeredUsers;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.date,
    required this.time,
    required this.duration,
    required this.description,
    required this.grade,
    required this.location,
    List<String>? registeredUsers,
  }) : registeredUsers = List.unmodifiable(registeredUsers ?? const []);

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      grade: json['grade'] ?? '',
      location: json['location'] ?? '',
      registeredUsers: const [],
    );
  }

  /// عدد المسجلين في الدورة
  int get registeredCount => registeredUsers.length;

  /// هل هذا المستخدم مسجل؟
  bool isUserRegistered(String employeeId) {
    return registeredUsers.contains(employeeId);
  }

  /// نسخة جديدة من الدورة مع إضافة مستخدم (بدون تكرار)
  Course addRegisteredUser(String employeeId) {
    if (registeredUsers.contains(employeeId)) return this;
    return copyWith(
      registeredUsers: [...registeredUsers, employeeId],
    );
  }

  /// نسخة جديدة من الدورة مع حذف مستخدم (إذا احتجتي لاحقًا)
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
    DateTime? date,
    String? time,
    String? duration,
    String? description,
    String? grade,
    String? location,
    List<String>? registeredUsers,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      grade: grade ?? this.grade,
      location: location ?? this.location,
      registeredUsers: registeredUsers ?? this.registeredUsers,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, title: $title, date: $date, grade: $grade, registered: $registeredCount)';
  }
}