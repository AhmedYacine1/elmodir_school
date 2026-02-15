import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'core/database/isar_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'shared/theme/app_theme.dart';
import 'shared/localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar database
  final dir = await getApplicationDocumentsDirectory();
  IsarService.isar = await Isar.open([
    StudentSchema,
    ParentSchema,
    StaffSchema,
    ClassSchema,
    AttendanceSchema,
    PaymentSchema,
    ExpenseSchema,
    UserSchema,
  ], directory: dir.path);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة المدارس',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar', 'DZ'), // Default to Arabic Algerian
      home: const LoginScreen(),
    );
  }
}
