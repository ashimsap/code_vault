import 'package:code_vault/models/connected_device.dart';
import 'package:code_vault/viewmodels/connected_devices_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/providers.dart';

class ConnectedDevicesSection extends ConsumerWidget {
  const ConnectedDevicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isServerRunning = ref.watch(serverRunningProvider);
    final devices = ref.watch(connectedDevicesProvider);

    if (!isServerRunning) {
      return const SizedBox.shrink();
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
            Text('Connected Devices', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (devices.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Waiting for connections...'),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: devices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return _DeviceListItem(device: device);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceListItem extends ConsumerWidget {
  final ConnectedDevice device;

  const _DeviceListItem({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(connectedDevicesProvider.notifier);
    
    // Safely get the color for each status
    final statusInfo = {
      AccessStatus.pending: (Colors.blue, 'Pending approval'),
      AccessStatus.allowed: (Colors.green, 'Allowed'),
      AccessStatus.tempAllowed: (Colors.teal, 'Temporary Access'),
      AccessStatus.tempBlocked: (Colors.orange, 'Kicked (Temporary)'),
      AccessStatus.banned: (Colors.red, 'Banned'),
    }[device.status] ?? (Colors.grey, 'Unknown');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(device.ipAddress),
      subtitle: Text(
        statusInfo.$2,
        style: TextStyle(color: statusInfo.$1, fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildActionButtons(notifier, device),
      ),
    );
  }

  List<Widget> _buildActionButtons(ConnectedDevicesViewModel notifier, ConnectedDevice device) {
    switch (device.status) {
      case AccessStatus.pending:
        return [
          TextButton(onPressed: () => notifier.tempAllowDevice(device.ipAddress), child: const Text('Temp Allow')),
          TextButton(onPressed: () => notifier.allowDevice(device.ipAddress), child: const Text('Allow')),
          TextButton(onPressed: () => notifier.rejectDevice(device.ipAddress), child: const Text('Reject')),
        ];
      case AccessStatus.allowed:
      case AccessStatus.tempAllowed:
        return [
          TextButton(onPressed: () => notifier.kickDevice(device.ipAddress), child: const Text('Kick')),
          TextButton(onPressed: () => notifier.banDevice(device.ipAddress), child: const Text('Ban')),
        ];
      case AccessStatus.tempBlocked:
      case AccessStatus.banned:
        return [TextButton(onPressed: () => notifier.unblockDevice(device.ipAddress), child: const Text('Unblock'))];
      default:
        return [];
    }
  }
}
