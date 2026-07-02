import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/course_details_screen.dart';
import 'package:training_courses_app/services/api_service.dart';

class CoursesListScreen extends StatefulWidget {
  final User user;

  const CoursesListScreen({
    super.key,
    required this.user,
  });

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color softPurple = Color(0xFF7B2CBF);
  static const Color lightBackground = Color(0xFFF6F2FA);

  final TextEditingController _searchController = TextEditingController();

  late Future<List<Course>> _coursesFuture;

  String _searchText = '';
  String _selectedGrade = 'الكل';
  String _selectedMonth = 'الكل';

  @override
  void initState() {
    super.initState();
    _coursesFuture = ApiService.fetchCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshCourses() async {
    setState(() {
      _coursesFuture = ApiService.fetchCourses();
    });
  }

  List<String> _uniqueItems(List<String> items) {
    final result = <String>[];

    for (final item in items) {
      final clean = item.trim();
      if (clean.isNotEmpty && !result.contains(clean)) {
        result.add(clean);
      }
    }

    if (!result.contains('الكل')) {
      result.insert(0, 'الكل');
    }

    return result;
  }

  String? _safeDropdownValue(String value, List<String> items) {
    final safeItems = _uniqueItems(items);
    return safeItems.contains(value) ? value : 'الكل';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  String _monthName(int month) {
    const months = [
      'كانون الثاني',
      'شباط',
      'آذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين الأول',
      'تشرين الثاني',
      'كانون الأول',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  List<String> _extractMonths(List<Course> courses) {
    final months = courses
        .map((course) => '${course.date.year}-${course.date.month}')
        .toSet()
        .toList();

    months.sort((a, b) {
      final aParts = a.split('-');
      final bParts = b.split('-');

      final aYear = int.tryParse(aParts[0]) ?? 0;
      final aMonth = int.tryParse(aParts[1]) ?? 0;

      final bYear = int.tryParse(bParts[0]) ?? 0;
      final bMonth = int.tryParse(bParts[1]) ?? 0;

      final aDate = DateTime(aYear, aMonth);
      final bDate = DateTime(bYear, bMonth);

      return aDate.compareTo(bDate);
    });

    return _uniqueItems(['الكل', ...months]);
  }

  String _displayMonth(String value) {
    if (value == 'الكل') return 'كل الأشهر';

    final parts = value.split('-');
    if (parts.length < 2) return value;

    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;

    return '${_monthName(month)} $year';
  }

  List<String> _extractGrades(List<Course> courses) {
    final grades = <String>{};

    for (final course in courses) {
      final rawGrades = course.grade.split(',');
      for (final grade in rawGrades) {
        final cleanGrade = grade.trim();
        if (cleanGrade.isNotEmpty) {
          grades.add(cleanGrade);
        }
      }
    }

    final sortedGrades = grades.toList()..sort();
    return _uniqueItems(['الكل', ...sortedGrades]);
  }

  List<Course> _filterCourses(List<Course> courses) {
    return courses.where((course) {
      final search = _searchText.trim().toLowerCase();

      final matchesSearch = search.isEmpty ||
          course.title.toLowerCase().contains(search) ||
          course.instructorsText.toLowerCase().contains(search) ||
          course.location.toLowerCase().contains(search) ||
          course.grade.toLowerCase().contains(search);

      final courseMonth = '${course.date.year}-${course.date.month}';
      final matchesMonth =
          _selectedMonth == 'الكل' || courseMonth == _selectedMonth;

      final courseGrades =
          course.grade.split(',').map((grade) => grade.trim()).toList();

      final matchesGrade =
          _selectedGrade == 'الكل' || courseGrades.contains(_selectedGrade);

      return matchesSearch && matchesMonth && matchesGrade;
    }).toList();
  }

  Color _statusColor(Course course) {
    if (course.isFull) return Colors.red;
    if (course.isRegistrationExpired) return Colors.grey.shade700;
    if (course.isEndingSoon) return Colors.orange.shade800;
    if (course.isRegistrationOpen) return Colors.green.shade700;
    return deepPurple;
  }

  IconData _statusIcon(Course course) {
    if (course.isFull) return Icons.event_busy_rounded;
    if (course.isRegistrationExpired) return Icons.lock_clock_rounded;
    if (course.isEndingSoon) return Icons.warning_amber_rounded;
    if (course.isRegistrationOpen) return Icons.check_circle_rounded;
    return Icons.info_rounded;
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            deepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الدورات التدريبية المعلنة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'شركة توزيع المنتجات النفطية / فرع البصرة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'تابع أحدث الدورات وسجّل بالدورة المناسبة لدرجتك الوظيفية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters({
    required List<String> months,
    required List<String> grades,
  }) {
    final safeMonths = _uniqueItems(months);
    final safeGrades = _uniqueItems(grades);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: darkPurple.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'ابحث عن دورة، محاضر، مكان...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search_rounded, color: deepPurple),
              filled: true,
              fillColor: lightBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 650;

              final monthFilter = _buildDropdown(
                title: 'الشهر',
                icon: Icons.calendar_month_rounded,
                value: _safeDropdownValue(_selectedMonth, safeMonths),
                items: safeMonths,
                displayText: _displayMonth,
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value ?? 'الكل';
                  });
                },
              );

              final gradeFilter = _buildDropdown(
                title: 'الدرجة الوظيفية',
                icon: Icons.badge_rounded,
                value: _safeDropdownValue(_selectedGrade, safeGrades),
                items: safeGrades,
                displayText: (value) => value == 'الكل' ? 'كل الدرجات' : value,
                onChanged: (value) {
                  setState(() {
                    _selectedGrade = value ?? 'الكل';
                  });
                },
              );

              if (isWide) {
                return Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(child: monthFilter),
                    const SizedBox(width: 12),
                    Expanded(child: gradeFilter),
                  ],
                );
              }

              return Column(
                children: [
                  monthFilter,
                  const SizedBox(height: 12),
                  gradeFilter,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String Function(String value) displayText,
    required void Function(String?) onChanged,
  }) {
    final safeItems = _uniqueItems(items);
    final safeValue = value != null && safeItems.contains(value) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkPurple.withOpacity(0.08),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: Colors.white,
          alignment: AlignmentDirectional.centerEnd,
          items: safeItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(icon, color: deepPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayText(item),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text(title),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 58),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'قائمة الدورات المتاحة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: darkPurple,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'عدد النتائج الحالية: $count',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    softPurple.withOpacity(0.22),
                    deepPurple.withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.view_agenda_rounded,
                color: deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: darkPurple.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 17, color: deepPurple),
          const SizedBox(width: 6),
          Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Course course) {
    final color = _statusColor(course);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(_statusIcon(course), color: color, size: 18),
          const SizedBox(width: 7),
          Text(
            course.registrationStatusText,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsBox(Course course) {
    final remaining = course.remainingSeats < 0 ? 0 : course.remainingSeats;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: darkPurple.withOpacity(0.08)),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildInfoChip(
            icon: Icons.event_seat_rounded,
            text: 'المقاعد: ${course.capacity}',
          ),
          _buildInfoChip(
            icon: Icons.groups_rounded,
            text: 'المسجلين: ${course.registeredCount}',
          ),
          _buildInfoChip(
            icon: Icons.chair_alt_rounded,
            text: 'المتبقي: $remaining',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: darkPurple.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [blackColor, darkPurple, softPurple],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 70),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                course.title,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: darkPurple,
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'الدرجة المستهدفة: ${course.grade}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [darkPurple, deepPurple],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 29,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildStatusBadge(course),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        icon: Icons.groups_rounded,
                        text: course.instructorsText,
                      ),
                      _buildInfoChip(
                        icon: Icons.location_on_rounded,
                        text: course.location,
                      ),
                      _buildInfoChip(
                        icon: Icons.calendar_month_rounded,
                        text: _formatDate(course.date),
                      ),
                      _buildInfoChip(
                        icon: Icons.access_time_rounded,
                        text: course.time,
                      ),
                      _buildInfoChip(
                        icon: Icons.timelapse_rounded,
                        text: course.duration,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSeatsBox(course),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailsScreen(
                              course: course,
                              user: widget.user,
                            ),
                          ),
                        );

