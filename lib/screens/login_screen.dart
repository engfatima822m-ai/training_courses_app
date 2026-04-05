import 'package:flutter/material.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/services/data_service.dart';
import 'package:training_courses_app/services/api_service.dart';
import 'package:training_courses_app/screens/courses_list_screen.dart';
import 'package:training_courses_app/screens/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  bool _isLoading = false;

  static const String adminPassword = 'ADMIN001';

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  // ✅ (مؤقت) للتحقق من الاسم داخل القائمة فقط
  bool _isValidEmployeeName(String name) {
    return DataService.employees.any(
      (user) => user.fullName.trim() == name.trim(),
    );
  }

  // ==============================
  // 🔐 تسجيل الدخول عبر API
  // ==============================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.loginUser(
        fullName: _nameController.text.trim(),
        fingerprintId: _employeeIdController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        final userData = result['user'];

        final user = User(
          fullName: userData['full_name'],
          employeeId: userData['fingerprint_id'],
          grade: int.parse(userData['grade'].toString()),
          isAdmin: false,
        );

        final adminPasswordInput = _adminPasswordController.text.trim();

        setState(() {
          _isLoading = false;
        });

        // ✅ دخول عادي
        if (adminPasswordInput.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoursesListScreen(user: user),
            ),
          );
          return;
        }

        // ✅ دخول أدمن
        if (adminPasswordInput == adminPassword) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboard(user: user),
            ),
          );
          return;
        }

        // ❌ باسورد الأدمن خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة مرور الأدمن غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'بيانات غير صحيحة'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في الاتصال بالسيرفر'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'يرجى إدخال بيانات الموظف للدخول إلى نظام الدورات التدريبية في شركة توزيع المنتجات النفطية / فرع البصرة',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // 🔹 الاسم (Autocomplete)
                Autocomplete<User>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<User>.empty();
                    }

                    return DataService.employees.where(
                      (user) => user.fullName
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()),
                    );
                  },
                  displayStringForOption: (User option) => option.fullName,
                  onSelected: (User selection) {
                    _nameController.text = selection.fullName;
                    _employeeIdController.text = selection.employeeId;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'اسم الموظف',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _nameController.text = value;
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال الاسم';
                        }

                        if (!_isValidEmployeeName(value)) {
                          return 'يرجى اختيار اسم صحيح من القائمة';
                        }

                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 رقم البصمة
                TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'رقم البصمة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال رقم البصمة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'هذا الحقل خاص بموظف شعبة التدريب المسؤول عن التطبيق',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 🔹 باسورد الأدمن
                TextFormField(
                  controller: _adminPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة مرور الأدمن (اختياري)',
                    border: OutlineInputBorder(),
                    hintText: 'يترك فارغًا للدخول كموظف',
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 زر الدخول
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('تسجيل الدخول'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}