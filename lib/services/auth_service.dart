import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  static const baseUrl = 'http://localhost:8080/api/auth';
  final storage = FlutterSecureStorage();

  // Đăng ký
  Future<String?> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? response.body;
      }
    } catch (e) {
      return 'Đã xảy ra lỗi khi đăng ký: $e';
    }
  }

  // Đăng nhập
  Future<String?> login(LoginRequest request, Function(String role) onSuccess) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'];
        final role = json['role'];

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'role', value: role); // Lưu role nếu cần

        onSuccess(role);
        return null;
      } else {
        final json = jsonDecode(response.body);
        return json['message'] ?? 'Đăng nhập thất bại';
      }
    } catch (e) {
      return 'Lỗi đăng nhập: $e';
    }
  }
}
