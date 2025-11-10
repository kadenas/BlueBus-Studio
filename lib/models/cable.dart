class Cable {
  Cable({
    required this.id,
    required this.name,
    required this.type,
    this.lengthMeters,
  });

  final String id;
  final String name;
  final CableType type;
  final double? lengthMeters;
}

enum CableType { power, nmea0183, nmea2000 }
