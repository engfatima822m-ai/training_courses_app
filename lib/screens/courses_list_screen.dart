import 'package:flutter/material.dart';
import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/core/widgets/common/app_page_header.dart';
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
    if (course.isFull) return AppColors.danger;
    if (course.isRegistrationExpired) return Colors.grey.shade700;
    if (course.isEndingSoon) return Colors.orange.shade800;
    if (course.isRegistrationOpen) return AppColors.success;
    return AppColors.deepPurple;
  }

  IconData _statusIcon(Course course) {
    if (course.isFull) return Icons.event_busy_rounded;
    if (course.isRegistrationExpired) return Icons.lock_clock_rounded;
    if (course.isEndingSoon) return Icons.warning_amber_rounded;
    if (course.isRegistrationOpen) return Icons.check_circle_rounded;
    return Icons.info_rounded;
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: AppPageHeader(
        title: 'الدورات التدريبية المعلنة',
        subtitle:
            'شركة توزيع المنتجات النفطية / فرع البصرة\nتابعي أحدث الدورات وسجّلي بالدورة المناسبة لدرجتك الوظيفية',
        icon: Icons.school_rounded,
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
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(
          color: AppColors.darkPurple.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحثي عن دورة، محاضر، مكان...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: _searchController.text.isEmpty
                  ? const Icon(Icons.search_rounded, color: AppColors.deepPurple)
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchText = '');
                      },
                    ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
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
                    const SizedBox(width: AppSpacing.itemSpacing),
                    Expanded(child: gradeFilter),
                  ],
                );
              }

              return Column(
                children: [
                  monthFilter,
                  const SizedBox(height: AppSpacing.itemSpacing),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(
          color: AppColors.darkPurple.withOpacity(0.08),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: AppColors.white,
          alignment: AlignmentDirectional.centerEnd,
          items: safeItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(icon, color: AppColors.deepPurple, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      displayText(item),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text(title, textAlign: TextAlign.right),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.itemSpacing,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.lightPurple,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            child: const Icon(
              Icons.view_agenda_rounded,
              color: AppColors.deepPurple,
            ),
          ),
          const SizedBox(width: AppSpacing.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                const Text(
                  'قائمة الدورات المتاحة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'عدد النتائج الحالية: $count',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.itemSpacing,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.darkPurple.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 17, color: AppColors.deepPurple),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              text.isEmpty ? 'غير محدد' : text,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Course course) {
    final color = _statusColor(course);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.itemSpacing,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(_statusIcon(course), color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            course.registrationStatusText,
            textAlign: TextAlign.right,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.darkPurple.withOpacity(0.08)),
      ),
      child: Wrap(
        textDirection: TextDirection.rtl,
        alignment: WrapAlignment.start,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
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
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(
          color: AppColors.darkPurple.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkPurple,
                    AppColors.deepPurple,
                    AppColors.softPurple,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.darkPurple,
                              AppColors.deepPurple,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadius),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.white,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.itemSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              course.title,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 18.5,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'الدرجة المستهدفة: ${course.grade}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.itemSpacing),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildStatusBadge(course),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    textDirection: TextDirection.rtl,
                    alignment: WrapAlignment.start,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
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
                  const SizedBox(height: AppSpacing.md),
                  _buildSeatsBox(course),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.visibility_rounded, size: 21),
                      label: const Text('عرض تفاصيل الدورة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPurple,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadius),
                        ),
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
            color: AppColors.deepPurple,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(
          child: Text(
            'جاري تحميل الدورات المعلنة...',
            style: TextStyle(
              color: AppColors.textDark,
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSpacing.cardPadding),
              border: Border.all(
                color: AppColors.danger.withOpacity(0.20),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.danger,
                  size: 42,
                ),
                const SizedBox(height: AppSpacing.itemSpacing),
                const Text(
                  'تعذر تحميل الدورات حالياً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: _refreshCourses,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPurple,
                    foregroundColor: AppColors.white,
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
              border: Border.all(
                color: AppColors.darkPurple.withOpacity(0.10),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.deepPurple,
                  size: 48,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'لا توجد دورات مطابقة حالياً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'جرّبي تغيير البحث أو الفلاتر لعرض نتائج أخرى.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
          border: Border.all(
            color: AppColors.darkPurple.withOpacity(0.10),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.deepPurple,
              size: 46,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد نتائج حسب البحث الحالي',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'غيّري كلمة البحث أو الفلتر لعرض دورات أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.darkPurple,
          foregroundColor: AppColors.white,
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
              return course.title.trim().isNotEmpty && course.date.year > 2000;
            }).toList();

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
              color: AppColors.deepPurple,
              onRefresh: _refreshCourses,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
