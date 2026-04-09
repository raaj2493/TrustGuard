import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<AnalysisResult> analyze(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return AnalysisResult.fromJson(data['analysis']);
      } else {
        throw ApiException(data['message'] ?? 'Unknown error');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Cannot connect to TrustGuard API. Make sure the backend is running on port 8080.');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
