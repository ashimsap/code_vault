import 'package:code_vault/services/notification_service.dart';
import 'package:code_vault/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the notification service
  final notificationService = NotificationService();
  await notificationService.init();
  // **THE FIX: Request permission on startup**
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final activeTheme = ref.watch(activeThemeProvider);

    return MaterialApp(
      title: 'Code Vault',
      theme: activeTheme,
      darkTheme: activeTheme, 
      themeMode: themeSettings.themeMode,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
