import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';

class RegistrationRequestPdfService {
  static const PdfColor blackColor = PdfColor.fromInt(0xFF111111);
  static const PdfColor darkPurple = PdfColor.fromInt(0xFF2D033B);
  static const PdfColor deepPurple = PdfColor.fromInt(0xFF4B0082);
  static const PdfColor lightPurple = PdfColor.fromInt(0xFFF6F2FA);

  static String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$year/$month/$day';
  }

  static Future<Uint8List> generate({
    required User user,
    required Course course,
  }) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'),
    );

    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'),
    );

    final today = _formatDate(DateTime.now());
    final courseDate = _formatDate(course.date);
    final nextDueDate = _formatDate(user.nextDueDate);

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        build: (context) {
          return [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(boldFont),
                  pw.SizedBox(height: 26),
                  pw.Text(
                    'إلى / قسم الموارد البشرية - شعبة التدريب والتطوير',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      color: darkPurple,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'تحية طيبة...',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 13,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'أقدم لكم طلبي هذا لغرض إعلامكم بأنه تم تسجيلي إلكترونياً في برنامج الدورات التدريبية على الدورة الموسومة (${course.title})، والتي ستقام بتاريخ ($courseDate) في (${course.location})، وبإشراف المحاضر (${course.instructorsText})، وفي الساعة (${course.time})، ولمدة (${course.duration.isEmpty ? 'غير محددة' : course.duration}).',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'راجياً من شعبتكم الموقرة الاطلاع على طلبي واتخاذ ما يلزم بشأن دراسة الطلب والموافقة عليه حسب الضوابط المعتمدة، علماً أن التسجيل قد تم ضمن النظام الإلكتروني الخاص بالدورات التدريبية.',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  _buildInfoBox(
                    boldFont: boldFont,
                    regularFont: regularFont,
                    user: user,
                    course: course,
                    courseDate: courseDate,
                    nextDueDate: nextDueDate,
                  ),
                  pw.SizedBox(height: 30),
                  _buildFooter(
                    boldFont: boldFont,
                    regularFont: regularFont,
                    user: user,
                    today: today,
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: darkPurple,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'شركة توزيع المنتجات النفطية / فرع البصرة',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: boldFont,
              color: PdfColors.white,
              fontSize: 16,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'قسم الموارد البشرية / شعبة التدريب والتطوير',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: boldFont,
              color: PdfColors.white,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'طلب تثبيت تسجيل في دورة تدريبية',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: boldFont,
                color: darkPurple,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoBox({
    required pw.Font boldFont,
    required pw.Font regularFont,
    required User user,
    required Course course,
    required String courseDate,
    required String nextDueDate,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: lightPurple,
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFD8C7E8),
          width: 1,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          _infoRow('اسم الموظف', user.fullName, boldFont, regularFont),
          _divider(),
          _infoRow(
            'الرقم الوظيفي / رقم البصمة',
            user.employeeId,
            boldFont,
            regularFont,
          ),
          _divider(),
          _infoRow(
            'الدرجة الوظيفية',
            user.grade.toString(),
            boldFont,
            regularFont,
          ),
          _divider(),
          _infoRow(
            'مكان العمل',
            user.workPlace.isEmpty ? 'غير متوفر' : user.workPlace,
            boldFont,
            regularFont,
          ),
          _divider(),
          _infoRow(
            'تاريخ الاستحقاق القادم',
            nextDueDate,
            boldFont,
            regularFont,
          ),
          _divider(),
          _infoRow('اسم الدورة', course.title, boldFont, regularFont),
          _divider(),
          _infoRow('تاريخ الدورة', courseDate, boldFont, regularFont),
          _divider(),
          _infoRow('وقت الدورة', course.time, boldFont, regularFont),
          _divider(),
          _infoRow(
            'مدة الدورة',
            course.duration.isEmpty ? 'غير محددة' : course.duration,
            boldFont,
            regularFont,
          ),
          _divider(),
          _infoRow('مكان الدورة', course.location, boldFont, regularFont),
          _divider(),
          _infoRow(
            'المحاضر',
            course.instructorsText,
            boldFont,
            regularFont,
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 7),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 150,
              child: pw.Text(
                '$label:',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12.5,
                  color: darkPurple,
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Text(
                value.trim().isEmpty ? 'غير محدد' : value,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 12.5,
                  color: blackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Container(
      height: 0.7,
      color: const PdfColor.fromInt(0xFFE3D8EC),
    );
  }

  static pw.Widget _buildFooter({
    required pw.Font boldFont,
    required pw.Font regularFont,
    required User user,
    required String today,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'مقدم الطلب',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 13,
                  color: darkPurple,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                user.fullName,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 13,
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'التوقيع: ________________',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          pw.Text(
            'التاريخ: $today',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}