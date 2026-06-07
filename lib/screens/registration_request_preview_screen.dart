import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/services/registration_request_pdf.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;
class RegistrationRequestPreviewScreen extends StatelessWidget {
  final User user;
  final Course course;

  const RegistrationRequestPreviewScreen({
    super.key,
    required this.user,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'طلب التسجيل',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,
  backgroundColor: Color(0xFF2D033B),
  foregroundColor: Colors.white,
),
      body: PdfPreview(
        build: (format) => RegistrationRequestPdfService.generate(
          user: user,
          course: course,
        ),
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        actionBarTheme: const PdfActionBarTheme(
  backgroundColor: Color(0xFF2D033B),
  iconColor: Colors.white,
),
      ),
    );
  }
}