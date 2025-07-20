import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkAcceptanceService {
  static const String baseUrl = 'http://localhost:8080/api/works';
  static final _storage = FlutterSecureStorage();

  // Lấy token từ storage
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');
    final role = await _storage.read(key: 'role');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Username': username ?? '',
      'X-Role': role ?? '',
    };
  }

  /// 1. Nhận việc (POST /api/works/{workId}/acceptances)
  static Future<bool> acceptWork(int workId, int accountId) async {
    final url = Uri.parse('$baseUrl/$workId/acceptances');
    final headers = await _getHeaders();

    final body = jsonEncode({
      'workPostedId': workId,
      'accountId': accountId,
    });

    final response = await http.post(url, headers: headers, body: body);
    return response.statusCode == 200;
  }

  /// 2. Lấy danh sách người đã nhận việc (GET /api/works/{workId}/acceptances)
  static Future<List<dynamic>> getAcceptancesByWork(int workId) async {
    final url = Uri.parse('$baseUrl/$workId/acceptances');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải danh sách người nhận việc');
    }
  }

  /// 3. Lấy danh sách người dùng đã nhận/cancel/completed theo trạng thái (GET /api/works/{workId}/acceptances/account/{id}/status/{status})
  static Future<List<dynamic>> getAcceptedJobsByStatus(int workId, int accountId, String status) async {
    final url = Uri.parse('$baseUrl/$workId/acceptances/account/$accountId/status/$status');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    print('🔍 [DEBUG] Gọi API: $url');
    print('🔍 [DEBUG] Status code: ${response.statusCode}');
    print('🔍 [DEBUG] Response body: ${response.body}');
    print('📦 Headers gửi đi: $headers');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể lấy công việc đã nhận theo trạng thái');
    }
  }


  /// 4. Cập nhật trạng thái người nhận việc (PUT /api/works/{workId}/acceptances/{acceptanceId}/status)
  static Future<bool> updateAcceptanceStatus(
      int workId, int acceptanceId, String newStatus) async {
    final url = Uri.parse('$baseUrl/$workId/acceptances/$acceptanceId/status');
    final headers = await _getHeaders();

    final body = jsonEncode({'status': newStatus});

    final response = await http.put(url, headers: headers, body: body);
    return response.statusCode == 200;
  }
}
