import 'dart:async';
import 'package:code_vault/models/connected_device.dart';
import 'package:code_vault/viewmodels/connected_devices_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/providers.dart';

class ConnectedDevicesSection extends ConsumerStatefulWidget {
  const ConnectedDevicesSection({super.key});

  @override
  ConsumerState<ConnectedDevicesSection> createState() => _ConnectedDevicesSectionState();
}

class _ConnectedDevicesSectionState extends ConsumerState<ConnectedDevicesSection> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final devices = ref.watch(connectedDevicesProvider);

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
            Text('Devices', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (devices.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No known devices.'),
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
    final isServerRunning = ref.watch(serverRunningProvider);

    final isOnline = isServerRunning && 
        DateTime.now().difference(device.lastSeen).inSeconds < 45;
    
    final statusInfo = {
      AccessStatus.pending: (Colors.blue, 'Pending approval'),
      AccessStatus.allowed: (Colors.green, 'Allowed'),
      AccessStatus.tempAllowed: (Colors.teal, 'Temporary Access'),
      AccessStatus.tempBlocked: (Colors.orange, 'Kicked (Temporary)'),
      AccessStatus.banned: (Colors.red, 'Banned'),
    }[device.status] ?? (Colors.grey, 'Unknown');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Tooltip(
        message: isOnline ? 'Online' : 'Offline',
        child: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: isOnline ? Colors.greenAccent : Colors.redAccent,
            shape: BoxShape.circle,
            boxShadow: [
              if (isOnline)
                BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
            ],
          ),
        ),
      ),
      title: Text(device.ipAddress, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis,),
      subtitle: Text(
        statusInfo.$2,
        style: TextStyle(color: statusInfo.$1, fontWeight: FontWeight.bold, fontSize: 12),
      ),
      // **THE FIX: Replace the Row of buttons with a single PopupMenuButton**
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'temp_allow': notifier.tempAllowDevice(device.ipAddress); break;
            case 'allow': notifier.allowDevice(device.ipAddress); break;
            case 'reject': notifier.rejectDevice(device.ipAddress); break;
            case 'kick': notifier.kickDevice(device.ipAddress); break;
            case 'ban': notifier.banDevice(device.ipAddress); break;
            case 'unblock': notifier.unblockDevice(device.ipAddress); break;
          }
        },
        itemBuilder: (BuildContext context) {
          switch (device.status) {
            case AccessStatus.pending:
              return [
                const PopupMenuItem(value: 'temp_allow', child: Text('Temp Allow')),
                const PopupMenuItem(value: 'allow', child: Text('Allow')),
                const PopupMenuItem(value: 'reject', child: Text('Reject')),
              ];
            case AccessStatus.allowed:
            case AccessStatus.tempAllowed:
              return [
                const PopupMenuItem(value: 'kick', child: Text('Kick')),
                const PopupMenuItem(value: 'ban', child: Text('Ban')),
              ];
            case AccessStatus.tempBlocked:
            case AccessStatus.banned:
              return [const PopupMenuItem(value: 'unblock', child: Text('Unblock'))];
            default:
              return [];
          }
        },
        icon: const Icon(Icons.more_vert),
      ),
    );
  }
}
