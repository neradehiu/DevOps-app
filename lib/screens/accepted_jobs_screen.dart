import 'package:flutter/material.dart';
import '../services/work_acceptance_service.dart';
import '../services/work_service.dart';

class AcceptedJobsScreen extends StatefulWidget {
  final int accountId;

  const AcceptedJobsScreen({super.key, required this.accountId});

  @override
  State<AcceptedJobsScreen> createState() => _AcceptedJobsScreenState();
}

class _AcceptedJobsScreenState extends State<AcceptedJobsScreen> {
  List<dynamic> acceptedJobs = [];

  @override
  void initState() {
    super.initState();
    loadAcceptedJobs();
  }

  Future<void> loadAcceptedJobs() async {
    try {
      final List<dynamic> allAccepted = [];

      // Giả sử gọi tất cả công việc từ backend
      final allJobs = await WorkService.getAllWorks();

      for (var job in allJobs) {
        final accepted = await WorkAcceptanceService.getAcceptedJobsByStatus(
          job['id'], widget.accountId, 'PENDING',
        );
        if (accepted.isNotEmpty) {
          final jobCopy = {...job};
          jobCopy['status'] = accepted.first['status'];
          allAccepted.add(jobCopy);
        }
      }

      setState(() {
        acceptedJobs = allAccepted;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Công việc đã nhận')),
      body: acceptedJobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: acceptedJobs.length,
        itemBuilder: (context, index) {
          final job = acceptedJobs[index];
          return ListTile(
            title: Text(job['position'] ?? 'Không rõ'),
            subtitle: Text('Trạng thái: ${job['status'] ?? '...'}'),
            trailing: Text('Công ty: ${job['companyName'] ?? ''}'),
          );
        },
      ),
    );
  }
}
