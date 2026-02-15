import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_provider.dart';
import '../../../models/payment.dart';
import '../../../models/student.dart';
import '../../../core/database/isar_service.dart';
import '../../students/providers/student_provider.dart';
import '../widgets/payment_form_dialog.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  List<Payment> filteredPayments = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredPayments = ref.read(paymentProvider);
  }

  void _runFilter(String query) {
    final payments = ref.read(paymentProvider);
    setState(() {
      if (query.isEmpty) {
        filteredPayments = payments;
      } else {
        filteredPayments = payments.where((payment) =>
            _getStudentName(payment.studentId, ref).toLowerCase().contains(query.toLowerCase()) ||
            payment.amount.toString().contains(query.toLowerCase()) ||
            payment.status.toLowerCase().contains(query.toLowerCase()) ||
            payment.period.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(paymentProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المدفوعات'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'بحث',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  _runFilter(value);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    return ListView.builder(
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        return Card(
                          child: ListTile(
                            title: Text(_getStudentName(payment.studentId, ref)),
                            subtitle: Text(
                              'المبلغ: ${payment.amount.toStringAsFixed(2)} د.ج | '
                              'الحالة: ${payment.status} | '
                              'الفترة: ${payment.period} | '
                              'التاريخ: ${payment.paymentDate.toString().split(' ')[0]}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showPaymentFormDialog(context, payment, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, payment.id!, ref),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showPaymentFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _getStudentName(int studentId, WidgetRef ref) {
    final students = ref.read(studentProvider);
    final student = students.firstWhere((element) => element.id == studentId, orElse: () => Student(firstName: 'غير معروف', lastName: '', birthDate: DateTime.now(), gender: '', registrationNumber: '', isActive: true));
    return '${student.firstName} ${student.lastName}';
  }

  Future<void> _showPaymentFormDialog(BuildContext context, Payment? payment, WidgetRef ref) async {
    final students = ref.read(studentProvider);

    await showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        payment: payment,
        students: students,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الدفع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(paymentProvider.notifier).deletePayment(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}