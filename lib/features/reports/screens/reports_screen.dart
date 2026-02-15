import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/student.dart';
import '../../../models/payment.dart';
import '../../../models/attendance.dart';
import '../../../models/expense.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقرير مالي',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<double>(
                        future: IsarService.getMonthlyIncome(DateTime.now()),
                        builder: (context, snapshot) {
                          final income = snapshot.data ?? 0.0;
                          return ListTile(
                            title: const Text('الدخل الشهري'),
                            trailing: Text(
                              '${income.toStringAsFixed(2)} د.ج',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                      FutureBuilder<int>(
                        future: IsarService.getTotalActiveStudentsCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return ListTile(
                            title: const Text('عدد الطلاب النشطين'),
                            trailing: Text(
                              count.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                      FutureBuilder<int>(
                        future: IsarService.getUnpaidStudentsCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return ListTile(
                            title: const Text('الطلاب غير المدفوعين'),
                            trailing: Text(
                              count.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقرير الحضور',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, int>>(
                        future: IsarService.getAttendanceSummary(DateTime.now()),
                        builder: (context, snapshot) {
                          final summary = snapshot.data ?? {'present': 0, 'absent': 0, 'justified': 0};
                          return Column(
                            children: [
                              ListTile(
                                title: const Text('الحضور'),
                                trailing: Text(
                                  '${summary['present'] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ),
                              ListTile(
                                title: const Text('الغياب'),
                                trailing: Text(
                                  '${summary['absent'] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ),
                              ListTile(
                                title: const Text('الغياب المبرر'),
                                trailing: Text(
                                  '${summary['justified'] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}