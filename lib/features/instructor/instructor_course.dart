class InstructorCourse {
  final String id;
  final String title;
  final String date;
  final String time;
  final String duration;
  final String location;
  final String description;
  final String grade;
  final String capacity;
  final int registeredCount;

  InstructorCourse({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.location,
    required this.description,
    required this.grade,
    required this.capacity,
    required this.registeredCount,
  });

  factory InstructorCourse.fromJson(Map<String, dynamic> json) {
    return InstructorCourse(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '0',
      registeredCount: int.tryParse(json['registered_count'].toString()) ?? 0,
    );
  }
}