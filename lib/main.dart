import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm dòng này
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Find Work For Everyone',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF4F1FB), // Màu nền nhẹ
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
