import 'package:flutter/material.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/courses_list_screen.dart';
import 'package:training_courses_app/screens/instructor_dashboard.dart';
import 'package:training_courses_app/screens/admin_dashboard.dart';
import 'package:training_courses_app/screens/splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _trainingPasswordController =
      TextEditingController();
  final TextEditingController _instructorPasswordController =
      TextEditingController();

  bool _showTrainingPassword = false;
  bool _showInstructorPassword = false;

  static const String trainingStaffPassword = 'admin123';
  static const String instructorPassword = 'trainer123';

  final Color darkPurple = const Color(0xFF2D033B);
  final Color deepPurple = const Color(0xFF4B0082);
  final Color blackColor = const Color(0xFF111111);

  @override
  void dispose() {
    _trainingPasswordController.dispose();
    _instructorPasswordController.dispose();
    super.dispose();
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

  User _buildInstructorUser() {
    return User(
      fullName: 'المحاضر',
      employeeId: 'INSTRUCTOR',
      grade: 0,
      role: 'instructor',
      isAdmin: false,
      workPlace: 'شركة توزيع المنتجات النفطية / فرع البصرة',
      nextDueDate: null,
    );
  }

  void _goToSplash() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
    );
  }

  void _openEmployeeCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursesListScreen(user: _buildGuestUser()),
      ),
    );
  }

  void _loginTrainingStaff() {
    if (_trainingPasswordController.text.trim() != trainingStaffPassword) {
      _showMessage('كلمة مرور شعبة التدريب غير صحيحة');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminDashboard(user: _buildTrainingStaffUser()),
      ),
    );
  }

  void _loginInstructor() {
    if (_instructorPasswordController.text.trim() != instructorPassword) {
      _showMessage('كلمة مرور المحاضر غير صحيحة');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructorDashboard(user: _buildInstructorUser()),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Widget _buildAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.14),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black.withOpacity(0.25),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white, width: 1.4),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.white70,
        ),
        onPressed: onToggle,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: darkPurple,
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
          title: const Text('بوابة الدورات التدريبية'),
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
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'نظام الدورات التدريبية',
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
                    const SizedBox(height: 30),

                    _buildAccessCard(
                      icon: Icons.campaign_rounded,
                      title: 'عرض الدورات المعلنة',
                      subtitle:
                          'الدخول العام للموظفين للاطلاع على دورات هذا الشهر بدون تسجيل دخول.',
                      child: _buildButton(
                        text: 'شركة توزيع المنتجات النفطية / فرع البصرة',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _openEmployeeCourses,
                      ),
                    ),

                    _buildAccessCard(
                      icon: Icons.person_pin_rounded,
                      title: 'دخول المحاضر',
                      subtitle:
                          'خاص بالمحاضر لمتابعة الدورات المرتبطة به لاحقاً.',
                      child: Column(
                        children: [
                          TextField(
                            controller: _instructorPasswordController,
                            obscureText: !_showInstructorPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _passwordDecoration(
                              label: 'كلمة مرور المحاضر',
                              isVisible: _showInstructorPassword,
                              onToggle: () {
                                setState(() {
                                  _showInstructorPassword =
                                      !_showInstructorPassword;
                                });
                              },
                            ),
                            onSubmitted: (_) => _loginInstructor(),
                          ),
                          const SizedBox(height: 12),
                          _buildButton(
                            text: 'دخول المحاضر',
                            icon: Icons.login_rounded,
                            outlined: true,
                            onPressed: _loginInstructor,
                          ),
                        ],
                      ),
                    ),

                    _buildAccessCard(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'دخول شعبة التدريب',
                      subtitle:
                          'خاص بإدارة الدورات وإضافة الدورات الجديدة ومتابعة البيانات.',
                      child: Column(
                        children: [
                          TextField(
                            controller: _trainingPasswordController,
                            obscureText: !_showTrainingPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _passwordDecoration(
                              label: 'كلمة مرور شعبة التدريب',
                              isVisible: _showTrainingPassword,
                              onToggle: () {
                                setState(() {
                                  _showTrainingPassword =
                                      !_showTrainingPassword;
                                });
                              },
                            ),
                            onSubmitted: (_) => _loginTrainingStaff(),
                          ),
                          const SizedBox(height: 12),
                          _buildButton(
                            text: 'دخول شعبة التدريب',
                            icon: Icons.manage_accounts_rounded,
                            outlined: true,
                            onPressed: _loginTrainingStaff,
                          ),
                        ],
                      ),
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