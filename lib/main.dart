import 'package:flutter/material.dart';
import 'core/injection_container.dart';
import 'core/router.dart';
import 'core/theme_manager.dart';
import 'core/notification_service.dart';
import 'core/background_service_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await ThemeManager.load();

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
      builder: (context, mode, _) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Astrix Assist',
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: mode,
        );
      },
    );
  }
}
