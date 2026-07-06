import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/core/widgets/common/app_page_header.dart';

class ManageInstructorsScreen extends StatefulWidget {
  final bool showScaffold;

  const ManageInstructorsScreen({
    super.key,
    this.showScaffold = true,
  });

  @override
  State<ManageInstructorsScreen> createState() =>
      _ManageInstructorsScreenState();
}

class _ManageInstructorsScreenState extends State<ManageInstructorsScreen> {
  final String baseUrl = 'http://localhost/training_api';

  bool isLoading = true;
  List instructors = [];
  List filteredInstructors = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInstructors();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchInstructors() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_instructors.php'),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;

      setState(() {
        instructors = data['success'] == true ? data['data'] ?? [] : [];
        filteredInstructors = instructors;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        instructors = [];
        filteredInstructors = [];
        isLoading = false;
      });

      _showMessage('فشل الاتصال بالسيرفر', AppColors.danger);
    }
  }

  void filterInstructors(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredInstructors = instructors;
      } else {
        filteredInstructors = instructors.where((item) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          final phone = item['phone']?.toString().toLowerCase() ?? '';
          final specialization =
              item['specialization']?.toString().toLowerCase() ?? '';
          final username = item['username']?.toString().toLowerCase() ?? '';

          return name.contains(query) ||
              phone.contains(query) ||
              specialization.contains(query) ||
              username.contains(query);
        }).toList();
      }
    });
  }

  Future<void> addInstructor({
    required String name,
    required String phone,
    required String specialization,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_instructor.php'),
      body: {
        'name': name,
        'phone': phone,
        'specialization': specialization,
        'username': username,
        'password': password,
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    _showMessage(
      data['message'] ?? 'تمت العملية',
      data['success'] == true ? AppColors.success : AppColors.danger,
    );

    if (data['success'] == true) {
      searchController.clear();
      await fetchInstructors();
    }
  }

  Future<void> updateInstructor({
    required String id,
    required String name,
    required String phone,
    required String specialization,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_instructor.php'),
      body: {
        'id': id,
        'name': name,
        'phone': phone,
        'specialization': specialization,
        'username': username,
        'password': password,
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    _showMessage(
      data['message'] ?? 'تمت العملية',
      data['success'] == true ? AppColors.success : AppColors.danger,
    );

    if (data['success'] == true) {
      searchController.clear();
      await fetchInstructors();
    }
  }

  Future<void> deleteInstructor(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_instructor.php'),
      body: {'id': id},
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    _showMessage(
      data['message'] ?? 'تمت العملية',
      data['success'] == true ? AppColors.success : AppColors.danger,
    );

    if (data['success'] == true) {
      searchController.clear();
      await fetchInstructors();
    }
  }

  int _getCoursesCount(Map instructor) {
    final value = instructor['courses_count'] ??
        instructor['course_count'] ??
        instructor['coursesCount'] ??
        0;

    return int.tryParse(value.toString()) ?? 0;
  }

  List<String> _getCoursesNames(Map instructor) {
    final value = instructor['courses_names'] ??
        instructor['course_names'] ??
        instructor['courses'] ??
        instructor['courses_titles'];

    if (value == null) return [];

    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return value
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: color,
      ),
    );
  }

  void _openInstructorDialog({Map? instructor}) {
    final nameController =
        TextEditingController(text: instructor?['name']?.toString() ?? '');
    final phoneController =
        TextEditingController(text: instructor?['phone']?.toString() ?? '');
    final specializationController = TextEditingController(
      text: instructor?['specialization']?.toString() ?? '',
    );
    final usernameController =
        TextEditingController(text: instructor?['username']?.toString() ?? '');
    final passwordController =
        TextEditingController(text: instructor?['password']?.toString() ?? '');

    final isEdit = instructor != null;

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
            ),
            title: Text(
              isEdit ? 'تعديل بيانات المحاضر' : 'إضافة محاضر جديد',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _dialogField('اسم المحاضر', nameController),
                    _dialogField('رقم الهاتف', phoneController),
                    _dialogField('الاختصاص', specializationController),
                    _dialogField('اسم المستخدم', usernameController),
                    _dialogField('كلمة المرور', passwordController),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.start,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurple,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
                  ),
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final specialization = specializationController.text.trim();
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();

                  if (name.isEmpty || username.isEmpty || password.isEmpty) {
                    _showMessage(
                      'الاسم واسم المستخدم وكلمة المرور مطلوبة',
                      AppColors.danger,
                    );
                    return;
                  }

                  Navigator.pop(context);

                  if (isEdit) {
                    await updateInstructor(
                      id: instructor['id'].toString(),
                      name: name,
                      phone: phone,
                      specialization: specialization,
                      username: username,
                      password: password,
                    );
                  } else {
                    await addInstructor(
                      name: name,
                      phone: phone,
                      specialization: specialization,
                      username: username,
                      password: password,
                    );
                  }
                },
                child: Text(isEdit ? 'حفظ التعديل' : 'إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          filled: true,
          fillColor: AppColors.lightPurple,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
            borderSide: const BorderSide(
              color: AppColors.softPurple,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map instructor) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
            ),
            title: const Text(
              'تأكيد الحذف',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'هل تريدين حذف المحاضر: ${instructor['name']} ؟',
              textAlign: TextAlign.right,
            ),
            actionsAlignment: MainAxisAlignment.start,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deleteInstructor(instructor['id'].toString());
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppPageHeader(
          title: 'إدارة المحاضرين',
          subtitle: 'إضافة وتعديل حسابات المحاضرين ومتابعة الدورات المرتبطة بهم',
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Wrap(
            textDirection: TextDirection.rtl,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _statBox('عدد المحاضرين', instructors.length.toString()),
              _statBox('نتائج البحث', filteredInstructors.length.toString()),
              ElevatedButton.icon(
                onPressed: () => _openInstructorDialog(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة محاضر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurple,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.darkPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      onChanged: filterInstructors,
      decoration: InputDecoration(
        hintText: 'ابحث باسم المحاضر أو الهاتف أو الاختصاص أو اسم المستخدم...',
        hintTextDirection: TextDirection.rtl,
        prefixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  filterInstructors('');
                },
              ),
        suffixIcon: const Icon(Icons.search, color: AppColors.softPurple),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _instructorCard(Map instructor) {
    final coursesCount = _getCoursesCount(instructor);
    final coursesNames = _getCoursesNames(instructor);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.lightPurple,
                child: Text(
                  (instructor['name']?.toString().isNotEmpty ?? false)
                      ? instructor['name'].toString()[0]
                      : 'م',
                  style: const TextStyle(
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      instructor['name']?.toString() ?? '',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.darkPurple,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.itemSpacing,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightPurple,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$coursesCount دورة',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: AppColors.softPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          _info('الهاتف', instructor['phone'], Icons.phone_rounded),
          _info(
            'الاختصاص',
            instructor['specialization'],
            Icons.workspace_premium_rounded,
          ),
          _info(
            'اسم المستخدم',
            instructor['username'],
            Icons.account_circle_rounded,
          ),
          _info('كلمة المرور', instructor['password'], Icons.lock_rounded),
          const SizedBox(height: AppSpacing.sm),
          _coursesSection(coursesNames),
          const SizedBox(height: AppSpacing.itemSpacing),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openInstructorDialog(instructor: instructor),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('تعديل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepPurple,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(instructor),
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('حذف'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coursesSection(List<String> coursesNames) {
    if (coursesNames.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.itemSpacing),
        decoration: BoxDecoration(
          color: AppColors.lightPurple,
          borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
        ),
        child: const Text(
          'لا توجد دورات مرتبطة بهذا المحاضر حالياً',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.itemSpacing),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(AppSpacing.itemSpacing),
      ),
      child: Wrap(
        textDirection: TextDirection.rtl,
        alignment: WrapAlignment.start,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: coursesNames.map((course) {
          return Chip(
            label: Text(course),
            backgroundColor: AppColors.white,
            labelStyle: const TextStyle(color: AppColors.darkPurple),
          );
        }).toList(),
      ),
    );
  }

  Widget _info(String label, dynamic value, IconData icon) {
    final text = value?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18, color: AppColors.softPurple),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text.isEmpty ? 'غير محدد' : text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }

  Widget _bodyContent() {
    return RefreshIndicator(
      color: AppColors.deepPurple,
      onRefresh: fetchInstructors,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _header(),
          const SizedBox(height: AppSpacing.md),
          _searchBox(),
          const SizedBox(height: AppSpacing.lg),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: CircularProgressIndicator(color: AppColors.deepPurple),
              ),
            )
          else if (instructors.isEmpty)
            _emptyBox('لا يوجد محاضرون حالياً')
          else if (filteredInstructors.isEmpty)
            _emptyBox('لا توجد نتائج مطابقة للبحث')
          else
            ...filteredInstructors.map((item) => _instructorCard(item)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: widget.showScaffold
          ? Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.darkPurple,
                foregroundColor: AppColors.white,
                centerTitle: true,
                title: const Text(
                  'إدارة المحاضرين',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: fetchInstructors,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: AppColors.darkPurple,
                foregroundColor: AppColors.white,
                onPressed: () => _openInstructorDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة محاضر'),
              ),
              body: _bodyContent(),
            )
          : _bodyContent(),
    );
  }
}
