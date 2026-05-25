import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 IMPORTANT: PHYSICAL DEVICE IP
  static const String baseUrl = 'http://192.168.0.103:5000';

  static const String summarizeEndpoint = '/api/summarize';

  static Future<Map<String, dynamic>> summarizeNote({
    required String content,
    String summaryType = 'brief',
  }) async {
    final url = Uri.parse('$baseUrl$summarizeEndpoint');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'content': content, 'type': summaryType}),
          )
          .timeout(const Duration(seconds: 120)); // AI NEEDS TIME

      if (response.statusCode != 200) {
        throw Exception('Backend error: ${response.body}');
      }

      final data = jsonDecode(response.body);

      return {
        'success': true,
        'summary': data['summary'],
        'keyPoints': List<String>.from(data['keyPoints']),
      };
    } catch (e) {
      // 🔴 DO NOT SILENTLY FALL BACK
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> generateTitle(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-title'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'title': data['title'] ?? 'Untitled Note'};
      } else {
        return {'success': false, 'error': 'Failed to generate title'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> extractKeywords(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/extract-keywords'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'keywords': List<String>.from(data['keywords'] ?? []),
        };
      } else {
        return {'success': false, 'error': 'Failed to extract keywords'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Summarize a file (image or PDF)
  /// Sends the file to the Python backend for text extraction and AI summarization
  static Future<Map<String, dynamic>> summarizeFile({
    required File file,
    required String summaryType,
    required bool isImage,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/summarize-file');

      var request = http.MultipartRequest('POST', uri)
        ..fields['summaryType'] = summaryType
        ..fields['isImage'] = isImage.toString()
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'extractedText': jsonResponse['extracted_text'] ?? '',
          'summary': jsonResponse['summary'] ?? '',
          'keyPoints': jsonResponse['key_points'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['error'] ?? 'Failed to process file',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }
}
  