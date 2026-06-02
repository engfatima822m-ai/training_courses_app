import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;
import 'package:training_courses_app/models/course.dart';
import 'package:training_courses_app/models/user.dart';

class RegistrationRequestPdfService {
  static String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$year/$month/$day';
  }
static String _ar(String text) {
  final reshaped = ArabicReshaper().reshape(text);
  return String.fromCharCodes(bidi.logicalToVisual(reshaped));
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
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
        ),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Text(
                    _ar('قسم الموارد البشرية / شعبة التدريب والتطوير'),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 16,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    _ar('طلب تثبيت تسجيل في دورة تدريبية'),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  _ar('إلى / قسم الموارد البشرية - شعبة التدريب والتطوير'),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  _ar('تحية طيبة...'),
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 13,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  _ar(
                    'أقدم لكم طلبي هذا لغرض إعلامكم بأنه تم تسجيلي إلكترونيًا في برنامج الدورات التدريبية على الدورة الموسومة (${course.title})، والتي ستقام بتاريخ ($courseDate) في (${course.location})، وبإشراف المحاضر (${course.instructor})، وفي الساعة (${course.time})، ولمدة (${course.duration.isEmpty ? 'غير محددة' : course.duration}).',
                  ),
                  textAlign: pw.TextAlign.justify,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 13,
                    lineSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  _ar(
                    'راجيًا من شعبتكم الموقرة الاطلاع على طلبي واتخاذ ما يلزم بشأن دراسة الطلب والموافقة عليه حسب الضوابط المعتمدة، علمًا أن التسجيل قد تم ضمن النظام الإلكتروني الخاص بالدورات، وأنا بانتظار تأييدكم وقبول الطلب من جهتكم.',
                  ),
                  textAlign: pw.TextAlign.justify,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 13,
                    lineSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _infoRow(_ar('اسم الموظف'), _ar(user.fullName), boldFont, regularFont),
                      _divider(),
                      _infoRow(_ar('الرقم الوظيفي / رقم البصمة'), _ar(user.employeeId), boldFont, regularFont),
                      _divider(),
                      _infoRow(_ar('الدرجة الوظيفية'), _ar(user.grade.toString()), boldFont, regularFont),
                      _divider(),
                      _infoRow(
                        _ar('مكان العمل'),
                        _ar(user.workPlace.isEmpty ? 'غير متوفر' : user.workPlace),
                        boldFont,
                        regularFont,
                      ),
                      _divider(),
                      _infoRow(_ar('تاريخ الاستحقاق القادم'), _ar(nextDueDate), boldFont, regularFont),
                      _divider(),
                      _infoRow(_ar('اسم الدورة'), _ar(course.title), boldFont, regularFont),
                      _divider(),
                      _infoRow(_ar('تاريخ الدورة'), _ar(courseDate), boldFont, regularFont),
                      _divider(),
                      _infoRow(_ar('وقت الدورة'), _ar(course.time), boldFont, regularFont),
                      _divider(),
                      _infoRow(_ar('مكان الدورة'), _ar(course.location), boldFont, regularFont),
                    ],
                  ),
                ),
                pw.SizedBox(height: 28),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      _ar('التاريخ: $today'),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 13,
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          _ar('اسم الموظف'),
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 14),
                        pw.Text(
                          _ar(user.fullName),
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Text(
                          _ar('التوقيع: ____________'),
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoRow(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 12,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      height: 1,
      color: PdfColors.grey300,
    );
  }
}