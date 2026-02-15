import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _totalStudents = 0;
  double _monthlyIncome = 0.0;
  int _unpaidStudents = 0;
  Map<String, int> _attendanceSummary = {'present': 0, 'absent': 0, 'justified': 0};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final now = DateTime.now();
      
      // Load dashboard statistics
      _totalStudents = await IsarService.getTotalStudentsCount();
      _monthlyIncome = await IsarService.getMonthlyIncome(now);
      _unpaidStudents = await IsarService.getUnpaidStudentsCount();
      _attendanceSummary = await IsarService.getAttendanceSummary(now);
      
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.account_circle),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('تسجيل الخروج'),
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'مرحباً بك في نظام إدارة المدارس',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    StatCard(
                      title: 'عدد الطلاب',
                      value: _totalStudents.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'الدخل الشهري',
                      value: '${_monthlyIncome.toStringAsFixed(2)} د.ج',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'طلاب بدون دفع',
                      value: _unpaidStudents.toString(),
                      icon: Icons.money_off,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'الحضور اليومي',
                      value: '${_attendanceSummary['present']} حاضر',
                      icon: Icons.check_circle,
                      color: Colors.purple,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Recent activity section
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'النشاط الأخير',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.school, color: Colors.blue),
                          title: const Text('إدارة الطلاب'),
                          subtitle: const Text('عرض وتحرير معلومات الطلاب'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to students screen
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.calendar_today, color: Colors.green),
                          title: const Text('الحضور'),
                          subtitle: const Text('تسجيل الحضور اليومي للطلاب'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to attendance screen
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.payment, color: Colors.orange),
                          title: const Text('المدفوعات'),
                          subtitle: const Text('إدارة اشتراكات الطلاب'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to payments screen
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
      ),
    );
  }
}