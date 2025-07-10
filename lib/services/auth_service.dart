import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  static const baseUrl = 'http://localhost:8080/api/auth';
  final storage = const FlutterSecureStorage();

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
        await storage.write(key: 'role', value: role);

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


  Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Không thể gửi email khôi phục';
      }
    } catch (e) {
      return 'Lỗi gửi email: $e';
    }
  }


  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  Future<String?> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Không thể đặt lại mật khẩu';
      }
    } catch (e) {
      return 'Lỗi đặt lại mật khẩu: $e';
    }
  }


  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'role');
  }


  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }


  Future<String?> getRole() async {
    return await storage.read(key: 'role');
  }


  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
