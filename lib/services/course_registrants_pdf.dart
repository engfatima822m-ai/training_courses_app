import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:training_courses_app/models/course.dart';

class CourseRegistrantsPdfService {
  static const PdfColor darkPurple = PdfColor.fromInt(0xFF2D033B);
  static const PdfColor lightPurple = PdfColor.fromInt(0xFFF6F2FA);

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  static Future<Uint8List> generate({
    required Course course,
    required List<Map<String, dynamic>> registrants,
  }) async {
    final pdf = pw.Document();

    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'),
    );

    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'),
    );

    final logoBytes = await rootBundle.load('assets/images/company_logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
          );
        },
        build: (context) {
          return [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _header(logoImage, boldFont),
                  pw.SizedBox(height: 16),
                  _courseInfo(course, registrants.length, boldFont, regularFont),
                  pw.SizedBox(height: 16),
                  _table(registrants, boldFont, regularFont),
                  pw.SizedBox(height: 35),
                  _signatures(boldFont),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(pw.ImageProvider logo, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Image(logo, width: 78, height: 78),
        pw.SizedBox(height: 6),
        pw.Text(
          'شركة توزيع المنتجات النفطية / فرع البصرة',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'شعبة التدريب',
          style: pw.TextStyle(font: boldFont, fontSize: 14),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 10),
          decoration: pw.BoxDecoration(
            color: darkPurple,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Center(
            child: pw.Text(
              'كشف أسماء المشاركين في الدورة التدريبية',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 16,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _courseInfo(
    Course course,
    int count,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightPurple,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFD8C7E8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _infoRow('اسم الدورة', course.title, boldFont, regularFont),
          _infoRow('المحاضرون', course.instructorsText, boldFont, regularFont),
          _infoRow(
            'تاريخ الدورة',
            _formatDate(course.date),
            boldFont,
            regularFont,
          ),
          _infoRow('وقت الدورة', course.time, boldFont, regularFont),
          _infoRow('مكان الدورة', course.location, boldFont, regularFont),
          _infoRow('مدة الدورة', course.duration, boldFont, regularFont),
          _infoRow('عدد المقاعد', '${course.capacity}', boldFont, regularFont),
          _infoRow('عدد المسجلين', '$count', boldFont, regularFont),
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
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 105,
              child: pw.Text(
                '$label:',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11.5,
                  color: darkPurple,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Text(
                value.trim().isEmpty ? 'غير محدد' : value,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _table(
    List<Map<String, dynamic>> registrants,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    final rows = registrants.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final person = entry.value;

      return [
        person['phone']?.toString() ?? '',
        person['grade']?.toString() ?? '',
        person['work_place']?.toString() ?? '',
        person['employee_id']?.toString() ?? '',
        person['employee_name']?.toString() ?? '',
        '$index',
      ];
    }).toList();

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.TableHelper.fromTextArray(
        headers: [
          'الهاتف',
          'الدرجة',
          'القسم',
          'الرقم الوظيفي',
          'الاسم',
          'ت',
        ],
        data: rows,
        border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
        headerStyle: pw.TextStyle(
          font: boldFont,
          color: PdfColors.white,
          fontSize: 10.5,
        ),
        headerDecoration: const pw.BoxDecoration(color: darkPurple),
        cellStyle: pw.TextStyle(font: regularFont, fontSize: 9.5),
        cellAlignment: pw.Alignment.center,
        headerAlignment: pw.Alignment.center,
        cellPadding: const pw.EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 6,
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(1.4),
          1: const pw.FlexColumnWidth(0.8),
          2: const pw.FlexColumnWidth(1.3),
          3: const pw.FlexColumnWidth(1.2),
          4: const pw.FlexColumnWidth(1.6),
          5: const pw.FlexColumnWidth(0.45),
        },
      ),
    );
  }

  static pw.Widget _signatures(pw.Font boldFont) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            children: [
              pw.Text(
                'توقيع المحاضر',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text('__________________'),
            ],
          ),
          pw.Column(
            children: [
              pw.Text(
                'توقيع مسؤول شعبة التدريب',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text('__________________'),
            ],
          ),
        ],
      ),
    );
  }
}