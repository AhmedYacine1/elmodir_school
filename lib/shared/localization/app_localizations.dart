import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar', 'DZ'), // Arabic Algerian
    Locale('fr', 'FR'), // French French
    Locale('en', 'US'), // English US
  ];

  static const fallbackLocale = Locale('ar', 'DZ');

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get title => 'نظام إدارة المدارس';
  String get loginTitle => 'تسجيل الدخول';
  String get usernameLabel => 'اسم المستخدم';
  String get passwordLabel => 'كلمة المرور';
  String get loginButton => 'تسجيل الدخول';
  String get logout => 'تسجيل الخروج';
  String get dashboard => 'لوحة التحكم';
  String get students => 'الطلاب';
  String get parents => 'الآباء';
  String get staff => 'الموظفين';
  String get classes => 'الفصول';
  String get attendance => 'الحضور';
  String get payments => 'المدفوعات';
  String get expenses => 'المصاريف';
  String get reports => 'التقارير';
  String get settings => 'الإعدادات';
  String get firstName => 'الاسم الأول';
  String get lastName => 'الاسم الأخير';
  String get birthDate => 'تاريخ الميلاد';
  String get gender => 'الجنس';
  String get address => 'العنوان';
  String get phone => 'الهاتف';
  String get email => 'البريد الإلكتروني';
  String get save => 'حفظ';
  String get cancel => 'إلغاء';
  String get edit => 'تعديل';
  String get delete => 'حذف';
  String get search => 'بحث';
  String get addNew => 'إضافة جديد';
  String get total => 'المجموع';
  String get amount => 'المبلغ';
  String get date => 'التاريخ';
  String get status => 'الحالة';
  String get action => 'إجراء';
  String get successMessage => 'تمت العملية بنجاح';
  String get errorMessage => 'حدث خطأ أثناء العملية';
  String get confirmDelete => 'هل أنت متأكد من رغبتك في الحذف؟';
  String get yes => 'نعم';
  String get no => 'لا';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}