import 'package:flutter/material.dart';

class WWScreen extends StatelessWidget {
  const WWScreen({super.key});

  void _handleAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thao tác: $action')),
    );
    // TODO: Gọi API tương ứng qua Provider hoặc service
  }

  Widget _buildGradientButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Quản lý công ty'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildGradientButton(context, Icons.add_business, 'Tạo công ty mới',
                    () => _handleAction(context, 'Tạo công ty')),
            _buildGradientButton(context, Icons.business, 'Xem công ty của tôi',
                    () => _handleAction(context, 'Lấy danh sách công ty theo owner')),
            _buildGradientButton(context, Icons.edit, 'Cập nhật công ty',
                    () => _handleAction(context, 'Cập nhật công ty')),
            _buildGradientButton(context, Icons.delete, 'Xóa công ty',
                    () => _handleAction(context, 'Xóa công ty')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
