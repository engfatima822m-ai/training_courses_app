import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/courses_list_screen.dart';
import 'package:training_courses_app/screens/registration_request_preview_screen.dart';
import 'package:training_courses_app/services/api_service.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final Course course;
  final User user;

  const CourseRegistrationScreen({
    super.key,
    required this.course,
    required this.user,
  });

  @override
  State<CourseRegistrationScreen> createState() =>
      _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color softPurple = Color(0xFF7B2CBF);
  static const Color lightBackground = Color(0xFFF6F2FA);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _workPlaceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isRegistered = false;
  bool _isLoading = false;
  User? _registeredUser;

  @override
  void initState() {
    super.initState();

    if (widget.user.employeeId != 'GUEST') {
      _nameController.text = widget.user.fullName;
      _employeeIdController.text = widget.user.employeeId;
      _gradeController.text = widget.user.grade.toString();
      _workPlaceController.text = widget.user.workPlace;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _gradeController.dispose();
    _workPlaceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  User _buildEmployeeUser() {
    return User(
      fullName: _nameController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      grade: int.tryParse(_gradeController.text.trim()) ?? 0,
      role: 'employee',
      isAdmin: false,
      workPlace: _workPlaceController.text.trim(),
      nextDueDate: null,
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final employeeUser = _buildEmployeeUser();

    try {
      final bool success = await ApiService.registerToCourse(
        employeeId: employeeUser.employeeId,
        courseId: widget.course.id,
      );

      setState(() {
        _isLoading = false;
        _isRegistered = success;
        _registeredUser = employeeUser;
      });

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر التسجيل أو أن الموظف مسجل مسبقاً في هذه الدورة',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء التسجيل: $e',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openRequestPdf() {
    final userForPdf = _registeredUser ?? _buildEmployeeUser();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationRequestPreviewScreen(
          user: userForPdf,
          course: widget.course,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: deepPurple),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: darkPurple.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: darkPurple.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: deepPurple, width: 1.4),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  String? _gradeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (int.tryParse(value.trim()) == null) {
      return 'اكتبي الدرجة كرقم فقط';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: blackColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'التسجيل في الدورة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isRegistered ? _buildSuccessView() : _buildRegistrationForm(),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: darkPurple.withOpacity(0.10)),
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
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    decoration: _inputDecoration(
                      label: 'اسم الموظف الثلاثي',
                      icon: Icons.person_rounded,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _employeeIdController,
                    textAlign: TextAlign.right,
                    decoration: _inputDecoration(
                      label: 'الرقم الوظيفي / البصمة',
                      icon: Icons.badge_rounded,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _gradeController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'الدرجة الوظيفية',
                      icon: Icons.workspace_premium_rounded,
                      hint: 'مثال: 4',
                    ),
                    validator: _gradeValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _workPlaceController,
                    textAlign: TextAlign.right,
                    decoration: _inputDecoration(
                      label: 'مكان العمل / القسم',
                      icon: Icons.business_rounded,
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: 'رقم الهاتف',
                      icon: Icons.phone_rounded,
                      hint: 'اختياري',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleRegistration,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.how_to_reg_rounded),
                      label: Text(
                        _isLoading ? 'جاري التسجيل...' : 'تأكيد التسجيل',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.assignment_rounded, color: Colors.white, size: 38),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'معلومات الموظف',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.course.title,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.info_rounded, color: Colors.white, size: 19),
                SizedBox(width: 7),
                Text(
                  'املأ معلومات الموظف لإكمال التسجيل وإصدار الطلب',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.green.withOpacity(0.25)),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 88,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'تم التسجيل بنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.course.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'يمكنك الآن فتح طلب التسجيل بصيغة PDF لطباعته أو مشاركته.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _openRequestPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('فتح طلب التسجيل PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CoursesListScreen(user: _registeredUser!),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('العودة إلى الدورات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkPurple,
                      side: BorderSide(color: darkPurple.withOpacity(0.28)),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}