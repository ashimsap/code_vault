import 'dart:convert';
import 'package:code_vault/models/connected_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceRepository {
  static const _key = 'connected_devices';

  Future<void> saveDevices(List<ConnectedDevice> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceList = devices.map((d) => {
      'ipAddress': d.ipAddress,
      'status': d.status.index,
      'lastSeen': d.lastSeen.toIso8601String(),
    }).toList();
    await prefs.setString(_key, jsonEncode(deviceList));
  }

  Future<List<ConnectedDevice>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_key);
    if (savedData == null) {
      return [];
    }

    final deviceList = jsonDecode(savedData) as List;
    return deviceList.map((d) => ConnectedDevice(
      ipAddress: d['ipAddress'],
      status: AccessStatus.values[d['status']],
      lastSeen: DateTime.parse(d['lastSeen']),
    )).toList();
  }
}
