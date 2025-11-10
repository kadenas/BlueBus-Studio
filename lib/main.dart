import 'package:flutter/material.dart';

void main() {
  runApp(const BlueBusApp());
}

class BlueBusApp extends StatelessWidget {
  const BlueBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueBus Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1F2430),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B8BF5),
          surface: Color(0xFF252C3A),
          background: Color(0xFF1F2430),
          onBackground: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const BlueBusHomePage(),
    );
  }
}

class BlueBusHomePage extends StatefulWidget {
  const BlueBusHomePage({super.key});

  @override
  State<BlueBusHomePage> createState() => _BlueBusHomePageState();
}

class _BlueBusHomePageState extends State<BlueBusHomePage> {
  final List<DeviceModel> _devices = [];
  final List<CableModel> _cables = [];
  int _deviceCounter = 0;
  int _portCounter = 0;
  String? _selectedPortId;

  late final List<DeviceTemplate> _templates = _buildTemplates();

  List<DeviceTemplate> _buildTemplates() {
    const sizeSmall = Size(160, 100);
    const sizeMedium = Size(180, 120);
    const sizeLarge = Size(200, 140);

    return [
      DeviceTemplate(
        name: 'Batería 12V',
        size: sizeSmall,
        ports: const [
          PortTemplate(
            name: 'Positivo',
            type: PortType.powerPos,
            offset: Offset(30, 78),
          ),
          PortTemplate(
            name: 'Negativo',
            type: PortType.powerNeg,
            offset: Offset(65, 78),
          ),
        ],
      ),
      DeviceTemplate(
        name: 'Batería 24V',
        size: sizeSmall,
        metadata: const {'voltage': 24},
        ports: const [
          PortTemplate(
            name: 'Positivo',
            type: PortType.powerPos,
            offset: Offset(30, 78),
          ),
          PortTemplate(
            name: 'Negativo',
            type: PortType.powerNeg,
            offset: Offset(65, 78),
          ),
        ],
      ),
      DeviceTemplate(
        name: 'GPS NMEA-0183',
        size: sizeMedium,
        ports: const [
          PortTemplate(
            name: 'Power +',
            type: PortType.powerPos,
            offset: Offset(20, 55),
          ),
          PortTemplate(
            name: 'Power -',
            type: PortType.powerNeg,
            offset: Offset(20, 85),
          ),
          PortTemplate(
            name: 'NMEA OUT +',
            type: PortType.nmeaOutPos,
            offset: Offset(160, 50),
          ),
          PortTemplate(
            name: 'NMEA OUT -',
            type: PortType.nmeaOutNeg,
            offset: Offset(160, 80),
          ),
        ],
      ),
      DeviceTemplate(
        name: 'Plotter / MFD',
        size: sizeLarge,
        ports: const [
          PortTemplate(
            name: 'NMEA IN +',
            type: PortType.nmeaInPos,
            offset: Offset(20, 55),
          ),
          PortTemplate(
            name: 'NMEA IN -',
            type: PortType.nmeaInNeg,
            offset: Offset(20, 85),
          ),
          PortTemplate(
            name: 'NMEA OUT +',
            type: PortType.nmeaOutPos,
            offset: Offset(180, 55),
          ),
          PortTemplate(
            name: 'Power +',
            type: PortType.powerPos,
            offset: Offset(90, 118),
          ),
          PortTemplate(
            name: 'Power -',
            type: PortType.powerNeg,
            offset: Offset(120, 118),
          ),
          PortTemplate(
            name: 'N2K',
            type: PortType.n2k,
            offset: Offset(150, 125),
          ),
        ],
      ),
      DeviceTemplate(
        name: 'Sensor AIS NMEA-2000',
        size: sizeMedium,
        ports: const [
          PortTemplate(
            name: 'N2K',
            type: PortType.n2k,
            offset: Offset(90, 105),
          ),
          PortTemplate(
            name: 'Power +',
            type: PortType.powerPos,
            offset: Offset(20, 55),
          ),
          PortTemplate(
            name: 'Power -',
            type: PortType.powerNeg,
            offset: Offset(20, 85),
          ),
        ],
      ),
      DeviceTemplate(
        name: 'Multiplexor 0183',
        size: sizeMedium,
        ports: const [
          PortTemplate(
            name: 'Power +',
            type: PortType.powerPos,
            offset: Offset(80, 35),
          ),
          PortTemplate(
            name: 'Power -',
            type: PortType.powerNeg,
            offset: Offset(120, 35),
          ),
          PortTemplate(
            name: 'NMEA IN +',
            type: PortType.nmeaInPos,
            offset: Offset(20, 70),
          ),
          PortTemplate(
            name: 'NMEA IN -',
            type: PortType.nmeaInNeg,
            offset: Offset(20, 95),
          ),
          PortTemplate(
            name: 'NMEA OUT +',
            type: PortType.nmeaOutPos,
            offset: Offset(160, 70),
          ),
          PortTemplate(
            name: 'NMEA OUT -',
            type: PortType.nmeaOutNeg,
            offset: Offset(160, 95),
          ),
        ],
      ),
      DeviceTemplate(
        name: 'Módulo alimentación',
        size: sizeSmall,
        ports: const [
          PortTemplate(
            name: 'Entrada +',
            type: PortType.powerPos,
            offset: Offset(30, 45),
          ),
          PortTemplate(
            name: 'Entrada -',
            type: PortType.powerNeg,
            offset: Offset(30, 70),
          ),
          PortTemplate(
            name: 'Salida +',
            type: PortType.powerPos,
            offset: Offset(130, 45),
          ),
          PortTemplate(
            name: 'Salida -',
            type: PortType.powerNeg,
            offset: Offset(130, 70),
          ),
        ],
      ),
    ];
  }

