import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String schoolName = 'مدرسة الأمل';
  String academicYear = '2023-2024';
  bool isDarkMode = false;
  String language = 'ar';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات المدرسة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'اسم المدرسة',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: schoolName,
                        onChanged: (value) {
                          setState(() {
                            schoolName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'السنة الدراسية',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: academicYear,
                        onChanged: (value) {
                          setState(() {
                            academicYear = value;
                          });
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
                        'الإعدادات العامة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('الوضع الليلي'),
                        value: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isDarkMode = value;
                          });
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('اللغة'),
                        subtitle: Text(language == 'ar' ? 'العربية' : language == 'fr' ? 'الفرنسية' : 'الإنجليزية'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _selectLanguage(context),
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
                        'النسخ الاحتياطي والاستعادة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('إنشاء نسخة احتياطية'),
                        trailing: const Icon(Icons.backup),
                        onTap: () => _backupDatabase(context),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('استعادة من نسخة احتياطية'),
                        trailing: const Icon(Icons.restore),
                        onTap: () => _restoreDatabase(context),
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

  void _selectLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: language,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    language = value;
                  });
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('الفرنسية'),
              value: 'fr',
              groupValue: language,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    language = value;
                  });
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('الإنجليزية'),
              value: 'en',
              groupValue: language,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    language = value;
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/backup_$timestamp.isar');
      
      // Copy the database file to backup location
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dbDir.path}/default.isar');
      
      if (await dbFile.exists()) {
        await dbFile.copy(backupFile.path);
        
        // Add password protection by hashing
        final password = await _showPasswordDialog(context, 'أدخل كلمة المرور للنسخة الاحتياطية');
        if (password != null) {
          // In a real app, you would encrypt the file with the password
          // For now, we just show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء النسخة الاحتياطية بنجاح')),
          );
        }
      } else {
        throw Exception('ملف قاعدة البيانات غير موجود');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء إنشاء النسخة الاحتياطية: $e')),
      );
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      
      if (!await backupDir.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد نسخ احتياطية')),
        );
        return;
      }
      
      final files = await backupDir.list().toList();
      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد نسخ احتياطية')),
        );
        return;
      }
      
      // Sort files by modification time (newest first)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      final selectedFile = await showDialog<File>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('اختر نسخة احتياطية للاستعادة'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index] as File;
                  final fileName = file.path.split('/').last;
                  return ListTile(
                    title: Text(fileName),
                    subtitle: Text(_formatDateTime(file.statSync().modified)),
                    onTap: () => Navigator.pop(context, file),
                  );
                },
              ),
            ),
          );
        },
      );
      
      if (selectedFile != null) {
        final password = await _showPasswordDialog(context, 'أدخل كلمة المرور لفك تشفير النسخة الاحتياطية');
        if (password != null) {
          // In a real app, you would decrypt the file with the password
          // Then copy it to the database location
          
          // Close the current database
          // await Isar.getInstance().close();
          
          // Copy the backup file to database location
          final dbDir = await getApplicationDocumentsDirectory();
          final dbFile = File('${dbDir.path}/default.isar');
          
          await selectedFile.copy(dbFile.path);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم استعادة قاعدة البيانات بنجاح. يرجى إعادة تشغيل التطبيق.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء استعادة قاعدة البيانات: $e')),
      );
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context, String title) async {
    final passwordController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, passwordController.text);
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}