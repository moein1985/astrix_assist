import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English (default)
    Locale('fa', ''), // Farsi
  ];

  // Translations map
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_title': 'Astrix Assist',
      
      // Login Page
      'saved_servers': 'Saved Servers',
      'add_server': 'Add Server',
      'no_servers': 'No servers saved',
      'add_server_to_start': 'Add a server to get started',
      'server_name': 'Server Name',
      'ip_address': 'IP Address',
      'port': 'Port',
      'username': 'Username',
      'password': 'Password',
      'add_new_server': 'Add New Server',
      'edit_server': 'Edit Server',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete_server': 'Delete Server',
      'delete_confirm': 'Are you sure you want to delete',
      'delete': 'Delete',
      'edit': 'Edit',
      'active': 'Active',
      'mock_mode': 'Test Mode (Mock Data)',
      'mock_mode_desc': 'Login without Asterisk server',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      
      // Dashboard
      'dashboard': 'Dashboard',
      'extensions': 'Extensions',
      'active_calls': 'Active Calls',
      'queues': 'Queues',
      'waiting': 'Waiting',
      'available': 'Available',
      'call': 'Call',
      'online': 'Online',
      'offline': 'Offline',
      'recent_calls': 'Recent Calls',
      'no_active_calls': 'No active calls',
      'duration': 'Duration',
      
      // Validation
      'field_required': 'This field is required',
      'name_required': 'Name is required',
      'ip_required': 'IP address is required',
      'port_required': 'Port is required',
      
      // Common
      'loading': 'Loading...',
      'error': 'Error',
      'refresh': 'Refresh',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
    },
    'fa': {
      // App
      'app_title': 'دستیار استریکس',
      
      // Login Page
      'saved_servers': 'سرورهای ذخیره شده',
      'add_server': 'افزودن سرور',
      'no_servers': 'هیچ سروری ذخیره نشده',
      'add_server_to_start': 'برای شروع یک سرور اضافه کنید',
      'server_name': 'نام سرور',
      'ip_address': 'آدرس IP',
      'port': 'پورت',
      'username': 'نام کاربری',
      'password': 'رمز عبور',
      'add_new_server': 'افزودن سرور جدید',
      'edit_server': 'ویرایش سرور',
      'save': 'ذخیره',
      'cancel': 'لغو',
      'delete_server': 'حذف سرور',
      'delete_confirm': 'آیا از حذف اطمینان دارید',
      'delete': 'حذف',
      'edit': 'ویرایش',
      'active': 'فعال',
      'mock_mode': 'حالت آزمایشی (Mock Data)',
      'mock_mode_desc': 'ورود بدون نیاز به سرور Asterisk',
      'logout': 'خروج',
      'logout_confirm': 'آیا از خروج اطمینان دارید؟',
      
      // Dashboard
      'dashboard': 'داشبورد',
      'extensions': 'داخلی‌ها',
      'active_calls': 'تماس‌های فعال',
      'queues': 'صف‌ها',
      'waiting': 'در انتظار',
      'available': 'آزاد',
      'call': 'تماس',
      'online': 'آنلاین',
      'offline': 'آفلاین',
      'recent_calls': 'تماس‌های اخیر',
      'no_active_calls': 'تماس فعالی وجود ندارد',
      'duration': 'مدت',
      
      // Validation
      'field_required': 'این فیلد الزامی است',
      'name_required': 'نام الزامی است',
      'ip_required': 'آدرس IP الزامی است',
      'port_required': 'پورت الزامی است',
      
      // Common
      'loading': 'در حال بارگذاری...',
      'error': 'خطا',
      'refresh': 'بروزرسانی',
      'settings': 'تنظیمات',
      'language': 'زبان',
      'theme': 'پوسته',
      'light': 'روشن',
      'dark': 'تیره',
      'system': 'سیستم',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand method
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