  void _addDevice(DeviceTemplate template) {
    final deviceId = 'device_${_deviceCounter++}';
    final baseOffset = Offset(120 + (_devices.length * 30) % 300, 120 + ((_devices.length * 30) % 180));

    final ports = template.ports
        .map(
          (portTemplate) => PortModel(
            id: 'port_${_portCounter++}',
            deviceId: deviceId,
            name: portTemplate.name,
            type: portTemplate.type,
            offset: portTemplate.offset,
          ),
        )
        .toList();

    final device = DeviceModel(
      id: deviceId,
      name: template.name,
      size: template.size,
      position: baseOffset,
      ports: ports,
      metadata: template.metadata,
    );

    setState(() {
      _devices.add(device);
    });
  }

  void _handlePortTap(PortModel port) {
    if (_selectedPortId == null) {
      setState(() {
        _selectedPortId = port.id;
      });
      return;
    }

    if (_selectedPortId == port.id) {
      setState(() {
        _selectedPortId = null;
      });
      return;
    }

    final PortModel? firstPort = _findPortById(_selectedPortId!);
    if (firstPort == null) {
      setState(() {
        _selectedPortId = port.id;
      });
      return;
    }

    if (arePortsCompatible(firstPort.type, port.type) &&
        !_cableExistsBetween(firstPort.id, port.id)) {
      final cable = CableModel(
        fromPortId: firstPort.id,
        toPortId: port.id,
        type: firstPort.type,
      );
      setState(() {
        _cables.add(cable);
        _selectedPortId = null;
      });
    } else {
      setState(() {
        _selectedPortId = port.id;
      });
    }
  }

  bool _cableExistsBetween(String a, String b) {
    return _cables.any(
      (c) =>
          (c.fromPortId == a && c.toPortId == b) ||
          (c.fromPortId == b && c.toPortId == a),
    );
  }

  PortModel? _findPortById(String portId) {
    for (final device in _devices) {
      for (final port in device.ports) {
        if (port.id == portId) {
          return port;
        }
      }
    }
    return null;
  }

  DeviceModel? _deviceForPort(String portId) {
    for (final device in _devices) {
      if (device.ports.any((port) => port.id == portId)) {
        return device;
      }
    }
    return null;
  }

  Offset? _portCenter(String portId) {
    final port = _findPortById(portId);
    if (port == null) {
      return null;
    }
    final device = _deviceForPort(portId);
    if (device == null) {
      return null;
    }
    return device.position + port.offset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: Color(0xFF232838),
              border: Border(
                right: BorderSide(color: Color(0x332C3648)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BlueBus Studio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dispositivos disponibles',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      return _DeviceTemplateTile(
                        template: template,
                        onTap: () => _addDevice(template),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF1F2430),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final List<Widget> stackChildren = [];

                  for (final device in _devices) {
                    stackChildren.add(
                      _DraggableDevice(
                        key: ValueKey(device.id),
                        device: device,
                        onPositionChanged: (newOffset) {
                          setState(() {
                            final index =
                                _devices.indexWhere((d) => d.id == device.id);
                            if (index != -1) {
                              _devices[index] =
                                  _devices[index].copyWith(position: newOffset);
                            }
                          });
                        },
                        onPortTap: _handlePortTap,
                        selectedPortId: _selectedPortId,
                      ),
                    );
                  }

                  stackChildren.add(
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: CablePainter(
                            cables: _cables,
                            portCenterResolver: _portCenter,
                          ),
                        ),
                      ),
                    ),
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF222839),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x332C3648)),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: stackChildren,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTemplateTile extends StatelessWidget {
  const _DeviceTemplateTile({
    required this.template,
    required this.onTap,
  });

  final DeviceTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3144),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x332C3648)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B8BF5), Color(0xFF6C91FA)],
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${template.ports.length} puertos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraggableDevice extends StatefulWidget {
  const _DraggableDevice({
    super.key,
    required this.device,
    required this.onPositionChanged,
    required this.onPortTap,
    required this.selectedPortId,
  });

  final DeviceModel device;
  final ValueChanged<Offset> onPositionChanged;
  final ValueChanged<PortModel> onPortTap;
  final String? selectedPortId;

  @override
  State<_DraggableDevice> createState() => _DraggableDeviceState();
}

class _DraggableDeviceState extends State<_DraggableDevice> {
  Offset? _dragOffsetWithinDevice;

