import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/views/home_screen.dart';
import 'package:code_vault/views/settings_view.dart';

// A provider to hold the current selected tab index
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final brightness = Theme.of(context).brightness;

    // This widget allows us to control the system's UI overlay (like the status bar)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Make the status bar background transparent
        statusBarColor: Colors.transparent,
        // Automatically adjust the icon brightness based on the app's theme
        statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness, // For iOS
      ),
      child: Scaffold(
        body: _widgetOptions.elementAt(selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (index) => ref.read(selectedIndexProvider.notifier).state = index,
        ),
      ),
    );
  }
}
