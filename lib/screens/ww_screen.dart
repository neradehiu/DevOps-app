import 'package:flutter/material.dart';

class WWScreen extends StatelessWidget {
  const WWScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang WW'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text(
          'Đây là trang WW',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
