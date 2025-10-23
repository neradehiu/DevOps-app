import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  static const baseUrl = 'http://178.128.208.73:8080/api/auth';
  final storage = const FlutterSecureStorage();

  // ---------------------- REGISTER ----------------------
  Future<String?> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('📩 [REGISTER] Response: ${response.statusCode} - ${response.body}');

      // ✅ Backend trả về 200 hoặc 201 => đăng ký thành công
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      // ❌ Lỗi khác thì parse message
      final error = jsonDecode(response.body);
      return error['message'] ?? response.body;
    } catch (e) {
      print('❌ [REGISTER ERROR] $e');
      return 'Đã xảy ra lỗi khi đăng ký: $e';
    }
  }

  // ---------------------- LOGIN ----------------------
  Future<String?> login(LoginRequest request, Function(String role) onSuccess) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('📩 [LOGIN] Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final token = json['token']?.toString();
        final role = json['role']?.toString();
        final username = json['username']?.toString();
        final id = json['id']?.toString();

        if (token == null || role == null) {
          print('⚠️ [LOGIN] Thiếu token hoặc role trong phản hồi!');
          return 'Phản hồi từ máy chủ không hợp lệ (thiếu token hoặc role)';
        }

        // ✅ Lưu token và thông tin người dùng
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'role', value: role);
        if (username != null) await storage.write(key: 'username', value: username);
        if (id != null) await storage.write(key: 'id', value: id);

        print('✅ [LOGIN SUCCESS] Token: $token, Role: $role, User: $username, ID: $id');

        onSuccess(role);
        return null;
      }

      final json = jsonDecode(response.body);
      return json['message'] ?? 'Đăng nhập thất bại (${response.statusCode})';
    } catch (e) {
      print('❌ [LOGIN ERROR] $e');
      return 'Lỗi đăng nhập: $e';
    }
  }

  // ---------------------- FORGOT PASSWORD ----------------------
  Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('📩 [FORGOT PASSWORD] ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) return null;

      final error = jsonDecode(response.body);
      return error['message'] ?? 'Không thể gửi email khôi phục';
    } catch (e) {
      return 'Lỗi gửi email: $e';
    }
  }

  // ---------------------- VERIFY CODE ----------------------
  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      print('📩 [VERIFY CODE] ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [VERIFY CODE ERROR] $e');
      return false;
    }
  }

  // ---------------------- RESET PASSWORD ----------------------
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

      print('📩 [RESET PASSWORD] ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) return null;

      final error = jsonDecode(response.body);
      return error['message'] ?? 'Không thể đặt lại mật khẩu';
    } catch (e) {
      return 'Lỗi đặt lại mật khẩu: $e';
    }
  }

  // ---------------------- LOGOUT ----------------------
  Future<bool> logout() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📩 [LOGOUT] ${response.statusCode} - ${response.body}');

      // Dù backend có lỗi thì vẫn xóa token local
      await storage.deleteAll();

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [LOGOUT ERROR] $e');
      await storage.deleteAll();
      return false;
    }
  }

  // ---------------------- GETTERS ----------------------
  Future<int?> getAccountId() async {
    final idStr = await storage.read(key: 'id');
    return idStr != null ? int.tryParse(idStr) : null;
  }

  Future<String?> getToken() async => await storage.read(key: 'token');
  Future<String?> getRole() async => await storage.read(key: 'role');
  Future<String?> getUsername() async => await storage.read(key: 'username');

  Future<bool> isLoggedIn() async => (await getToken()) != null;
}
