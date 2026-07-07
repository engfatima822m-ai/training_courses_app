import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/admin_dashboard.dart';
import 'package:training_courses_app/screens/courses_list_screen.dart';
import 'package:training_courses_app/screens/instructor_dashboard.dart';
import 'package:training_courses_app/screens/splash_screen.dart';
import 'package:training_courses_app/features/employee/employee_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String trainingUsername = 'admin';
  static const String trainingPassword = 'admin123';

  final Color blackColor = const Color(0xFF111111);
  final Color darkPurple = const Color(0xFF2D033B);
  final Color deepPurple = const Color(0xFF4B0082);
  final Color softPurple = const Color(0xFF7B2CBF);

  String get instructorLoginUrl {
    return 'http://localhost/training_api/instructor_login.php';
  }

  User _buildGuestUser() {
    return User(
      fullName: 'شركة توزيع المنتجات النفطية / فرع البصرة',
      employeeId: 'GUEST',
      grade: 0,
      role: 'employee',
      isAdmin: false,
      workPlace: 'فرع البصرة',
      nextDueDate: null,
    );
  }

  User _buildTrainingStaffUser() {
    return User(
      fullName: 'شعبة التدريب',
      employeeId: 'TRAINING_STAFF',
      grade: 0,
      role: 'training_staff',
      isAdmin: true,
      workPlace: 'شركة توزيع المنتجات النفطية / فرع البصرة',
      nextDueDate: null,
    );
  }

  User _buildInstructorUser({
    required String name,
    required String id,
  }) {
    return User(
      fullName: name,
      employeeId: id,
      grade: 0,
      role: 'instructor',
      isAdmin: false,
      workPlace: 'شركة توزيع المنتجات النفطية / فرع البصرة',
      nextDueDate: null,
    );
  }

  Future<User> _loginInstructorFromApi({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse(instructorLoginUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data['success'] == true) {
      final instructor = data['instructor'];

      return _buildInstructorUser(
        name: instructor['name'].toString(),
        id: instructor['id'].toString(),
      );
    } else {
      throw Exception(data['message'] ?? 'بيانات الدخول غير صحيحة');
    }
  }

  void _goToSplash() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  void _openEmployeeCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDashboard(user: _buildGuestUser()),
      ),
    );
  }

  void _openRoleLogin({
    required String title,
    required String subtitle,
    required IconData icon,
    required Future<User?> Function(String username, String password) loginAction,
    required void Function(User? user) onSuccess,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _RoleLoginPage(
          title: title,
          subtitle: subtitle,
          icon: icon,
          loginAction: loginAction,
          onSuccess: onSuccess,
          blackColor: blackColor,
          darkPurple: darkPurple,
          deepPurple: deepPurple,
          softPurple: softPurple,
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.22),
                        softPurple.withOpacity(0.35),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white.withOpacity(0.74),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: darkPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      Icons.arrow_back_rounded,
                      color: darkPurple,
                      size: 20,
                    ),
                  ],
                ),
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
        backgroundColor: blackColor,
        appBar: AppBar(
          backgroundColor: blackColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'بوابة الدورات التدريبية',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToSplash,
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                blackColor,
                darkPurple,
                deepPurple,
                blackColor,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 68,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'نظام إدارة الدورات التدريبية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'شركة توزيع المنتجات النفطية / فرع البصرة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 34),

                    _buildPortalCard(
                      icon: Icons.groups_rounded,
                      title: 'دخول الموظفين',
                      subtitle:
                          'عرض الدورات التدريبية المعلنة والتفاصيل المتاحة بدون تسجيل دخول.',
                      buttonText: 'عرض الدورات',
                      onTap: _openEmployeeCourses,
                    ),

                    _buildPortalCard(
                      icon: Icons.person_pin_rounded,
                      title: 'دخول المحاضرين',
                      subtitle:
                          'خاص بالمحاضر لمشاهدة الدورات المكلف بها وأعداد المسجلين.',
                      buttonText: 'تسجيل دخول المحاضر',
                      onTap: () {
                        _openRoleLogin(
                          title: 'دخول المحاضر',
                          subtitle: 'يرجى إدخال اسم المستخدم وكلمة المرور',
                          icon: Icons.person_pin_rounded,
                          loginAction: (username, password) async {
                            return await _loginInstructorFromApi(
                              username: username,
                              password: password,
                            );
                          },
                          onSuccess: (user) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InstructorDashboard(
                                  user: user!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    _buildPortalCard(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'دخول شعبة التدريب',
                      subtitle:
                          'خاص بإدارة الدورات وإضافة الدورات الجديدة ومتابعة المسجلين.',
                      buttonText: 'تسجيل دخول الشعبة',
                      onTap: () {
                        _openRoleLogin(
                          title: 'دخول شعبة التدريب',
                          subtitle: 'يرجى إدخال اسم المستخدم وكلمة المرور',
                          icon: Icons.admin_panel_settings_rounded,
                          loginAction: (username, password) async {
                            if (username == trainingUsername &&
                                password == trainingPassword) {
                              return _buildTrainingStaffUser();
                            }
                            throw Exception('اسم المستخدم أو كلمة المرور غير صحيحة');
                          },
                          onSuccess: (user) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminDashboard(
                                  user: user!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'نسخة تجريبية للعرض الأولي على المسؤول',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleLoginPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Future<User?> Function(String username, String password) loginAction;
  final void Function(User? user) onSuccess;

  final Color blackColor;
  final Color darkPurple;
  final Color deepPurple;
  final Color softPurple;

  const _RoleLoginPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.loginAction,
    required this.onSuccess,
    required this.blackColor,
    required this.darkPurple,
    required this.deepPurple,
    required this.softPurple,
  });

  @override
  State<_RoleLoginPage> createState() => _RoleLoginPageState();
}

class _RoleLoginPageState extends State<_RoleLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يرجى إدخال اسم المستخدم وكلمة المرور',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await widget.loginAction(username, password);

      if (!mounted) return;
      widget.onSuccess(user);
    } catch (e) {
      if (!mounted) return;

      String message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.black.withOpacity(0.25),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: widget.blackColor,
        appBar: AppBar(
          backgroundColor: widget.blackColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                widget.blackColor,
                widget.darkPurple,
                widget.deepPurple,
                widget.blackColor,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.13),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 62,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _usernameController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'اسم المستخدم',
                          icon: Icons.person_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'كلمة المرور',
                          icon: Icons.lock_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: widget.darkPurple,
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Icon(Icons.login_rounded),
                                    SizedBox(width: 8),
                                    Text('تسجيل الدخول'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(Icons.arrow_back_rounded),
                              SizedBox(width: 7),
                              Text('الرجوع إلى البوابة الرئيسية'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}