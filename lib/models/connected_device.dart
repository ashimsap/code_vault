enum RegistrationStatus {
  unregistered,
  temporary,
  permanent,
}

class ConnectedDevice {
  // The name of the device.
  final String name;

  // The IP address of the device.
  final String ipAddress;

  // The registration status of the device.
  final RegistrationStatus registrationStatus;

  // The time the device connected.
  final DateTime connectionTime;

  // The duration of a temporary registration.
  final Duration? temporaryRegistrationDuration;

  ConnectedDevice({
    required this.name,
    required this.ipAddress,
    required this.registrationStatus,
    required this.connectionTime,
    this.temporaryRegistrationDuration,
  });
}
