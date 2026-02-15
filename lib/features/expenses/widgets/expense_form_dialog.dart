import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../../../models/expense.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  final Expense? expense;

  const ExpenseFormDialog({
    Key? key,
    this.expense,
  }) : super(key: key);

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = '';

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final expense = widget.expense!;
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _dateController.text = expense.date.toString().split(' ')[0];
      _notesController.text = expense.notes ?? '';
      _category = expense.category;
    } else {
      _dateController.text = DateTime.now().toString().split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'إضافة مصروف جديد' : 'تعديل المصروف'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان المصروف';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _category.isEmpty ? null : _category,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  items: const [
                    DropdownMenuItem(value: 'education', child: Text('تعليم')),
                    DropdownMenuItem(value: 'utilities', child: Text('مرافق')),
                    DropdownMenuItem(value: 'salaries', child: Text('رواتب')),
                    DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
                    DropdownMenuItem(value: 'other', child: Text('أخرى')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _category = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الفئة';
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
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'التاريخ'),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.expense?.date ?? DateTime.now(),
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
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 3,
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
              final expense = Expense(
                id: widget.expense?.id,
                title: _titleController.text,
                category: _category,
                amount: double.parse(_amountController.text),
                date: DateTime.parse(_dateController.text),
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              );

              if (widget.expense == null) {
                await ref.read(expenseProvider.notifier).addExpense(expense);
              } else {
                await ref.read(expenseProvider.notifier).updateExpense(expense);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.expense == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}