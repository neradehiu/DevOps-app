import 'package:flutter/material.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  // Danh sách thông báo mẫu
  List<Map<String, String>> notifications = [
    {
      'title': 'Tài khoản mới',
      'message': 'Người dùng Nguyễn Văn A vừa đăng ký tài khoản.',
      'time': '5 phút trước'
    },
    {
      'title': 'Báo cáo lỗi',
      'message': 'Người dùng Báo cáo lỗi hệ thống.',
      'time': '1 giờ trước'
    },
    {
      'title': 'Xác minh email',
      'message': 'Tài khoản user123 đã xác minh email thành công.',
      'time': 'Hôm qua'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("THÔNG BÁO"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              // TODO: handle logout
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.deepPurple),
              title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['message'] ?? ''),
              trailing: Text(item['time'] ?? '', style: const TextStyle(fontSize: 12)),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin/create');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/admin/profile');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/admin/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Quản lý tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản của tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
