import 'package:flutter/material.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return;
    }

    final request = RegisterRequest(
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      email: email,
    );

    final result = await _authService.register(request);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );
      Navigator.pop(context); // Quay lại login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $result")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2FF),
      appBar: AppBar(title: const Text("Đăng ký")),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Tạo tài khoản",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Họ tên")),
                const SizedBox(height: 10),
                TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email")),
                const SizedBox(height: 10),
                TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username")),
                const SizedBox(height: 10),
                TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true),
                const SizedBox(height: 10),
                TextField(
                    controller: _confirmPasswordController,
                    decoration:
                    const InputDecoration(labelText: "Xác nhận Password"),
                    obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _register, child: const Text("Đăng ký"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
