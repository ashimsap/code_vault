import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/api_providers.dart';

class ServerSection extends ConsumerWidget {
  const ServerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isServerRunning = ref.watch(serverRunningProvider);
    final ipAddressAsync = ref.watch(ipAddressProvider);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server', style: theme.textTheme.headlineSmall), // Use default text color
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isServerRunning ? 'Status: Running' : 'Status: Stopped',
                  // Use generic green for status, not the accent color
                  style: TextStyle(color: isServerRunning ? Colors.green : Colors.red),
                ),
                // Use a more neutral OutlinedButton to avoid strong accent color background
                OutlinedButton(
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
