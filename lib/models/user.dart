class User {
  final String fullName;
  final String employeeId;
  final int grade;
  final String role;
  final bool isAdmin;
  final String workPlace;
  final DateTime? nextDueDate;

  User({
    required this.fullName,
    required this.employeeId,
    required this.grade,
    required this.role,
    required this.isAdmin,
    this.workPlace = '',
    this.nextDueDate,
  });

  @override
  String toString() {
    return 'User(name: $fullName, id: $employeeId, grade: $grade, role: $role, admin: $isAdmin, workPlace: $workPlace, nextDueDate: $nextDueDate)';
  }
}