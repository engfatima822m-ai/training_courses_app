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

  @override
  void initState() {
    super.initState();
    fetchInstructors();
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        instructors = [];
        isLoading = false;
      });
      _showMessage('فشل الاتصال بالسيرفر', Colors.red);
    }
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
      fetchInstructors();
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
      fetchInstructors();
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
      fetchInstructors();
    }
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.groups_rounded, color: Colors.white, size: 48),
          SizedBox(height: 12),
          Text(
            'إدارة المحاضرين',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'إضافة وتعديل حسابات المحاضرين المرتبطين بالدورات',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _instructorCard(Map instructor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
            _info('الهاتف', instructor['phone']),
            _info('الاختصاص', instructor['specialization']),
            _info('اسم المستخدم', instructor['username']),
            _info('كلمة المرور', instructor['password']),
            const SizedBox(height: 12),
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

  Widget _info(String label, dynamic value) {
    final text = value?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        '$label: ${text.isEmpty ? 'غير محدد' : text}',
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.black54),
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
              const SizedBox(height: 18),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: deepPurple),
                  ),
                )
              else if (instructors.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'لا يوجد محاضرون حالياً',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...instructors.map((item) => _instructorCard(item)),
            ],
          ),
        ),
      ),
    );
  }
}