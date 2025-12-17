import 'package:code_vault/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        _ThemeSection(),
        SizedBox(height: 24),
        _ServerSection(),
        SizedBox(height: 24),
        _ConnectedDevicesSection(),
      ],
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(activeThemeProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButton<AppTheme>(
              value: activeTheme,
              onChanged: (AppTheme? newTheme) {
                if (newTheme != null) {
                  ref.read(activeThemeProvider.notifier).state = newTheme;
                }
              },
              items: appThemes.map<DropdownMenuItem<AppTheme>>((AppTheme theme) {
                return DropdownMenuItem<AppTheme>(
                  value: theme,
                  child: Text(theme.name),
                );
              }).toList(),
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerSection extends ConsumerWidget {
  const _ServerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isServerRunning = ref.watch(serverRunningProvider);
    final ipAddressAsync = ref.watch(ipAddressProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Server', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isServerRunning ? 'Status: Running' : 'Status: Stopped', style: TextStyle(color: isServerRunning ? Colors.green : Colors.red)),
                ElevatedButton(
                  onPressed: () {
                    if (isServerRunning) {
                      ref.read(serverRunningProvider.notifier).stopServer();
                    } else {
                      ref.read(serverRunningProvider.notifier).startServer();
                    }
                  },
                  child: Text(isServerRunning ? 'Stop' : 'Start'),
                ),
              ],
            ),
            if (isServerRunning) ...[
              const SizedBox(height: 16),
              ipAddressAsync.when(
                data: (ip) => Text('Listening at: http://$ip:8765'),
                loading: () => const Text('Listening at: Fetching IP...'),
                error: (err, stack) => const Text('Listening at: Error'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConnectedDevicesSection extends ConsumerWidget {
  const _ConnectedDevicesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isServerRunning = ref.watch(serverRunningProvider);
    final clientsAsync = ref.watch(clientUpdatesProvider);

    if (!isServerRunning) {
      return const SizedBox.shrink(); // Don't show this section if the server is off
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connected Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            clientsAsync.when(
              data: (clients) {
                if (clients.isEmpty) {
                  return const Text('No clients connected.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return Text(clients[index]);
                  },
                );
              },
              loading: () => const Text('Waiting for connections...'),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