                        if (mounted) {
                          _refreshCourses();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: TextDirection.rtl,
                        children: [
                          Icon(Icons.visibility_rounded, size: 21),
                          SizedBox(width: 8),
                          Text('عرض تفاصيل الدورة'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return ListView(
      children: [
        _buildHeader(),
        const SizedBox(height: 60),
        const Center(
          child: CircularProgressIndicator(
            color: deepPurple,
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'جاري تحميل الدورات المعلنة...',
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(Object? error) {
    return ListView(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.20),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red,
                  size: 42,
                ),
                const SizedBox(height: 12),
                const Text(
                  'تعذر تحميل الدورات حالياً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _refreshCourses,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return ListView(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: darkPurple.withOpacity(0.10),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color: deepPurple,
                  size: 48,
                ),
                SizedBox(height: 14),
                Text(
                  'لا توجد دورات مطابقة حالياً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'جرّب تغيير البحث أو الفلاتر لعرض نتائج أخرى.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoFilteredResultsView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: darkPurple.withOpacity(0.10),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: deepPurple,
              size: 46,
            ),
            SizedBox(height: 14),
            Text(
              'لا توجد نتائج حسب البحث الحالي',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkPurple,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'غيّري كلمة البحث أو الفلتر لعرض دورات أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: blackColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الدورات التدريبية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refreshCourses,
            ),
          ],
        ),
        body: FutureBuilder<List<Course>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingView();
            }

            if (snapshot.hasError) {
              return _buildErrorView(snapshot.error);
            }

            final allCourses = (snapshot.data ?? []).where((course) {
              return course.title.trim().isNotEmpty &&
                  course.date.year > 2000;
            }).toList();

            // واجهة الموظف تعرض فقط الدورات التي ما زال التسجيل عليها متاحاً
            // أو ممتلئة/تنتهي قريباً، ولا تعرض الدورات التي انتهى التسجيل عليها.
            // لا يتم حذف أي دورة من قاعدة البيانات، فقط إخفاؤها من هذه الصفحة.
            final availableCourses = allCourses.where((course) {
              return !course.isRegistrationExpired;
            }).toList();

            if (availableCourses.isEmpty) {
              return _buildEmptyView();
            }

            final months = _extractMonths(availableCourses);
            final grades = _extractGrades(availableCourses);

            if (!months.contains(_selectedMonth)) {
              _selectedMonth = 'الكل';
            }

            if (!grades.contains(_selectedGrade)) {
              _selectedGrade = 'الكل';
            }

            final filteredCourses = _filterCourses(availableCourses);

            return RefreshIndicator(
              color: deepPurple,
              onRefresh: _refreshCourses,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 18),
                itemCount:
                    filteredCourses.isEmpty ? 4 : filteredCourses.length + 3,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHeader();

                  if (index == 1) {
                    return _buildSearchAndFilters(
                      months: months,
                      grades: grades,
                    );
                  }

                  if (index == 2) {
                    return _buildSectionTitle(filteredCourses.length);
                  }

                  if (filteredCourses.isEmpty) {
                    return _buildNoFilteredResultsView();
                  }

                  final course = filteredCourses[index - 3];
                  return _buildCourseCard(context, course);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}