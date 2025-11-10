import 'device_instance.dart';

class Project {
  Project({
    required this.name,
    this.description,
    List<DeviceInstance>? devices,
  }) : devices = devices ?? [];

  final String name;
  final String? description;
  final List<DeviceInstance> devices;
}
