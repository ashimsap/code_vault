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
    final activeTheme = ref.watch(activeThemeProvider);

    return MaterialApp(
      title: 'Code Vault',
      theme: activeTheme,
      darkTheme: activeTheme, // Apply the same logic for dark theme
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: const MainScreen(),
    );
  }
}
