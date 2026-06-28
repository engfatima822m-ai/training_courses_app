import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageInstructorsScreen extends StatefulWidget {
  const ManageInstructorsScreen({super.key});

  @override
  State<ManageInstructorsScreen> createState() =>
      _ManageInstructorsScreenState();
}

class _ManageInstructorsScreenState extends State<ManageInstructorsScreen> {
  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color lightPurple = Color(0xFFF6F2FA);

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

      setState(() {
        instructors = data['success'] == true ? data['data'] ?? [] : [];
        filteredInstructors = instructors;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        instructors = [];
        filteredInstructors = [];
        isLoading = false;
      });
      _showMessage('فشل الاتصال بالسيرفر', Colors.red);
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
      data['success'] == true ? Colors.green : Colors.red,
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
      data['success'] == true ? Colors.green : Colors.red,
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
      data['success'] == true ? Colors.green : Colors.red,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
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
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isEdit ? 'تعديل بيانات المحاضر' : 'إضافة محاضر جديد',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 450,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final specialization =
                      specializationController.text.trim();
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();

                  if (name.isEmpty || username.isEmpty || password.isEmpty) {
                    _showMessage(
                      'الاسم واسم المستخدم وكلمة المرور مطلوبة',
                      Colors.red,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: lightPurple,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
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
            title: const Text('تأكيد الحذف'),
            content: Text(
              'هل تريدين حذف المحاضر: ${instructor['name']} ؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [blackColor, darkPurple, blackColor],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'إدارة المحاضرين',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'إضافة وتعديل حسابات المحاضرين ومتابعة الدورات المرتبطة بهم',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _statBox('عدد المحاضرين', instructors.length.toString()),
              const SizedBox(width: 10),
              _statBox('نتائج البحث', filteredInstructors.length.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      textAlign: TextAlign.right,
      onChanged: filterInstructors,
      decoration: InputDecoration(
        hintText: 'ابحث باسم المحاضر أو الهاتف أو الاختصاص أو اسم المستخدم...',
        prefixIcon: const Icon(Icons.search, color: deepPurple),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  filterInstructors('');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _instructorCard(Map instructor) {
    final coursesCount = _getCoursesCount(instructor);
    final coursesNames = _getCoursesNames(instructor);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: lightPurple,
                  child: Text(
                    (instructor['name']?.toString().isNotEmpty ?? false)
                        ? instructor['name'].toString()[0]
                        : 'م',
                    style: const TextStyle(
                      color: darkPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        instructor['name']?.toString() ?? '',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: darkPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: lightPurple,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '$coursesCount دورة',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: deepPurple,
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
            const Divider(height: 24),
            _info('الهاتف', instructor['phone']),
            _info('الاختصاص', instructor['specialization']),
            _info('اسم المستخدم', instructor['username']),
            _info('كلمة المرور', instructor['password']),
            const SizedBox(height: 8),
            _coursesSection(coursesNames),
            const SizedBox(height: 14),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openInstructorDialog(instructor: instructor),
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(instructor),
                    icon: const Icon(Icons.delete),
                    label: const Text('حذف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coursesSection(List<String> coursesNames) {
    if (coursesNames.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lightPurple,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'لا توجد دورات مرتبطة بهذا المحاضر حالياً',
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        textDirection: TextDirection.rtl,
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: coursesNames.map((course) {
          return Chip(
            label: Text(course),
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: darkPurple),
          );
        }).toList(),
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    final text = value?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$label: ${text.isEmpty ? 'غير محدد' : text}',
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightPurple,
        appBar: AppBar(
          backgroundColor: blackColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'إدارة المحاضرين',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: fetchInstructors,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: darkPurple,
          foregroundColor: Colors.white,
          onPressed: () => _openInstructorDialog(),
          icon: const Icon(Icons.add),
          label: const Text('إضافة محاضر'),
        ),
        body: RefreshIndicator(
          onRefresh: fetchInstructors,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(),
              const SizedBox(height: 16),
              _searchBox(),
              const SizedBox(height: 18),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: deepPurple),
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
        ),
      ),
    );
  }
}