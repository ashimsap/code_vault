import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/providers.dart';

class ServerSection extends ConsumerWidget {
  const ServerSection({super.key});

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
            Text('Server', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary, // Using accent color
            )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isServerRunning ? 'Status: Running' : 'Status: Stopped',
                  style: TextStyle(color: isServerRunning ? Theme.of(context).colorScheme.primary : Colors.red), // Using accent color when running
                ),
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
