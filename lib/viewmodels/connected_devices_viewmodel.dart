import 'dart:async';
import 'package:code_vault/models/connected_device.dart';
import 'package:code_vault/repositories/device_repository.dart';
import 'package:code_vault/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceRepositoryProvider = Provider((_) => DeviceRepository());

final connectedDevicesProvider = StateNotifierProvider<ConnectedDevicesViewModel, List<ConnectedDevice>>((ref) {
  return ConnectedDevicesViewModel(ref.read(deviceRepositoryProvider));
});

class ConnectedDevicesViewModel extends StateNotifier<List<ConnectedDevice>> {
  final DeviceRepository _repository;
  Timer? _cleanupTimer;

  ConnectedDevicesViewModel(this._repository) : super([]) {
    _loadDevices();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (_) => _clearInactiveDevices());
  }

  Future<void> _loadDevices() async {
    state = await _repository.loadDevices();
  }

  Future<void> _saveDevices() async {
    await _repository.saveDevices(state);
  }

  void addOrUpdateDevice(String ipAddress) {
    final now = DateTime.now();
    final existingDeviceIndex = state.indexWhere((d) => d.ipAddress == ipAddress);

    if (existingDeviceIndex != -1) {
      final existingDevice = state[existingDeviceIndex];
      if (existingDevice.status == AccessStatus.pending) {
        NotificationService().showConnectionNotification(ipAddress);
      }
      final updatedDevice = existingDevice.copyWith(lastSeen: now);
      state = [...state.sublist(0, existingDeviceIndex), updatedDevice, ...state.sublist(existingDeviceIndex + 1)];
    } else {
      NotificationService().showConnectionNotification(ipAddress);
      state = [...state, ConnectedDevice(ipAddress: ipAddress, lastSeen: now)];
    }
    _saveDevices();
  }

  void allowDevice(String ipAddress) => _updateDeviceStatus(ipAddress, AccessStatus.allowed);
  void tempAllowDevice(String ipAddress) => _updateDeviceStatus(ipAddress, AccessStatus.tempAllowed);
  void rejectDevice(String ipAddress) => _updateDeviceStatus(ipAddress, AccessStatus.banned);
  void banDevice(String ipAddress) => _updateDeviceStatus(ipAddress, AccessStatus.banned); // Corrected Typo
  void kickDevice(String ipAddress) => _updateDeviceStatus(ipAddress, AccessStatus.pending); 
  void unblockDevice(String ipAddress) => _updateDeviceStatus(ipAddress, AccessStatus.pending);

  void _updateDeviceStatus(String ipAddress, AccessStatus status) {
    final deviceIndex = state.indexWhere((d) => d.ipAddress == ipAddress);
    if (deviceIndex != -1) {
      final updatedDevice = state[deviceIndex].copyWith(status: status, lastSeen: DateTime.now());
      state = [...state.sublist(0, deviceIndex), updatedDevice, ...state.sublist(deviceIndex + 1)];
      _saveDevices();
    }
  }

  void _clearInactiveDevices() {
    final now = DateTime.now();
    bool changed = false;
    final newState = state.map((device) {
      if (device.status == AccessStatus.tempAllowed && now.difference(device.lastSeen).inDays >= 1) {
        changed = true;
        return device.copyWith(status: AccessStatus.pending);
      }
      return device;
    }).where((device) {
      if (device.status == AccessStatus.pending && now.difference(device.lastSeen).inSeconds > 30) {
        changed = true;
        return false;
      }
      return true;
    }).toList();

    if (changed) {
      state = newState;
      _saveDevices();
    }
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