  void _handlePanStart(DragStartDetails details) {
    _dragOffsetWithinDevice = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final delta = details.delta;
    final newOffset = widget.device.position + delta;
    widget.onPositionChanged(newOffset);
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragOffsetWithinDevice = null;
  }

  @override
  Widget build(BuildContext context) {
    const portRadius = 7.0;

    return Positioned(
      left: widget.device.position.dx,
      top: widget.device.position.dy,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: SizedBox(
          width: widget.device.size.width,
          height: widget.device.size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3144),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x44405365)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 10,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.device.metadata != null &&
                          widget.device.metadata!.containsKey('voltage'))
                        Text(
                          '${widget.device.metadata!['voltage']} V',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: widget.device.ports
                            .where((port) => port.type == PortType.n2k)
                            .map(
                              (port) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'N2K',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              for (final port in widget.device.ports)
                Positioned(
                  left: port.offset.dx - portRadius,
                  top: port.offset.dy - portRadius,
                  child: Tooltip(
                    message: port.name,
                    preferBelow: false,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(color: Colors.white),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onPortTap(port),
                      child: _PortIndicator(
                        port: port,
                        selected: widget.selectedPortId == port.id,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortIndicator extends StatelessWidget {
  const _PortIndicator({
    required this.port,
    required this.selected,
  });

  final PortModel port;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = portColor(port.type);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: selected ? 18 : 14,
      height: selected ? 18 : 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: selected ? Colors.white : Colors.black87,
          width: selected ? 3 : 1.2,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}

class CablePainter extends CustomPainter {
  CablePainter({
    required this.cables,
    required this.portCenterResolver,
  });

  final List<CableModel> cables;
  final Offset? Function(String portId) portCenterResolver;

  @override
  void paint(Canvas canvas, Size size) {
    for (final cable in cables) {
      final from = portCenterResolver(cable.fromPortId);
      final to = portCenterResolver(cable.toPortId);
      if (from == null || to == null) {
        continue;
      }
      final paint = Paint()
        ..color = cableColorForType(cable.type)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CablePainter oldDelegate) => true;
}

enum PortType {
  powerPos,
  powerNeg,
  nmeaOutPos,
  nmeaOutNeg,
  nmeaInPos,
  nmeaInNeg,
  n2k,
}

class DeviceModel {
  DeviceModel({
    required this.id,
    required this.name,
    required this.size,
    required this.position,
    required this.ports,
    this.metadata,
  });

  final String id;
  final String name;
  final Size size;
  final Offset position;
  final List<PortModel> ports;
  final Map<String, Object?>? metadata;

  DeviceModel copyWith({Offset? position, List<PortModel>? ports}) {
    return DeviceModel(
      id: id,
      name: name,
      size: size,
      position: position ?? this.position,
      ports: ports ?? this.ports,
      metadata: metadata,
    );
  }
}

class PortModel {
  PortModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.type,
    required this.offset,
  });

  final String id;
  final String deviceId;
  final String name;
  final PortType type;
  final Offset offset;
}

class CableModel {
  CableModel({
    required this.fromPortId,
    required this.toPortId,
    required this.type,
  });

  final String fromPortId;
  final String toPortId;
  final PortType type;
}

class DeviceTemplate {
  const DeviceTemplate({
    required this.name,
    required this.size,
    required this.ports,
    this.metadata,
  });

  final String name;
  final Size size;
  final List<PortTemplate> ports;
  final Map<String, Object?>? metadata;
}

class PortTemplate {
  const PortTemplate({
    required this.name,
    required this.type,
    required this.offset,
  });

  final String name;
  final PortType type;
  final Offset offset;
}

Color portColor(PortType type) {
  switch (type) {
    case PortType.powerPos:
      return const Color(0xFFE74C3C);
    case PortType.powerNeg:
      return const Color(0xFF1F2933);
    case PortType.nmeaOutPos:
      return const Color(0xFF4ADE80);
    case PortType.nmeaOutNeg:
      return const Color(0xFF166534);
    case PortType.nmeaInPos:
      return const Color(0xFF34D399);
    case PortType.nmeaInNeg:
      return const Color(0xFF15803D);
    case PortType.n2k:
      return const Color(0xFF2563EB);
  }
}

Color cableColorForType(PortType type) {
  switch (type) {
    case PortType.powerPos:
    case PortType.powerNeg:
      return const Color(0xFFEF4444);
    case PortType.nmeaOutPos:
    case PortType.nmeaOutNeg:
    case PortType.nmeaInPos:
    case PortType.nmeaInNeg:
      return const Color(0xFF22C55E);
    case PortType.n2k:
      return const Color(0xFF3B82F6);
  }
}

bool arePortsCompatible(PortType a, PortType b) {
  bool match(PortType first, PortType second) {
    return (a == first && b == second) || (a == second && b == first);
  }

  if (match(PortType.powerPos, PortType.powerPos)) return true;
  if (match(PortType.powerNeg, PortType.powerNeg)) return true;
  if (match(PortType.nmeaOutPos, PortType.nmeaInPos)) return true;
  if (match(PortType.nmeaOutNeg, PortType.nmeaInNeg)) return true;
  if (match(PortType.n2k, PortType.n2k)) return true;
  return false;
}
