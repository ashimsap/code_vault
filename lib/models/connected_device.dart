enum AccessStatus { allowed, tempBlocked, banned }

class ConnectedDevice {
  final String ipAddress;
  final AccessStatus status;
  final DateTime lastSeen;

  ConnectedDevice({
    required this.ipAddress,
    this.status = AccessStatus.allowed,
    required this.lastSeen,
  });

  ConnectedDevice copyWith({
    AccessStatus? status,
    DateTime? lastSeen,
  }) {
    return ConnectedDevice(
      ipAddress: ipAddress,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
