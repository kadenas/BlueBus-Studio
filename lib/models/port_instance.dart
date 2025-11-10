import 'cable.dart';

enum PortType { nmea0183, nmea2000, power }

enum PortDirection { input, output, bidirectional }

class PortInstance {
  PortInstance({
    required this.id,
    required this.name,
    required this.type,
    required this.direction,
    this.connectedCable,
  });

  final String id;
  final String name;
  final PortType type;
  final PortDirection direction;
  final Cable? connectedCable;
}
