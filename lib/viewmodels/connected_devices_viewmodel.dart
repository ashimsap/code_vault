import 'package:code_vault/models/connected_device.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectedDevicesProvider = StateNotifierProvider<ConnectedDevicesViewModel, List<ConnectedDevice>>((ref) {
  return ConnectedDevicesViewModel();
});

class ConnectedDevicesViewModel extends StateNotifier<List<ConnectedDevice>> {
  ConnectedDevicesViewModel() : super([]);

  void addOrUpdateDevice(String ipAddress) {
    final existingDeviceIndex = state.indexWhere((d) => d.ipAddress == ipAddress);
    if (existingDeviceIndex != -1) {
      final updatedDevice = state[existingDeviceIndex].copyWith(lastSeen: DateTime.now());
      state = [
        ...state.sublist(0, existingDeviceIndex),
        updatedDevice,
        ...state.sublist(existingDeviceIndex + 1),
      ];
    } else {
      state = [...state, ConnectedDevice(ipAddress: ipAddress, lastSeen: DateTime.now())];
    }
  }

  void kickDevice(String ipAddress) {
    _updateDeviceStatus(ipAddress, AccessStatus.tempBlocked);
  }

  void banDevice(String ipAddress) {
    _updateDeviceStatus(ipAddress, AccessStatus.banned);
  }

  void unblockDevice(String ipAddress) {
    _updateDeviceStatus(ipAddress, AccessStatus.allowed);
  }

  void _updateDeviceStatus(String ipAddress, AccessStatus status) {
    final deviceIndex = state.indexWhere((d) => d.ipAddress == ipAddress);
    if (deviceIndex != -1) {
      final updatedDevice = state[deviceIndex].copyWith(status: status);
      state = [
        ...state.sublist(0, deviceIndex),
        updatedDevice,
        ...state.sublist(deviceIndex + 1),
      ];
    }
  }

  void clearInactiveDevices() {
    final now = DateTime.now();
    state = state.where((device) {
      if (device.status == AccessStatus.tempBlocked) {
        // Temp-blocked devices are unblocked after 1 minute
        return now.difference(device.lastSeen).inMinutes < 1;
      }
      // Allowed devices are removed after 15 seconds of inactivity
      return now.difference(device.lastSeen).inSeconds < 15;
    }).toList();
  }
}
