import 'package:flutter/material.dart';
import 'core/injection_container.dart';
import 'core/router.dart';
import 'core/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await ThemeManager.load();
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
          theme: ThemeData(primarySwatch: Colors.blue),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
        );
      },
    );
  }
}
