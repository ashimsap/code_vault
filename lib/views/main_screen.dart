import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/views/home_screen.dart';
import 'package:code_vault/views/settings_view.dart';
import 'package:flutter_riverpod/legacy.dart';

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }

        // 1. If on Settings page, navigate back to Home
        if (selectedIndex != 0) {
          ref.read(selectedIndexProvider.notifier).state = 0;
          return;
        }

        // 2. If on Home, check scroll position
        final homeScrollController = ref.read(homeScrollControllerProvider);
        if (homeScrollController != null && homeScrollController.hasClients) {
          // If scrolled down, animate to top
          if (homeScrollController.offset > 0) {
            homeScrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            return;
          }
        }

        // 3. If at top of Home, exit the app
        await SystemNavigator.pop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
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
      ),
    );
  }
}
