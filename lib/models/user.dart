class User {
  final String fullName;
  final String employeeId;
  final int grade;
  final bool isAdmin;

  User({
    required this.fullName,
    required this.employeeId,
    required this.grade,
    required this.isAdmin,
  });

  @override
  String toString() {
    return 'User(name: $fullName, id: $employeeId, grade: $grade, admin: $isAdmin)';
  }
}