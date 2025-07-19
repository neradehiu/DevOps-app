import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/work_service.dart';
import '../services/company_service.dart';
import 'ww_screen.dart';
import 'settings_screen.dart';
import 'companyListScreen.dart';
import 'support_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'group_chat_screen.dart';
import 'private_chat_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  String? _username;
  String? currentUserRole;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> jobList = [];
  List<Map<String, dynamic>> filteredJobs = [];

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadJobs();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final role = await _authService.getRole();
    setState(() {
      currentUserRole = role;
    });
  }


  Future<void> loadUsername() async {
    final name = await _authService.getUsername();
    setState(() {
      _username = name;
    });
  }

  Future<void> loadJobs() async {
    try {
      final jobs = await WorkService.getAllWorks();
      setState(() {
        jobList = jobs;
        filteredJobs = List.from(jobs);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải công việc: $e')),
      );
    }
  }

  void _filterJobs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredJobs = jobList.where((job) {
        final position = job['position']?.toLowerCase() ?? '';
        final company = job['company']?.toLowerCase() ?? '';
        return position.contains(lowerQuery) || company.contains(lowerQuery);
      }).toList();
    });
  }

  void onChatPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GroupChatScreen()),
    );
  }

  void onWWPressed(BuildContext context) async {
    final role = await _authService.getRole();
    if (role == 'ROLE_MANAGER') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WWScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Chức năng tuyển dụng của riêng doanh nghiệp, liên hệ admin để đăng ký tài khoản doanh nghiệp ngay!",
          ),
        ),
      );
    }
  }

  void showCompanyDetail(BuildContext context, int companyId) async {
    try {
      final company = await CompanyService.getCompanyById(companyId);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(company['name'] ?? 'Thông tin công ty'),
          // ↓ Thay `content: Column(...)` thành:
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mô tả: ${company['descriptionCompany'] ?? ''}'),
                const SizedBox(height: 8),
                Text('Loại hình: ${company['type'] ?? ''}'),
                const SizedBox(height: 8),
                Text('Địa chỉ: ${company['address'] ?? ''}'),
                const SizedBox(height: 8),
                Text('Công khai: ${company['isPublic'] == true ? 'Có' : 'Không'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể hiển thị chi tiết công ty: $e')),
      );
    }
  }

  void onPrivateChat(String receiverUsername) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateChatScreen(receiverUsername: receiverUsername),
      ),
    );
  }

  Widget buildCircleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.pink, width: 2),
          gradient: const LinearGradient(
            colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildCompanyDrawer(BuildContext context) {
    return Drawer(
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9D4EDD), Color(0xFF40C9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'TÌM VIỆC 24H',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const Divider(color: Colors.white54),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF63F4E9),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CompanyListScreen()),
                    );
                  });
                },
                child: const Text(
                  'Danh sách công ty',
                  style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      buildJobListTab(context),
      const NotificationScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
      const SupportScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: buildCompanyDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildCircleButton(
              onTap: () => onChatPressed(context),
              child: const Icon(Icons.message_rounded,
                  color: Colors.white, size: 24),
            ),
            buildCircleButton(
              onTap: () => onWWPressed(context),
              child: const Text(
                'WW',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Tìm mới'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Hỗ trợ'),
        ],
      ),
    );
  }

  Widget buildJobListTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9D4EDD), Color(0xFF40C9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'tên: ${_username ?? "..."}',
                style: const TextStyle(color: Colors.white),
              ),
              const Text(
                'TÌM VIỆC 24H',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterJobs,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'THANH TÌM KIẾM',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Việc Làm mới cập nhật',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];
              return InkWell(
                onTap: () {
                  final companyId = job['companyId'];
                  if (companyId != null) {
                    showCompanyDetail(context, companyId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không tìm thấy ID công ty')),
                    );
                  }
                },
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            job['position'] ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ),
                            maxLines: 1,               // force single line
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Công ty: ${job['company'] ?? ''}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Lương: ${job['salary']} VNĐ',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        if (currentUserRole != null && currentUserRole != 'ROLE_MANAGER' && currentUserRole != 'ROLE_ADMIN')
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                final companyUsername = job['createdByUsername'];
                                if (companyUsername != null) {
                                  onPrivateChat(companyUsername);
                                }
                              },
                              icon: const Icon(Icons.chat_bubble, color: Colors.white),
                              label: Text(
                                'Chat với ${job['createdByUsername'] ?? "..."}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
