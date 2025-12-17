import 'package:code_vault/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/data_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
