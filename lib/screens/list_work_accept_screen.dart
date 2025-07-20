import 'package:flutter/material.dart';
import '../services/work_acceptance_service.dart';

class ListWorkAcceptScreen extends StatefulWidget {
  final int workId;

  const ListWorkAcceptScreen({super.key, required this.workId});

  @override
  State<ListWorkAcceptScreen> createState() => _ListWorkAcceptScreenState();
}

class _ListWorkAcceptScreenState extends State<ListWorkAcceptScreen> {
  late Future<List<dynamic>> _futureAcceptances;

  @override
  void initState() {
    super.initState();
    _futureAcceptances = WorkAcceptanceService.getAcceptancesByWork(widget.workId);
  }

  Future<void> _updateStatus(int acceptanceId, String newStatus) async {
    try {
      final success = await WorkAcceptanceService.updateAcceptanceStatus(
        widget.workId,
        acceptanceId,
        newStatus,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
        setState(() {
          _futureAcceptances = WorkAcceptanceService.getAcceptancesByWork(widget.workId);
        });
      }
    } catch (e) {
      print('Lỗi cập nhật trạng thái: $e');
      // Hiển thị lỗi chi tiết từ server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }



  final List<String> statusOptions = ['PENDING', 'COMPLETED', 'CANCELLED'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách người đã nhận việc')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAcceptances,
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
              final int acceptanceId = user['id'];
              final String currentStatus = user['status'] ?? 'PENDING';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['accountUsername'] ?? 'Không rõ'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vị trí: ${user['position'] ?? ''}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Trạng thái: '),
                          DropdownButton<String>(
                            value: currentStatus,
                            onChanged: (value) {
                              if (value != null && value != currentStatus) {
                                _updateStatus(acceptanceId, value);
                              }
                            },
                            items: statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
