import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final storage = const FlutterSecureStorage();
  final ThemeController themeController = Get.find<ThemeController>();
  int selectedIndex = 4;

  void handleNavigation(int index) {
    setState(() => selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/admin/create');
        break;
      case 2:
        Navigator.pushNamed(context, '/admin/reports');
        break;
      case 3:
        Navigator.pushNamed(context, '/admin/profile');
        break;
      case 4:
      // Trang hiện tại - không làm gì
        break;
    }
  }

  void _logout() async {
    await storage.deleteAll();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSettingTile("Tài khoản", Icons.person, () {
            Navigator.pushNamed(context, '/admin/profile');
          }),
          _buildSettingTile("Đổi mật khẩu", Icons.lock_reset, () {
            // Điều hướng nếu có trang đổi mật khẩu
          }),
          _buildDarkModeSwitch(),
          _buildSettingTile("Thông tin ứng dụng", Icons.info, () {
            showAboutDialog(
              context: context,
              applicationName: "Find Work For Everyone",
              applicationVersion: "1.0.0",
              children: [const Text("Ứng dụng quản lý tuyển dụng dành cho Admin.")],
            );
          }),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: handleNavigation,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Thêm'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeSwitch() {
    return Obx(() => SwitchListTile(
      title: const Text("Chế độ tối", style: TextStyle(fontSize: 16)),
      secondary: const Icon(Icons.brightness_6, color: Colors.deepPurple),
      value: themeController.isDarkMode.value,
      onChanged: (value) => themeController.toggleTheme(),
    ));
  }
}
