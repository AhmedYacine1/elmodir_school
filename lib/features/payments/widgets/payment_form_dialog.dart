import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_provider.dart';
import '../../../models/payment.dart';
import '../../../models/student.dart';

class PaymentFormDialog extends ConsumerStatefulWidget {
  final Payment? payment;
  final List<Student> students;

  const PaymentFormDialog({
    Key? key,
    this.payment,
    required this.students,
  }) : super(key: key);

  @override
  ConsumerState<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends ConsumerState<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _discountController = TextEditingController();
  final _dateController = TextEditingController();
  int? _selectedStudentId;
  String _status = '';
  String _period = '';

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      final payment = widget.payment!;
      _amountController.text = payment.amount.toString();
      _discountController.text = payment.discount.toString();
      _dateController.text = payment.paymentDate.toString().split(' ')[0];
      _selectedStudentId = payment.studentId;
      _status = payment.status;
      _period = payment.period;
    } else {
      _dateController.text = DateTime.now().toString().split(' ')[0];
      _discountController.text = '0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.payment == null ? 'إضافة دفع جديد' : 'تعديل الدفع'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedStudentId,
                  decoration: const InputDecoration(labelText: 'الطالب'),
                  items: widget.students.map((student) {
                    return DropdownMenuItem(
                      value: student.id,
                      child: Text('${student.firstName} ${student.lastName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStudentId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'الرجاء اختيار الطالب';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال المبلغ';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال مبلغ صحيح';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'الخصم'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الخصم';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال خصم صحيح';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'تاريخ الدفع'),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.payment?.paymentDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateController.text = date.toString().split(' ')[0];
                      });
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status.isEmpty ? null : _status,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: const [
                    DropdownMenuItem(value: 'paid', child: Text('مدفوع')),
                    DropdownMenuItem(value: 'partial', child: Text('جزئي')),
                    DropdownMenuItem(value: 'unpaid', child: Text('غير مدفوع')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الحالة';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _period.isEmpty ? null : _period,
                  decoration: const InputDecoration(labelText: 'الفترة'),
                  items: const [
                    DropdownMenuItem(value: 'month', child: Text('شهر')),
                    DropdownMenuItem(value: 'term', child: Text('فصل')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _period = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الفترة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final payment = Payment(
                id: widget.payment?.id,
                studentId: _selectedStudentId!,
                amount: double.parse(_amountController.text),
                discount: double.parse(_discountController.text),
                paymentDate: DateTime.parse(_dateController.text),
                status: _status,
                period: _period,
              );

              if (widget.payment == null) {
                await ref.read(paymentProvider.notifier).addPayment(payment);
              } else {
                await ref.read(paymentProvider.notifier).updatePayment(payment);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.payment == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}