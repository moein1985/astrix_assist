import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'core/injection_container.dart';
import 'core/router.dart';
import 'core/theme_manager.dart';
import 'core/locale_manager.dart';
import 'core/notification_service.dart';
import 'core/background_service_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load settings
  await ThemeManager.load();
  await LocaleManager.load();
  
  // Setup dependencies (uses AppConfig.useMockRepositories)
  await setupDependencies();

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize background service
  await BackgroundServiceManager().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeManager.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder(
          valueListenable: LocaleManager.locale,
          builder: (context, locale, _) {
            return MaterialApp.router(
              routerConfig: router,
              title: 'Astrix Assist',
              theme: ThemeManager.lightTheme,
              darkTheme: ThemeManager.darkTheme,
              themeMode: themeMode,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        );
      },
    );
  }
}
