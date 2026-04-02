import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCourseScreenCustom extends StatefulWidget {
  const AddCourseScreenCustom({super.key});

  @override
  State<AddCourseScreenCustom> createState() {
    return _AddCourseScreenCustomState();
  }
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

  DateTime? _selectedDate;
  bool _isLoading = false;

  final String addCourseUrl = 'http://10.0.2.2/training_api/add_course.php';

  @override
  void dispose() {
    _titleController.dispose();
    _trainerController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
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
      setState(() {
        _selectedDate = pickedDate;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تأريخ الدورة'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(addCourseUrl),
        body: {
          'title': _titleController.text.trim(),
          'instructor': _trainerController.text.trim(),
          'date': _formatDate(_selectedDate!),
          'time': _timeController.text.trim(),
          'duration': _durationController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'grade': _gradeController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'تمت إضافة الدورة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'حدث خطأ أثناء إضافة الدورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الاتصال بالسيرفر: $e'),
          backgroundColor: Colors.red,
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

  InputDecoration _inputDecoration(String hintText, Color fillColor) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دورة جديدة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('عنوان الدورة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.end,
                decoration: _inputDecoration(
                  'ادخل عنوان الدورة',
                  const Color.fromARGB(255, 122, 138, 205),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'عنوان الدورة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('اسم المدرب'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _trainerController,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.end,
                decoration: _inputDecoration(
                  'ادخل اسم المدرب',
                  const Color.fromARGB(255, 106, 146, 178),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اسم المدرب مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('تأريخ الدورة'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 228, 232, 248),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'اختر تأريخ الدورة'
                        : _formatDate(_selectedDate!),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('وقت الدورة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                textAlign: TextAlign.end,
                decoration: _inputDecoration(
                  'اختر وقت الدورة',
                  const Color.fromARGB(255, 232, 243, 255),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _pickTime,
                  ),
                ),
                onTap: _pickTime,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'وقت الدورة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('مدة الدورة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.end,
                decoration: _inputDecoration(
                  'مثال: 3 أيام أو أسبوع',
                  const Color.fromARGB(255, 240, 236, 255),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'مدة الدورة مطلوبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('مكان الدورة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.end,
                decoration: _inputDecoration(
                  'ادخل مكان الدورة',
                  const Color.fromARGB(255, 236, 250, 240),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'مكان الدورة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('الدرجة الوظيفية'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gradeController,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.end,
                decoration: _inputDecoration(
                  'مثال: 2,3',
                  const Color.fromARGB(255, 255, 244, 233),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الدرجة الوظيفية مطلوبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('وصف الدورة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textAlign: TextAlign.end,
                maxLines: 4,
                decoration: _inputDecoration(
                  'ادخل وصف الدورة',
                  const Color.fromARGB(255, 245, 245, 245),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'وصف الدورة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCourse,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إضافة الدورة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}