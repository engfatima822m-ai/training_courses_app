import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCourseScreenCustom extends StatefulWidget {
  final dynamic course;

  const AddCourseScreenCustom({super.key, this.course});

  @override
  State<AddCourseScreenCustom> createState() => _AddCourseScreenCustomState();
}

class _AddCourseScreenCustomState extends State<AddCourseScreenCustom> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gradeController = TextEditingController();
  final _capacityController = TextEditingController(text: '30');

  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isLoadingInstructors = true;

  List<Map<String, dynamic>> _instructors = [];
  List<Map<String, dynamic>> _selectedInstructors = [];

  static const Color blackColor = Color(0xFF1A1A1A);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color lightPurple = Color(0xFFF2E8F8);
  static const Color fieldPurple = Color(0xFFF7F1FB);

  final String baseUrl = 'http://localhost/training_api';
  final String addCourseUrl = 'http://localhost/training_api/add_course.php';
  final String updateCourseUrl =
      'http://localhost/training_api/update_course.php';

  bool get isEditMode => widget.course != null;

  @override
  void initState() {
    super.initState();
    _fillCourseData();
    _fetchInstructors();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  dynamic _getCourseValue(String key) {
    final course = widget.course;
    if (course == null) return null;

    if (course is Map) {
      return course[key];
    }

    try {
      switch (key) {
        case 'id':
          return course.id;
        case 'title':
          return course.title;
        case 'instructor':
          return course.instructor;
        case 'instructors':
          return course.instructors;
        case 'date':
          return course.date;
        case 'time':
          return course.time;
        case 'duration':
          return course.duration;
        case 'location':
          return course.location;
        case 'description':
          return course.description;
        case 'grade':
          return course.grade;
        case 'capacity':
          return course.capacity;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  void _fillCourseData() {
    if (!isEditMode) return;

    _titleController.text = _getCourseValue('title')?.toString() ?? '';
    _timeController.text = _getCourseValue('time')?.toString() ?? '';
    _durationController.text = _getCourseValue('duration')?.toString() ?? '';
    _locationController.text = _getCourseValue('location')?.toString() ?? '';
    _descriptionController.text =
        _getCourseValue('description')?.toString() ?? '';
    _gradeController.text = _getCourseValue('grade')?.toString() ?? '';
    _capacityController.text = _getCourseValue('capacity')?.toString() ?? '30';

    final dateText = _getCourseValue('date')?.toString() ?? '';
    if (dateText.isNotEmpty) {
      _selectedDate = DateTime.tryParse(dateText);
    }
  }

  List<String> _oldInstructorNames() {
    final instructorsValue = _getCourseValue('instructors');

    if (instructorsValue is List) {
      return instructorsValue
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final instructorsText =
        (_getCourseValue('instructors') ?? _getCourseValue('instructor') ?? '')
            .toString();

    return instructorsText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _fetchInstructors() async {
    setState(() => _isLoadingInstructors = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_instructors.php'),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;

      final loadedInstructors = data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'] ?? [])
          : <Map<String, dynamic>>[];

      final oldNames = _oldInstructorNames();

      setState(() {
        _instructors = loadedInstructors;

        if (isEditMode && oldNames.isNotEmpty) {
          _selectedInstructors = _instructors.where((instructor) {
            final name = instructor['name']?.toString().trim() ?? '';
            return oldNames.contains(name);
          }).toList();
        }

        _isLoadingInstructors = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _instructors = [];
        _isLoadingInstructors = false;
      });

      _showMessage('فشل جلب المحاضرين من السيرفر', Colors.red);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
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

  String _selectedInstructorNames() {
    return _selectedInstructors
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.trim().isNotEmpty)
        .join(',');
  }

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedInstructors.isEmpty) {
      _showMessage('يرجى اختيار محاضر واحد على الأقل', Colors.red);
      return;
    }

    if (_selectedDate == null) {
      _showMessage('يرجى اختيار تأريخ الدورة', Colors.red);
      return;
    }

    final instructorsNames = _selectedInstructorNames();

    final body = {
      if (isEditMode) 'id': _getCourseValue('id').toString(),
      'title': _titleController.text.trim(),
      'instructor': instructorsNames,
      'instructors': instructorsNames,
      'date': _formatDate(_selectedDate!),
      'time': _timeController.text.trim(),
      'duration': _durationController.text.trim(),
      'location': _locationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'grade': _gradeController.text.trim(),
      'capacity': _capacityController.text.trim(),
    };

    if (!isEditMode) {
      final registrationStartDate = DateTime.now();
      final registrationEndDate =
          registrationStartDate.add(const Duration(days: 9));

      body.addAll({
        'instructor_username': '',
        'instructor_password': '',
        'registration_start_date': _formatDate(registrationStartDate),
        'registration_end_date': _formatDate(registrationEndDate),
      });
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(isEditMode ? updateCourseUrl : addCourseUrl),
        body: body,
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        _showMessage(
          data['message'] ??
              (isEditMode
                  ? 'تم تعديل الدورة بنجاح'
                  : 'تمت إضافة الدورة بنجاح'),
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        _showMessage(
          data['message'] ??
              (isEditMode
                  ? 'حدث خطأ أثناء تعديل الدورة'
                  : 'حدث خطأ أثناء إضافة الدورة'),
          Colors.red,
        );
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
                      color:
                          _selectedDate == null ? Colors.black54 : blackColor,
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

  Widget _buildInstructorsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'المحاضرون',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isLoadingInstructors ? null : _openInstructorsDialog,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: fieldPurple,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: darkPurple.withOpacity(0.15)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(Icons.groups_rounded, color: darkPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: _isLoadingInstructors
                      ? const Text(
                          'جاري تحميل المحاضرين...',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.black54),
                        )
                      : _selectedInstructors.isEmpty
                          ? const Text(
                              'اختاري المحاضرين من القائمة',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.black54),
                            )
                          : Wrap(
                              textDirection: TextDirection.rtl,
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedInstructors.map((item) {
                                return Chip(
                                  label: Text(item['name']?.toString() ?? ''),
                                  backgroundColor: Colors.white,
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedInstructors.removeWhere(
                                        (selected) =>
                                            selected['id'].toString() ==
                                            item['id'].toString(),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: darkPurple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openInstructorsDialog() {
    final tempSelected = List<Map<String, dynamic>>.from(_selectedInstructors);

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: const Text(
                  'اختيار المحاضرين',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: 460,
                  child: _instructors.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'لا يوجد محاضرون حالياً. أضيفي المحاضرين أولاً من شاشة إدارة المحاضرين.',
                            textAlign: TextAlign.right,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _instructors.length,
                          itemBuilder: (context, index) {
                            final instructor = _instructors[index];
                            final id = instructor['id'].toString();

                            final isSelected = tempSelected.any(
                              (item) => item['id'].toString() == id,
                            );

                            return CheckboxListTile(
                              value: isSelected,
                              activeColor: darkPurple,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                instructor['name']?.toString() ?? '',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                instructor['specialization']
                                            ?.toString()
                                            .trim()
                                            .isNotEmpty ==
                                        true
                                    ? instructor['specialization'].toString()
                                    : 'بدون اختصاص',
                                textAlign: TextAlign.right,
                              ),
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSelected.add(instructor);
                                  } else {
                                    tempSelected.removeWhere(
                                      (item) => item['id'].toString() == id,
                                    );
                                  }
                                });
                              },
                            );
                          },
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
                    onPressed: () {
                      setState(() {
                        _selectedInstructors = tempSelected;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('اعتماد الاختيار'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRegistrationInfoCard() {
    if (isEditMode) {
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
              child: const Icon(Icons.edit_calendar_rounded,
                  color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'وضع التعديل: يمكنك تعديل بيانات الدورة والمحاضرين المختارين.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            isEditMode
                ? Icons.edit_note_rounded
                : Icons.add_circle_outline_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            isEditMode ? 'تعديل الدورة التدريبية' : 'إضافة دورة تدريبية جديدة',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEditMode
                ? 'عدّلي بيانات الدورة والمحاضرين ثم احفظي التغييرات'
                : 'حددي بيانات الدورة، المحاضرين، المقاعد، ومدة التسجيل',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
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
        _buildInstructorsSelector(),
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
    final text = isEditMode ? 'حفظ التعديلات' : 'إضافة الدورة';
    final loadingText = isEditMode ? 'جاري الحفظ...' : 'جاري الإضافة...';

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
        label: Text(_isLoading ? loadingText : text),
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
          title: Text(
            isEditMode ? 'تعديل الدورة' : 'إضافة دورة جديدة',
            style: const TextStyle(fontWeight: FontWeight.bold),
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