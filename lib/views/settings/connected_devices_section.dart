import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/api_providers.dart';

class ConnectedDevicesSection extends ConsumerWidget {
  const ConnectedDevicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isServerRunning = ref.watch(serverRunningProvider);
    final clientsAsync = ref.watch(clientUpdatesProvider);

    if (!isServerRunning) {
      return const SizedBox.shrink(); // Don't show this section if the server is off
    }

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
            Text('Connected Devices', style: theme.textTheme.headlineSmall), // Use default text color
            const SizedBox(height: 16),
            clientsAsync.when(
              data: (clients) {
                if (clients.isEmpty) {
                  return const Text('No clients connected.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // To be used inside a ListView
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
