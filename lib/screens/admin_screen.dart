import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/account.dart';
import '../../services/admin_service.dart';
import 'admin_create_account_screen.dart';
import 'ww_screen.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService adminService = AdminService();
  final storage = FlutterSecureStorage();
  List<Account> accounts = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) return;

      final result = await adminService.getAllAccounts(token);
      setState(() {
        accounts = result;
      });
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  Future<void> handleLockToggle(Account acc) async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    if (acc.isLocked) {
      await adminService.unlockUser(acc.id, token);
    } else {
      await adminService.lockUser(acc.id, token);
    }
    await loadAccounts();
  }

  Future<void> handleDelete(Account acc) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa tài khoản ${acc.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      final token = await storage.read(key: 'token');
      if (token == null) return;

      await adminService.deleteUser(acc.id, token);
      await loadAccounts();
    }
  }

  void showEditDialog(Account acc) {
    final nameController = TextEditingController(text: acc.name);
    final emailController = TextEditingController(text: acc.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chỉnh sửa tài khoản"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Tên")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            child: Text("Lưu"),
            onPressed: () async {
              final token = await storage.read(key: 'token');
              if (token == null) return;
              await adminService.updateUser(
                acc.id,
                nameController.text,
                emailController.text,
                acc.role,
                acc.isLocked,
                token,
              );
              Navigator.pop(context);
              await loadAccounts();
            },
          ),
        ],
      ),
    );
  }

  Widget buildAccountItem(Account acc) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.shade100, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(acc.email, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(acc.isLocked ? Icons.lock : Icons.lock_open, color: Colors.deepPurple),
                onPressed: () => handleLockToggle(acc),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => handleDelete(acc),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => showEditDialog(acc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: loadAccounts,
                  child: const Text("DANH SÁCH"),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.indigo),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: accounts.map(buildAccountItem).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.pink, width: 2),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WWScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Text(
            "WW",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminCreateAccountScreen()),
              );
              break;
            case 2:
              Navigator.pushNamed(context, '/admin/reports');
              break;
            case 3:
              Navigator.pushNamed(context, '/admin/profile');
              break;
            case 4:
              Navigator.pushNamed(context, '/admin/settings');
              break;
          }
        },
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
}
