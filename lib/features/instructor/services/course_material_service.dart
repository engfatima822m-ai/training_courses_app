import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:training_courses_app/services/api_service.dart';

class CourseMaterialService {
  static Future<Map<String, dynamic>> uploadCourseMaterial({
    required String courseId,
    required String title,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return {
        'success': false,
        'message': 'لم يتم اختيار ملف',
      };
    }

    final file = result.files.first;

    if (file.bytes == null) {
      return {
        'success': false,
        'message': 'تعذر قراءة الملف',
      };
    }

    final uri = Uri.parse('${ApiService.baseUrl}/upload_course_material.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['course_id'] = courseId;
    request.fields['title'] = file.name;

    request.files.add(
      http.MultipartFile.fromBytes(
        'material_file',
        file.bytes!,
        filename: file.name,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<List<dynamic>> fetchCourseMaterials({
    required String courseId,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/get_course_materials.php?course_id=$courseId',
    );

    final response = await http.get(uri);
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data['success'] == true) {
      return data['data'] ?? [];
    }

    return [];
  }

  static String buildMaterialUrl(String filePath) {
    return '${ApiService.baseUrl}/$filePath';
  }
}