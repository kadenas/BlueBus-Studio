import 'port_instance.dart';

class DeviceInstance {
  DeviceInstance({
    required this.id,
    required this.name,
    required this.deviceType,
    List<PortInstance>? ports,
  }) : ports = ports ?? [];

  final String id;
  final String name;
  final String deviceType;
  final List<PortInstance> ports;
}
