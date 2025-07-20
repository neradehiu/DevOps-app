import 'package:flutter/material.dart';
import '../services/work_acceptance_service.dart';

class ListWorkAcceptScreen extends StatelessWidget {
  final int workId;

  const ListWorkAcceptScreen({super.key, required this.workId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người đã nhận việc'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: WorkAcceptanceService.getAcceptancesByWork(workId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final acceptances = snapshot.data ?? [];

          if (acceptances.isEmpty) {
            return const Center(child: Text('Chưa có người nào nhận việc.'));
          }

          return ListView.builder(
            itemCount: acceptances.length,
            itemBuilder: (context, index) {
              final user = acceptances[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user['accountUsername'] ?? 'Không rõ'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vị trí: ${user['position'] ?? ''}'),
                    Text('Trạng thái: ${user['status'] ?? ''}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
