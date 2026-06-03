import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCourseScreenCustom extends StatefulWidget {
  const AddCourseScreenCustom({super.key});

  @override
  State<AddCourseScreenCustom> createState() => _AddCourseScreenCustomState();
}

class _AddCourseScreenCustomState extends State<AddCourseScreenCustom> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _trainerController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gradeController = TextEditingController();
  final _capacityController = TextEditingController(text: '30');

  DateTime? _selectedDate;
  bool _isLoading = false;

  static const Color blackColor = Color(0xFF1A1A1A);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color lightPurple = Color(0xFFF2E8F8);
  static const Color fieldPurple = Color(0xFFF7F1FB);

  final String addCourseUrl = 'http://localhost/training_api/add_course.php';

  @override
  void dispose() {
    _titleController.dispose();
    _trainerController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

      setState(() {
        _timeController.text = '$hour:$minute $period';
      });
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showMessage('يرجى اختيار تأريخ الدورة', Colors.red);
      return;
    }

    final registrationStartDate = DateTime.now();
    final registrationEndDate = registrationStartDate.add(const Duration(days: 9));

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(addCourseUrl),
        body: {
          'title': _titleController.text.trim(),

          // أول محاضر يبقى للتوافق مع الكود القديم
          'instructor': _trainerController.text.trim(),

          // المحاضرين المتعددين بصيغة نص مفصول بفارزة
          'instructors': _trainerController.text.trim(),

          'date': _formatDate(_selectedDate!),
          'time': _timeController.text.trim(),
          'duration': _durationController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'grade': _gradeController.text.trim(),

          // الحقول الجديدة
          'capacity': _capacityController.text.trim(),
          'registration_start_date': _formatDate(registrationStartDate),
          'registration_end_date': _formatDate(registrationEndDate),
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        _showMessage(data['message'] ?? 'تمت إضافة الدورة بنجاح', Colors.green);
        Navigator.pop(context, true);
      } else {
        _showMessage(data['message'] ?? 'حدث خطأ أثناء إضافة الدورة', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل الاتصال بالسيرفر: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: fieldPurple,
      hintText: hintText,
      hintTextDirection: TextDirection.rtl,
      prefixIcon: Icon(icon, color: darkPurple),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: darkPurple.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: darkPurple, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(hint, icon),
          validator: validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label مطلوب';
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'تأريخ الدورة',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: fieldPurple,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: darkPurple.withOpacity(0.15)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(Icons.calendar_month_rounded, color: darkPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'اختر تأريخ الدورة'
                        : _formatDate(_selectedDate!),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.black54 : blackColor,
                      fontWeight: _selectedDate == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationInfoCard() {
    final start = _formatDate(DateTime.now());
    final end = _formatDate(DateTime.now().add(const Duration(days: 9)));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: darkPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock_clock_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'مدة التسجيل',
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'يفتح التسجيل من $start ويغلق تلقائياً في $end',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            blackColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 48),
          SizedBox(height: 14),
          Text(
            'إضافة دورة تدريبية جديدة',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'حددي بيانات الدورة، المحاضرين، المقاعد، ومدة التسجيل',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFields(double width) {
    final crossAxisCount = width >= 1100
        ? 3
        : width >= 750
            ? 2
            : 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: crossAxisCount == 1 ? 5.3 : 3.6,
      children: [
        _buildTextField(
          label: 'عنوان الدورة',
          controller: _titleController,
          hint: 'ادخل عنوان الدورة',
          icon: Icons.title_rounded,
        ),
        _buildTextField(
          label: 'المحاضرون',
          controller: _trainerController,
          hint: 'مثال: أحمد علي، سارة محمد',
          icon: Icons.groups_rounded,
        ),
        _buildTextField(
          label: 'عدد المقاعد',
          controller: _capacityController,
          hint: 'مثال: 30',
          icon: Icons.event_seat_rounded,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'عدد المقاعد مطلوب';
            }

            final number = int.tryParse(value.trim());

            if (number == null || number <= 0) {
              return 'يرجى إدخال رقم صحيح';
            }

            return null;
          },
        ),
        _buildDateField(),
        _buildTextField(
          label: 'وقت الدورة',
          controller: _timeController,
          hint: 'اختر وقت الدورة',
          icon: Icons.access_time_rounded,
          readOnly: true,
          onTap: _pickTime,
        ),
        _buildTextField(
          label: 'مدة الدورة',
          controller: _durationController,
          hint: 'مثال: 3 أيام أو أسبوع',
          icon: Icons.timer_outlined,
        ),
        _buildTextField(
          label: 'مكان الدورة',
          controller: _locationController,
          hint: 'ادخل مكان الدورة',
          icon: Icons.location_on_rounded,
        ),
        _buildTextField(
          label: 'الدرجة الوظيفية',
          controller: _gradeController,
          hint: 'مثال: 2,3 أو اكتب الكل',
          icon: Icons.badge_rounded,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return _buildTextField(
      label: 'وصف الدورة',
      controller: _descriptionController,
      hint: 'ادخل وصف الدورة',
      icon: Icons.description_rounded,
      maxLines: 5,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitCourse,
        icon: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(_isLoading ? 'جاري الإضافة...' : 'إضافة الدورة'),
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
            'إضافة دورة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: darkPurple.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildRegistrationInfoCard(),
                          const SizedBox(height: 22),
                          _buildResponsiveFields(constraints.maxWidth),
                          const SizedBox(height: 20),
                          _buildDescriptionField(),
                          const SizedBox(height: 26),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}