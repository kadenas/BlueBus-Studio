import 'dart:math' as math;

import 'package:flutter/material.dart';

class PortTypes {
  static const powerPos = 'POWER_POS';
  static const powerNeg = 'POWER_NEG';
  static const nmeaInPos = 'NMEA_IN_POS';
  static const nmeaInNeg = 'NMEA_IN_NEG';
  static const nmeaOutPos = 'NMEA_OUT_POS';
  static const nmeaOutNeg = 'NMEA_OUT_NEG';
}

Color colorForPort(String type) {
  switch (type) {
    case PortTypes.powerPos:
      return const Color(0xFFFF3B30);
    case PortTypes.powerNeg:
      return const Color(0xFF000000);
    case PortTypes.nmeaInPos:
    case PortTypes.nmeaOutPos:
      return const Color(0xFF30C97A);
    case PortTypes.nmeaInNeg:
    case PortTypes.nmeaOutNeg:
      return const Color(0xFFE6C229);
    default:
      return Colors.white;
  }
}

Color colorForCable(String type) => colorForPort(type);

bool portsAreCompatible(String a, String b) {
  if ((a == PortTypes.nmeaOutPos && b == PortTypes.nmeaInPos) ||
      (b == PortTypes.nmeaOutPos && a == PortTypes.nmeaInPos)) return true;

  if ((a == PortTypes.nmeaOutNeg && b == PortTypes.nmeaInNeg) ||
      (b == PortTypes.nmeaOutNeg && a == PortTypes.nmeaInNeg)) return true;

  if (a == PortTypes.powerPos && b == PortTypes.powerPos) return true;
  if (a == PortTypes.powerNeg && b == PortTypes.powerNeg) return true;

  return false;
}

void main() {
  runApp(const BlueBusApp());
}

class BlueBusApp extends StatelessWidget {
  const BlueBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D1117);
    const panel = Color(0xFF161B22);
    const accent = Color(0xFF00AEEF);

    return MaterialApp(
      title: 'BlueBus Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: accent,
          onPrimary: Colors.black,
          secondary: accent,
          onSecondary: Colors.black,
          surface: panel,
          onSurface: Colors.white,
          background: background,
          onBackground: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: panel, elevation: 0),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        cardColor: panel,
        dividerColor: Colors.white12,
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
  final List<LogEntry> _logs = [];

  DeviceModel? _selectedDevice;
  PortModel? _selectedPort;

  final TransformationController _transformController = TransformationController();

  PortModel? _tempStartPort;
  Offset? _tempCurrentPosition;

  final GlobalKey _canvasKey = GlobalKey();

  bool _simulationRunning = false;
  bool _hasShortCircuit = false;

  late final Map<DeviceCategory, List<DeviceTemplate>> _library = _buildLibrary();


  Map<DeviceCategory, List<DeviceTemplate>> _buildLibrary() {
    return {
      DeviceCategory.power: [
        DeviceTemplate(
          catalogName: 'Battery 12V',
          manufacturer: 'BlueBus Energy',
          model: 'AGM 12V 100Ah',
          category: DeviceCategory.power,
          size: const Size(200, 120),
          nominalVoltage: 12.6,
          currentDraw: -5,
          capacityAh: 100,
          socPercent: 100,
          defaultVoltage: 12.6,
          blueprintId: 'battery-12v',
          ports: [
            PortTemplate(
              id: 'battery-12v-pos',
              name: 'Power +',
              type: PortTypes.powerPos,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerPos),
            ),
            PortTemplate(
              id: 'battery-12v-neg',
              name: 'Power -',
              type: PortTypes.powerNeg,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerNeg),
            ),
          ],
        ),
      ],
      DeviceCategory.navigation: [
        DeviceTemplate(
          catalogName: 'GPS Antenna',
          manufacturer: 'Garmin',
          model: 'GPS 19x',
          category: DeviceCategory.navigation,
          size: const Size(200, 140),
          nominalVoltage: 12.0,
          currentDraw: 0.3,
          defaultVoltage: 12.0,
          blueprintId: 'gps-0183',
          ports: [
            PortTemplate(
              id: 'gps-power-pos',
              name: 'Power +',
              type: PortTypes.powerPos,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerPos),
            ),
            PortTemplate(
              id: 'gps-power-neg',
              name: 'Power -',
              type: PortTypes.powerNeg,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerNeg),
            ),
            PortTemplate(
              id: 'gps-nmea-out-pos',
              name: 'NMEA OUT +',
              type: PortTypes.nmeaOutPos,
              group: 'OUT',
              side: 'right',
              color: colorForPort(PortTypes.nmeaOutPos),
            ),
            PortTemplate(
              id: 'gps-nmea-out-neg',
              name: 'NMEA OUT -',
              type: PortTypes.nmeaOutNeg,
              group: 'OUT',
              side: 'right',
              color: colorForPort(PortTypes.nmeaOutNeg),
            ),
          ],
        ),
        DeviceTemplate(
          catalogName: 'Chartplotter',
          manufacturer: 'Raymarine',
          model: 'Axiom 7',
          category: DeviceCategory.navigation,
          size: const Size(240, 160),
          nominalVoltage: 12.0,
          currentDraw: 2.5,
          defaultVoltage: 12.0,
          blueprintId: 'plotter-0183',
          ports: [
            PortTemplate(
              id: 'plotter-power-pos',
              name: 'Power +',
              type: PortTypes.powerPos,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerPos),
            ),
            PortTemplate(
              id: 'plotter-power-neg',
              name: 'Power -',
              type: PortTypes.powerNeg,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerNeg),
            ),
            PortTemplate(
              id: 'plotter-nmea-in-pos',
              name: 'NMEA IN +',
              type: PortTypes.nmeaInPos,
              group: 'IN',
              side: 'left',
              color: colorForPort(PortTypes.nmeaInPos),
            ),
            PortTemplate(
              id: 'plotter-nmea-in-neg',
              name: 'NMEA IN -',
              type: PortTypes.nmeaInNeg,
              group: 'IN',
              side: 'left',
              color: colorForPort(PortTypes.nmeaInNeg),
            ),
            PortTemplate(
              id: 'plotter-nmea-out-pos',
              name: 'NMEA OUT +',
              type: PortTypes.nmeaOutPos,
              group: 'OUT',
              side: 'right',
              color: colorForPort(PortTypes.nmeaOutPos),
            ),
            PortTemplate(
              id: 'plotter-nmea-out-neg',
              name: 'NMEA OUT -',
              type: PortTypes.nmeaOutNeg,
              group: 'OUT',
              side: 'right',
              color: colorForPort(PortTypes.nmeaOutNeg),
            ),
          ],
        ),
      ],
      DeviceCategory.communication: [
        DeviceTemplate(
          catalogName: 'VHF Radio DSC',
          manufacturer: 'Standard Horizon',
          model: 'GX2200',
          category: DeviceCategory.communication,
          size: const Size(220, 150),
          nominalVoltage: 12.0,
          currentDraw: 1.5,
          defaultVoltage: 12.0,
          blueprintId: 'vhf-dsc',
          ports: [
            PortTemplate(
              id: 'vhf-power-pos',
              name: 'Power +',
              type: PortTypes.powerPos,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerPos),
            ),
            PortTemplate(
              id: 'vhf-power-neg',
              name: 'Power -',
              type: PortTypes.powerNeg,
              group: 'Power',
              side: 'bottom',
              color: colorForPort(PortTypes.powerNeg),
            ),
            PortTemplate(
              id: 'vhf-nmea-in-pos',
              name: 'NMEA IN +',
              type: PortTypes.nmeaInPos,
              group: 'IN',
              side: 'left',
              color: colorForPort(PortTypes.nmeaInPos),
            ),
            PortTemplate(
              id: 'vhf-nmea-in-neg',
              name: 'NMEA IN -',
              type: PortTypes.nmeaInNeg,
              group: 'IN',
              side: 'left',
              color: colorForPort(PortTypes.nmeaInNeg),
            ),
          ],
        ),
      ],
    };
  }

  List<DeviceModel> _createNmeaScenarioDevices() {
    const double startX = 140;
    const double spacing = 260;
    const double baseY = 220;
    return [
      for (var i = 0; i < nmeaDevices.length; i++)
        nmeaDevices[i].copyWith(
          id: nmeaDevices[i].id,
          position: Offset(startX + spacing * i, baseY),
          actualVoltage: nmeaDevices[i].defaultVoltage ?? nmeaDevices[i].nominalVoltage,
        ),
    ];
  }

  DeviceModel? _deviceByName(String name) {
    for (final device in _devices) {
      if (device.name == name) {
        return device;
      }
    }
    return null;
  }

  bool _hasCableBetween(String portA, String portB) {
    for (final cable in _cables) {
      final matchesForward = cable.fromPortId == portA && cable.toPortId == portB;
      final matchesReverse = cable.fromPortId == portB && cable.toPortId == portA;
      if (matchesForward || matchesReverse) {
        return true;
      }
    }
    return false;
  }

  void _evaluateNmea0183Links() {
    final gps = _deviceByName('GPS Antenna');
    final plotter = _deviceByName('Chartplotter');
    final vhf = _deviceByName('VHF Radio DSC');

    if (gps != null && plotter != null) {
      final posConnected =
          _hasCableBetween('${gps.id}:gps-nmea-out-pos', '${plotter.id}:plotter-nmea-in-pos');
      final negConnected =
          _hasCableBetween('${gps.id}:gps-nmea-out-neg', '${plotter.id}:plotter-nmea-in-neg');

      if (posConnected && negConnected) {
        addLog('GPS → Chartplotter NMEA 0183 link active.', level: LogLevel.ok);
      } else {
        addLog('Incomplete NMEA 0183 connection between GPS and Chartplotter.', level: LogLevel.warn);
      }
    }

    if (plotter != null && vhf != null) {
      final posConnected =
          _hasCableBetween('${plotter.id}:plotter-nmea-out-pos', '${vhf.id}:vhf-nmea-in-pos');
      final negConnected =
          _hasCableBetween('${plotter.id}:plotter-nmea-out-neg', '${vhf.id}:vhf-nmea-in-neg');

      if (posConnected && negConnected) {
        addLog('Chartplotter → VHF Radio NMEA 0183 link active.', level: LogLevel.ok);
      } else {
        addLog('Incomplete NMEA 0183 connection between Chartplotter and VHF Radio.', level: LogLevel.warn);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _devices.addAll(_createNmeaScenarioDevices());
    _addLog(LogLevel.info, 'Welcome to BlueBus Studio. Tap New to start a fresh project.');
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _addLog(LogLevel level, String message) {
    setState(() {
      _logs.insert(0, LogEntry(level: level, message: message, timestamp: DateTime.now()));
    });
  }

  void addLog(String message, {LogLevel level = LogLevel.info}) {
    _addLog(level, message);
  }

  void _handleAddDevice(DeviceTemplate template) {
    setState(() {
      final baseId = template.blueprintId;
      var uniqueId = baseId;
      var counter = 1;
      while (_devices.any((d) => d.id == uniqueId)) {
        uniqueId = '${baseId}_$counter';
        counter++;
      }
      final id = uniqueId;
      final device = DeviceModel(
        id: id,
        name: template.catalogName,
        model: template.model,
        position: const Offset(80, 80),
        ports: template.ports
            .map(
              (port) => PortModel(
                id: port.id,
                deviceId: id,
                name: port.name,
                type: port.type,
                group: port.group,
                side: port.side,
                color: port.color,
              ),
            )
            .toList(),
        nominalVoltage: template.nominalVoltage,
        actualVoltage: template.defaultVoltage,
        currentDraw: template.currentDraw,
        category: template.category.label,
        size: template.size,
        capacityAh: template.capacityAh,
        socPercent: template.socPercent,
        defaultVoltage: template.defaultVoltage,
      );
      _devices.add(device);
      _selectedDevice = device;
      _selectedPort = null;
      _addLog(LogLevel.info, 'Added ${template.catalogName}.');
    });
  }

  void _handleSelectDevice(String deviceId) {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    setState(() {
      _selectedDevice = device;
      _selectedPort = null;
    });
  }

  void _handleMoveDevice(String deviceId, Offset delta, Size canvasSize) {
    setState(() {
      final device = _devices.firstWhere((d) => d.id == deviceId);
      final newPosition = device.position + delta;
      final clamped = Offset(
        newPosition.dx.clamp(10, math.max(10, canvasSize.width - device.size.width - 10)),
        newPosition.dy.clamp(10, math.max(10, canvasSize.height - device.size.height - 10)),
      );
      device.position = clamped;
    });
  }

  void onPortTap(DeviceModel device, PortModel port) {
    final portId = port.globalId;

    if (_tempStartPort != null) {
      final startId = _tempStartPort!.globalId;
      if (startId != portId) {
        final origin = _resolvePortById(startId);
        final target = _resolvePortById(portId);
        if (origin != null && target != null) {
          if (!portsAreCompatible(origin.port.type, target.port.type)) {
            addLog('[WARN] incompatible: "${origin.port.type}" vs "${target.port.type}"', level: LogLevel.warn);
          } else {
            final connected = _attemptConnection(origin, target);
            if (connected) {
              checkForShortCircuits();
            }
          }
        }
      }
      _tempStartPort = null;
      _tempCurrentPosition = null;
      setState(() {});
      return;
    }

    if (_selectedPort == null) {
      setState(() {
        _selectedPort = port;
      });
      return;
    }

    if (_selectedPort!.globalId == portId) {
      setState(() {
        _selectedPort = null;
      });
      return;
    }

    final origin = _resolvePortById(_selectedPort!.globalId);
    final target = _resolvePortById(portId);

    if (origin == null || target == null) {
      setState(() {
        _selectedPort = null;
      });
      return;
    }

    if (!portsAreCompatible(origin.port.type, target.port.type)) {
      addLog('[WARN] incompatible: "${origin.port.type}" vs "${target.port.type}"', level: LogLevel.warn);
      setState(() {
        _selectedPort = null;
      });
      return;
    }

    final connected = _attemptConnection(origin, target);
    if (connected) {
      checkForShortCircuits();
    }
  }

  void selectPortFromPanel(PortModel port) {
    setState(() {
      _selectedPort = port;
    });
  }

  void onPortDragStart(DeviceModel device, PortModel port, DragStartDetails details) {
    _tempStartPort = port;
    _tempCurrentPosition = _globalToCanvas(details.globalPosition) ?? _getPortCenterForPort(port);
    setState(() {});
  }

  void onPortDragUpdate(DragUpdateDetails details) {
    if (_tempStartPort == null) return;
    final position = _globalToCanvas(details.globalPosition);
    if (position == null) return;
    _tempCurrentPosition = position;
    setState(() {});
  }

  void onPortDragEnd() {
    if (_tempStartPort == null || _tempCurrentPosition == null) {
      _tempStartPort = null;
      _tempCurrentPosition = null;
      setState(() {});
      return;
    }

    final startPort = _tempStartPort!;
    final startId = startPort.globalId;
    final nearest = _findNearestPort(_tempCurrentPosition!, excludeGlobalId: startId);

    if (nearest != null &&
        _distanceToPort(nearest, _tempCurrentPosition!) < 25 &&
        portsAreCompatible(startPort.type, nearest.port.type)) {
      final origin = _resolvePortById(startId);
      if (origin != null) {
        if (_attemptConnection(origin, nearest)) {
          checkForShortCircuits();
        }
      }
    } else {
      addLog('[WARN] drop without valid target', level: LogLevel.warn);
    }

    _tempStartPort = null;
    _tempCurrentPosition = null;
    setState(() {});
  }

  bool _attemptConnection(_ResolvedPort origin, _ResolvedPort target) {
    if (origin.port.globalId == target.port.globalId) {
      setState(() {
        _selectedPort = null;
      });
      return false;
    }

    final fromId = origin.port.globalId;
    final toId = target.port.globalId;

    final originType = origin.port.type.trim();
    final targetType = target.port.type.trim();

    if (!portsAreCompatible(originType, targetType)) {
      addLog('[WARN] incompatible: "$originType" vs "$targetType"', level: LogLevel.warn);
      setState(() {
        _selectedPort = null;
      });
      return false;
    }

    final exists = _cables.any(
      (cable) => (cable.fromPortId == fromId && cable.toPortId == toId) ||
          (cable.fromPortId == toId && cable.toPortId == fromId),
    );

    if (exists) {
      addLog('These ports are already connected.', level: LogLevel.warn);
      setState(() {
        _selectedPort = null;
      });
      return false;
    }

    setState(() {
      final cableType = _preferredCableType(originType, targetType);
      _cables.add(CableModel(fromPortId: fromId, toPortId: toId, type: cableType));
      _selectedPort = null;
    });
    _addLog(LogLevel.ok, 'Created connection between ${origin.device.name} and ${target.device.name}.');
    return true;
  }

  static const double _portHitSize = 30;
  static const double _portCircleSize = 14;
  static const double _portOutsideOffset = 8;

  Offset _portOffset(DeviceModel device, PortModel port) {
    const double verticalPadding = 36;
    const double horizontalPadding = 36;
    final portsOnSide = device.ports.where((p) => p.side == port.side).toList();
    final index = portsOnSide.indexWhere((p) => p.id == port.id);
    final count = portsOnSide.length;

    double x = device.size.width / 2;
    double y = device.size.height / 2;

    switch (port.side) {
      case 'left':
      case 'right':
        if (count <= 1) {
          y = device.size.height / 2;
        } else {
          final available = math.max(0, device.size.height - verticalPadding * 2);
          final step = available / (count - 1);
          y = verticalPadding + step * index;
        }
        x = port.side == 'left' ? 0 : device.size.width;
        break;
      case 'bottom':
        if (count <= 1) {
          x = device.size.width / 2;
        } else {
          final available = math.max(0, device.size.width - horizontalPadding * 2);
          final step = available / (count - 1);
          x = horizontalPadding + step * index;
        }
        y = device.size.height;
        break;
      case 'top':
        if (count <= 1) {
          x = device.size.width / 2;
        } else {
          final available = math.max(0, device.size.width - horizontalPadding * 2);
          final step = available / (count - 1);
          x = horizontalPadding + step * index;
        }
        y = 0;
        break;
      default:
        x = device.size.width / 2;
        y = device.size.height / 2;
        break;
    }

    switch (port.side) {
      case 'left':
        x -= _portOutsideOffset;
        break;
      case 'right':
        x += _portOutsideOffset;
        break;
      case 'bottom':
        y += _portOutsideOffset;
        break;
      case 'top':
        y -= _portOutsideOffset;
        break;
    }

    return Offset(x, y);
  }

  Offset _getPortCenter(_ResolvedPort resolved) {
    return resolved.device.position + _portOffset(resolved.device, resolved.port);
  }

  Offset? _getPortCenterForPort(PortModel port) {
    for (final device in _devices) {
      if (device.id == port.deviceId) {
        return device.position + _portOffset(device, port);
      }
    }
    return null;
  }

  Offset? _globalToCanvas(Offset globalPosition) {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    return renderBox.globalToLocal(globalPosition);
  }

  _ResolvedPort? _findNearestPort(Offset point, {String? excludeGlobalId}) {
    _ResolvedPort? best;
    double bestDistance = double.infinity;

    for (final device in _devices) {
      for (var i = 0; i < device.ports.length; i++) {
        final port = device.ports[i];
        if (excludeGlobalId != null && port.globalId == excludeGlobalId) {
          continue;
        }
        final center = device.position + _portOffset(device, port);
        final distance = (center - point).distance;
        if (distance < bestDistance) {
          bestDistance = distance;
          best = _ResolvedPort(device: device, port: port, portIndex: i);
        }
      }
    }

    return best;
  }

  double _distanceToPort(_ResolvedPort port, Offset point) {
    final center = _getPortCenter(port);
    return (center - point).distance;
  }

  _ResolvedPort? _resolvePortById(String portId) {
    final separatorIndex = portId.indexOf(':');
    if (separatorIndex == -1) return null;
    final deviceId = portId.substring(0, separatorIndex);
    final portKey = portId.substring(separatorIndex + 1);

    DeviceModel? device;
    for (final candidate in _devices) {
      if (candidate.id == deviceId) {
        device = candidate;
        break;
      }
    }

    if (device == null) return null;

    final index = device.ports.indexWhere((p) => p.id == portKey);
    if (index == -1) return null;

    return _ResolvedPort(device: device, port: device.ports[index], portIndex: index);
  }

  GlobalPortReference? findPortByGlobalId(String portId) {
    final resolved = _resolvePortById(portId);
    if (resolved == null) {
      return null;
    }
    return GlobalPortReference(
      deviceId: resolved.device.id,
      deviceName: resolved.device.name,
      port: resolved.port,
    );
  }

  void _handleNewProject() {
    final scenarioDevices = _createNmeaScenarioDevices();
    setState(() {
      _devices
        ..clear()
        ..addAll(scenarioDevices);
      _cables.clear();
      _logs.clear();
      _selectedDevice = null;
      _selectedPort = null;
      _simulationRunning = false;
      _hasShortCircuit = false;
    });
    _transformController.value = Matrix4.identity();
    _addLog(LogLevel.info, 'Started a new project.');
  }

  void _handleSaveProject() {
    _addLog(LogLevel.info, 'Project saved (mock).');
  }

  void _handleStopSimulation() {
    if (!_simulationRunning) {
      _addLog(LogLevel.info, 'Simulation is not running.');
      return;
    }
    setState(() {
      _simulationRunning = false;
      for (final device in _devices) {
        device.voltageWarning = false;
        device.actualVoltage = device.defaultVoltage ?? device.nominalVoltage;
      }
    });
    _addLog(LogLevel.info, 'Simulation stopped.');
  }

  void deleteSelectedDevice() {
    if (_selectedDevice == null) return;

    final deviceId = _selectedDevice!.id;
    final portIds = _selectedDevice!.ports.map((p) => p.globalId).toSet();

    setState(() {
      _devices.removeWhere((d) => d.id == deviceId);
      _cables.removeWhere(
        (c) => portIds.contains(c.fromPortId) || portIds.contains(c.toPortId),
      );
      _selectedDevice = null;
      _selectedPort = null;
    });

    addLog('[INFO] Device removed from canvas.');
  }

  Future<void> _handleRunSimulation() async {
    if (_simulationRunning) {
      _addLog(LogLevel.info, 'Simulation already running.');
      return;
    }

    if (_devices.isEmpty) {
      _addLog(LogLevel.warn, 'No devices placed on the canvas.');
      return;
    }

    checkForShortCircuits();
    if (_hasShortCircuit) {
      return;
    }

    _addLog(LogLevel.ok, 'Electrical topology validated.');

    setState(() {
      _simulationRunning = true;
    });
    await runSimulation();
  }

  void checkForShortCircuits() {
    bool foundShort = false;

    for (final cable in _cables) {
      cable.isFault = false;
    }

    for (final c in _cables) {
      final p1 = findPortByGlobalId(c.fromPortId);
      final p2 = findPortByGlobalId(c.toPortId);
      if (p1 == null || p2 == null) {
        continue;
      }

      final isShort =
          (p1.type == PortTypes.powerPos && p2.type == PortTypes.powerNeg) ||
              (p1.type == PortTypes.powerNeg && p2.type == PortTypes.powerPos);

      if (isShort) {
        addLog('Short circuit detected between ${p1.name} and ${p2.name}', level: LogLevel.error);
        c.isFault = true;
        foundShort = true;
      }
    }

    setState(() {
      _hasShortCircuit = foundShort;
    });
  }

  Future<void> runSimulation() async {
    addLog('[INFO] Simulation started.');
    setState(() {});

    final batteries = _devices.where((d) => d.category == 'Power').toList();
    final Map<String, double> batteryCurrents = {
      for (final battery in batteries) battery.id: 0,
    };

    for (final battery in batteries) {
      battery.actualVoltage = battery.nominalVoltage;
      battery.voltageWarning = false;
      battery.socPercent ??= 100;
    }

    const stepDelay = Duration(milliseconds: 200);

    for (final dev in _devices) {
      await Future.delayed(stepDelay);

      if (dev.category == 'Power') {
        dev.actualVoltage = dev.nominalVoltage;
        dev.voltageWarning = false;
        final voltageDisplay = dev.actualVoltage?.toStringAsFixed(1) ?? '0.0';
        addLog('[OK] ${dev.name} online at ${voltageDisplay}V');
      } else {
        final hasPos = _cables.any((c) => isPowerConnection(c, dev.id, true, batteries));
        final hasNeg = _cables.any((c) => isPowerConnection(c, dev.id, false, batteries));

        if (hasPos && hasNeg && batteries.isNotEmpty) {
          final supplyBattery = _findBatteryForDevice(dev, batteries) ?? (batteries.isNotEmpty ? batteries.first : null);
          final baseVoltage = supplyBattery?.nominalVoltage ?? supplyBattery?.actualVoltage ?? dev.nominalVoltage ?? 0;
          dev.actualVoltage = math.max(0, baseVoltage - 0.2);
          dev.voltageWarning = false;
          addLog('[OK] ${dev.name} powered: ${dev.actualVoltage!.toStringAsFixed(1)}V');

          final draw = dev.currentDraw ?? 0;
          if (supplyBattery != null && draw > 0) {
            batteryCurrents[supplyBattery.id] = (batteryCurrents[supplyBattery.id] ?? 0) + draw;
          }
        } else {
          dev.actualVoltage = 0;
          dev.voltageWarning = true;
          addLog('[WARN] ${dev.name} has missing power connection (+/-)');
        }
      }

      setState(() {});
    }

    _evaluateNmea0183Links();
    checkForShortCircuits();

    final simulationSeconds = stepDelay.inMilliseconds / 1000.0 * _devices.length;
    for (final battery in batteries) {
      final totalCurrent = batteryCurrents[battery.id] ?? 0;
      updateBatterySoc(battery, totalCurrent, simulationSeconds);
    }

    addLog('[INFO] Simulation finished.');
    setState(() {
      _simulationRunning = false;
    });
  }

  bool isPowerConnection(CableModel cable, String deviceId, bool positive, List<DeviceModel> batteries) {
    final p1 = findPortByGlobalId(cable.fromPortId);
    final p2 = findPortByGlobalId(cable.toPortId);
    if (p1 == null || p2 == null) return false;

    final targetType = positive ? PortTypes.powerPos : PortTypes.powerNeg;

    final isDeviceEnd = (p1.deviceId == deviceId && p1.type == targetType) ||
        (p2.deviceId == deviceId && p2.type == targetType);

    if (!isDeviceEnd) return false;

    final otherEnd = p1.deviceId == deviceId ? p2 : p1;
    final isBattery = batteries.any((b) => b.id == otherEnd.deviceId);

    return isDeviceEnd && isBattery && otherEnd.type == targetType;
  }

  DeviceModel? _findBatteryForDevice(DeviceModel device, List<DeviceModel> batteries) {
    for (final cable in _cables) {
      final p1 = findPortByGlobalId(cable.fromPortId);
      final p2 = findPortByGlobalId(cable.toPortId);
      if (p1 == null || p2 == null) continue;

      final isPositiveEnd = (p1.deviceId == device.id && p1.type == PortTypes.powerPos) ||
          (p2.deviceId == device.id && p2.type == PortTypes.powerPos);

      if (!isPositiveEnd) continue;

      final other = p1.deviceId == device.id ? p2 : p1;
      for (final battery in batteries) {
        if (battery.id == other.deviceId) {
          return battery;
        }
      }
    }
    return null;
  }

  void updateBatterySoc(DeviceModel battery, double totalCurrentA, double seconds) {
    if (battery.capacityAh == null) return;
    final consumedAh = totalCurrentA * (seconds / 3600.0);
    final capacity = battery.capacityAh!;
    final soc = (battery.socPercent ?? 100);
    final newSoc = soc - (consumedAh / capacity) * 100;
    battery.socPercent = newSoc.clamp(0, 100);
  }

  String _preferredCableType(String a, String b) {
    if (a == b) return a;
    if ({PortTypes.nmeaOutPos, PortTypes.nmeaInPos}.contains(a) &&
        {PortTypes.nmeaOutPos, PortTypes.nmeaInPos}.contains(b)) {
      return PortTypes.nmeaOutPos;
    }
    if ({PortTypes.nmeaOutNeg, PortTypes.nmeaInNeg}.contains(a) &&
        {PortTypes.nmeaOutNeg, PortTypes.nmeaInNeg}.contains(b)) {
      return PortTypes.nmeaOutNeg;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(colorScheme),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 220, child: _buildDeviceLibrary(colorScheme)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _buildCanvasArea(),
                        ),
                      ),
                      SizedBox(width: 260, child: _buildPropertiesPanel(colorScheme)),
                    ],
                  );
                },
              ),
            ),
            _buildConsole(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: colorScheme.surface,
      child: Row(
        children: [
          Text('BlueBus Studio', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 32),
          _TopBarButton(label: 'New', icon: Icons.add_box_outlined, onTap: _handleNewProject),
          const SizedBox(width: 12),
          _TopBarButton(label: 'Save', icon: Icons.save_outlined, onTap: _handleSaveProject),
          const SizedBox(width: 12),
          _TopBarButton(label: 'Play', icon: Icons.play_arrow, onTap: _handleRunSimulation),
          const SizedBox(width: 12),
          _TopBarButton(label: 'Stop', icon: Icons.stop, onTap: _handleStopSimulation),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Delete selected device',
            onPressed: deleteSelectedDevice,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom out',
            onPressed: () {
              _transformController.value = _transformController.value.scaled(0.9);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom in',
            onPressed: () {
              _transformController.value = _transformController.value.scaled(1.1);
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _simulationRunning
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(_simulationRunning ? Icons.power_settings_new : Icons.bolt_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(_simulationRunning ? 'Simulation Running' : 'Idle', style: const TextStyle(fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeviceLibrary(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: _library.entries.map((entry) {
                return _LibrarySection(
                  title: entry.key.label,
                  templates: entry.value,
                  onTemplateTap: _handleAddDevice,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 2.5,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Stack(
                  key: _canvasKey,
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(size: size, painter: _GridPainter()),
                    ..._buildCables(),
                    if (_tempStartPort != null && _tempCurrentPosition != null)
                      CustomPaint(
                        painter: _TempCablePainter(
                          start: _getPortCenterForPort(_tempStartPort!) ?? _tempCurrentPosition!,
                          end: _tempCurrentPosition!,
                          color: colorForPort(_tempStartPort!.type),
                        ),
                        size: Size.infinite,
                      ),
                    ..._devices.map((device) => _buildDeviceWidget(device, size)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Iterable<Widget> _buildCables() sync* {
    for (final cable in _cables) {
      final from = _resolvePortById(cable.fromPortId);
      final to = _resolvePortById(cable.toPortId);
      if (from == null || to == null) continue;
      final fromOffset = _getPortCenter(from);
      final toOffset = _getPortCenter(to);
      final isShort = cable.isFault;
      final cableColor = cable.isFault ? Colors.redAccent : colorForCable(cable.type);
      final strokeWidth = isShort ? 5.0 : 3.0;
      yield CustomPaint(
        painter: _CablePainter(
          from: fromOffset,
          to: toOffset,
          color: cableColor,
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      );
    }
  }

  Widget _buildDeviceWidget(DeviceModel device, Size canvasSize) {
    final isSelected = _selectedDevice?.id == device.id;
    final borderColor = device.voltageWarning ? Colors.redAccent : (isSelected ? Theme.of(context).colorScheme.primary : Colors.white24);
    return Positioned(
      left: device.position.dx,
      top: device.position.dy,
      child: GestureDetector(
        onTap: () => _handleSelectDevice(device.id),
        onPanUpdate: (details) => _handleMoveDevice(device.id, details.delta, canvasSize),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: device.size.width,
          height: device.size.height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: device.voltageWarning ? 3 : 1.5),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          device.category == 'Power'
                              ? Icons.battery_full
                              : device.category == 'Navigation'
                                  ? Icons.navigation
                                  : Icons.memory,
                          size: 14,
                          color: Colors.cyanAccent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            device.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (device.model != null)
                      Text(device.model!, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              ..._buildGroupLabels(device),
              ...device.ports.map((port) => buildPortWidget(device, port)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupLabels(DeviceModel device) {
    final labels = <Widget>[];
    const style = TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 0.5);

    if (device.ports.any((p) => p.group == 'IN')) {
      labels.add(Positioned(
        left: 12,
        top: device.size.height / 2 - 8,
        child: const Text('IN', style: style),
      ));
    }

    if (device.ports.any((p) => p.group == 'OUT')) {
      labels.add(Positioned(
        right: 12,
        top: device.size.height / 2 - 8,
        child: const Text('OUT', style: style),
      ));
    }

    if (device.ports.any((p) => p.group == 'Power')) {
      labels.add(Positioned(
        bottom: 8,
        left: device.size.width / 2 - 20,
        child: const Text('POWER', style: style),
      ));
    }

    return labels;
  }

  Widget buildPortWidget(DeviceModel device, PortModel port) {
    final isSelected = _selectedPort?.globalId == port.globalId;
    final center = _portOffset(device, port);
    final left = center.dx - _portHitSize / 2;
    final top = center.dy - _portHitSize / 2;

    Alignment alignment;
    switch (port.side) {
      case 'left':
        alignment = Alignment.centerLeft;
        break;
      case 'right':
        alignment = Alignment.centerRight;
        break;
      case 'bottom':
        alignment = Alignment.bottomCenter;
        break;
      case 'top':
        alignment = Alignment.topCenter;
        break;
      default:
        alignment = Alignment.center;
        break;
    }

    final borderColor = isSelected ? Colors.cyanAccent : Colors.white24;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onPortTap(device, port),
        onPanStart: (details) => onPortDragStart(device, port, details),
        onPanUpdate: (details) => onPortDragUpdate(details),
        onPanEnd: (_) => onPortDragEnd(),
        onPanCancel: onPortDragEnd,
        child: SizedBox(
          width: _portHitSize,
          height: _portHitSize,
          child: Tooltip(
            message: port.name,
            waitDuration: const Duration(milliseconds: 300),
            child: Align(
              alignment: alignment,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _portCircleSize,
                height: _portCircleSize,
                decoration: BoxDecoration(
                  color: colorForPort(port.type),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: borderWidth),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesPanel(ColorScheme colorScheme) {
    final selected = _selectedDevice != null &&
            _devices.any((device) => device.id == _selectedDevice!.id)
        ? _selectedDevice
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (selected == null)
            Expanded(
              child: Center(
                child: Text('Select a device to view its properties.', style: Theme.of(context).textTheme.bodyMedium),
              ),
            )
          else
            Expanded(
              child: Builder(
                builder: (context) {
                  final device = selected!;
                  final nominalVoltage = device.nominalVoltage != null
                      ? '${device.nominalVoltage!.toStringAsFixed(1)} V'
                      : '—';
                  final actualVoltageValue = device.actualVoltage != null
                      ? '${device.actualVoltage!.toStringAsFixed(1)} V'
                      : '—';
                  final isLowVoltage = device.actualVoltage != null &&
                      device.nominalVoltage != null &&
                      device.actualVoltage! < device.nominalVoltage! - 0.5;
                  final currentDraw = device.currentDraw != null
                      ? '${device.currentDraw!.toStringAsFixed(2)} A'
                      : '—';
                  return ListView(
                    children: [
                      _PropertyRow(label: 'Name', value: device.name),
                      _PropertyRow(label: 'Category', value: device.category),
                      _PropertyRow(label: 'Nominal Voltage', value: nominalVoltage),
                      _PropertyRow(
                        label: 'Actual Voltage',
                        value: actualVoltageValue,
                        valueStyle: TextStyle(
                          color: isLowVoltage ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _PropertyRow(label: 'Current Draw', value: currentDraw),
                      if (device.capacityAh != null)
                        _PropertyRow(
                          label: 'Capacity',
                          value: '${device.capacityAh!.toStringAsFixed(0)} Ah',
                        ),
                      if (device.socPercent != null)
                        _PropertyRow(
                          label: 'State of Charge',
                          value: '${device.socPercent!.toStringAsFixed(1)} %',
                        ),
                      const SizedBox(height: 12),
                      Text('Ports', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      ...device.ports.map(
                        (port) {
                          final portColor = port.color;
                          final isSelectedPort = _selectedPort?.globalId == port.globalId;
                          return GestureDetector(
                            onTap: () => selectPortFromPanel(port),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelectedPort ? Colors.cyanAccent : Colors.transparent,
                                  width: isSelectedPort ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: portColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(port.name)),
                                  Text(portTypeLabel(port.type), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConsole(ColorScheme colorScheme) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diagnostics & Simulation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      '[${log.timestampString}] ${log.level.prefix} ${log.message}',
                      style: TextStyle(color: log.level.color),
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

class _LibrarySection extends StatelessWidget {
  const _LibrarySection({
    required this.title,
    required this.templates,
    required this.onTemplateTap,
  });

  final String title;
  final List<DeviceTemplate> templates;
  final ValueChanged<DeviceTemplate> onTemplateTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...templates.map((template) {
            return GestureDetector(
              onTap: () => onTemplateTap(template),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.catalogName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(template.model, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.bolt, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text('${template.nominalVoltage.toStringAsFixed(1)} V', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.speed, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text('${template.currentDraw.toStringAsFixed(2)} A', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class DeviceTemplate {
  const DeviceTemplate({
    required this.catalogName,
    required this.manufacturer,
    required this.model,
    required this.category,
    required this.size,
    required this.nominalVoltage,
    required this.currentDraw,
    required this.defaultVoltage,
    required this.blueprintId,
    this.capacityAh,
    this.socPercent,
    required this.ports,
  });

  final String catalogName;
  final String manufacturer;
  final String model;
  final DeviceCategory category;
  final Size size;
  final double nominalVoltage;
  final double currentDraw;
  final double defaultVoltage;
  final String blueprintId;
  final double? capacityAh;
  final double? socPercent;
  final List<PortTemplate> ports;
}

class PortTemplate {
  const PortTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.group,
    required this.side,
    required this.color,
  });

  final String id;
  final String name;
  final String type;
  final String group;
  final String side;
  final Color color;
}

class PortModel {
  PortModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.type,
    required this.group,
    required this.side,
    required this.color,
  });

  final String id;
  final String deviceId;
  final String name;
  final String type;
  final String group;
  final String side;
  final Color color;

  PortModel copyForDevice(String newDeviceId) {
    return PortModel(
      id: id,
      deviceId: newDeviceId,
      name: name,
      type: type,
      group: group,
      side: side,
      color: color,
    );
  }

  String get globalId => '$deviceId:$id';
}

class DeviceModel {
  DeviceModel({
    required this.id,
    required this.name,
    required this.position,
    required this.ports,
    required this.nominalVoltage,
    required double? actualVoltage,
    required this.currentDraw,
    required this.category,
    required this.size,
    this.model,
    this.capacityAh,
    this.socPercent,
    this.defaultVoltage,
  }) : actualVoltage = actualVoltage ?? nominalVoltage;

  final String id;
  final String name;
  Offset position;
  final List<PortModel> ports;
  final double? nominalVoltage;
  double? actualVoltage;
  final double? currentDraw;
  final String category;
  final Size size;
  final String? model;
  final double? capacityAh;
  double? socPercent;
  final double? defaultVoltage;
  bool voltageWarning = false;

  DeviceModel copyWith({
    String? id,
    String? name,
    Offset? position,
    List<PortModel>? ports,
    double? nominalVoltage,
    double? actualVoltage,
    double? currentDraw,
    String? category,
    Size? size,
    String? model,
    double? capacityAh,
    double? socPercent,
    double? defaultVoltage,
  }) {
    final newId = id ?? this.id;
    final clonedPorts = (ports ?? this.ports).map((port) => port.copyForDevice(newId)).toList();
    final device = DeviceModel(
      id: newId,
      name: name ?? this.name,
      position: position ?? this.position,
      ports: clonedPorts,
      nominalVoltage: nominalVoltage ?? this.nominalVoltage,
      actualVoltage: actualVoltage ?? this.actualVoltage,
      currentDraw: currentDraw ?? this.currentDraw,
      category: category ?? this.category,
      size: size ?? this.size,
      model: model ?? this.model,
      capacityAh: capacityAh ?? this.capacityAh,
      socPercent: socPercent ?? this.socPercent,
      defaultVoltage: defaultVoltage ?? this.defaultVoltage,
    );
    device.voltageWarning = voltageWarning;
    return device;
  }
}

final List<DeviceModel> nmeaDevices = [
  DeviceModel(
    id: 'gps-0183',
    name: 'GPS Antenna',
    model: 'NMEA 0183 GPS',
    category: 'Navigation',
    position: Offset.zero,
    size: const Size(200, 140),
    nominalVoltage: 12.0,
    actualVoltage: 12.0,
    currentDraw: 0.3,
    defaultVoltage: 12.0,
    ports: [
      PortModel(
        id: 'gps-power-pos',
        deviceId: 'gps-0183',
        name: 'Power +',
        type: PortTypes.powerPos,
        group: 'Power',
        side: 'bottom',
        color: colorForPort(PortTypes.powerPos),
      ),
      PortModel(
        id: 'gps-power-neg',
        deviceId: 'gps-0183',
        name: 'Power -',
        type: PortTypes.powerNeg,
        group: 'Power',
        side: 'bottom',
        color: colorForPort(PortTypes.powerNeg),
      ),
      PortModel(
        id: 'gps-nmea-out-pos',
        deviceId: 'gps-0183',
        name: 'NMEA OUT +',
        type: PortTypes.nmeaOutPos,
        group: 'OUT',
        side: 'right',
        color: colorForPort(PortTypes.nmeaOutPos),
      ),
      PortModel(
        id: 'gps-nmea-out-neg',
        deviceId: 'gps-0183',
        name: 'NMEA OUT -',
        type: PortTypes.nmeaOutNeg,
        group: 'OUT',
        side: 'right',
        color: colorForPort(PortTypes.nmeaOutNeg),
      ),
    ],
  ),
  DeviceModel(
    id: 'plotter-0183',
    name: 'Chartplotter',
    model: 'NMEA 0183 Plotter',
    category: 'Navigation',
    position: Offset.zero,
    size: const Size(240, 160),
    nominalVoltage: 12.0,
    actualVoltage: 12.0,
    currentDraw: 2.5,
    defaultVoltage: 12.0,
    ports: [
      PortModel(
        id: 'plotter-power-pos',
        deviceId: 'plotter-0183',
        name: 'Power +',
        type: PortTypes.powerPos,
        group: 'Power',
        side: 'bottom',
        color: colorForPort(PortTypes.powerPos),
      ),
      PortModel(
        id: 'plotter-power-neg',
        deviceId: 'plotter-0183',
        name: 'Power -',
        type: PortTypes.powerNeg,
        group: 'Power',
        side: 'bottom',
        color: colorForPort(PortTypes.powerNeg),
      ),
      PortModel(
        id: 'plotter-nmea-in-pos',
        deviceId: 'plotter-0183',
        name: 'NMEA IN +',
        type: PortTypes.nmeaInPos,
        group: 'IN',
        side: 'left',
        color: colorForPort(PortTypes.nmeaInPos),
      ),
      PortModel(
        id: 'plotter-nmea-in-neg',
        deviceId: 'plotter-0183',
        name: 'NMEA IN -',
        type: PortTypes.nmeaInNeg,
        group: 'IN',
        side: 'left',
        color: colorForPort(PortTypes.nmeaInNeg),
      ),
      PortModel(
        id: 'plotter-nmea-out-pos',
        deviceId: 'plotter-0183',
        name: 'NMEA OUT +',
        type: PortTypes.nmeaOutPos,
        group: 'OUT',
        side: 'right',
        color: colorForPort(PortTypes.nmeaOutPos),
      ),
      PortModel(
        id: 'plotter-nmea-out-neg',
        deviceId: 'plotter-0183',
        name: 'NMEA OUT -',
        type: PortTypes.nmeaOutNeg,
        group: 'OUT',
        side: 'right',
        color: colorForPort(PortTypes.nmeaOutNeg),
      ),
    ],
  ),
  DeviceModel(
    id: 'vhf-dsc',
    name: 'VHF Radio DSC',
    model: 'NMEA 0183 VHF',
    category: 'Communication',
    position: Offset.zero,
    size: const Size(220, 150),
    nominalVoltage: 12.0,
    actualVoltage: 12.0,
    currentDraw: 1.5,
    defaultVoltage: 12.0,
    ports: [
      PortModel(
        id: 'vhf-power-pos',
        deviceId: 'vhf-dsc',
        name: 'Power +',
        type: PortTypes.powerPos,
        group: 'Power',
        side: 'bottom',
        color: colorForPort(PortTypes.powerPos),
      ),
      PortModel(
        id: 'vhf-power-neg',
        deviceId: 'vhf-dsc',
        name: 'Power -',
        type: PortTypes.powerNeg,
        group: 'Power',
        side: 'bottom',
        color: colorForPort(PortTypes.powerNeg),
      ),
      PortModel(
        id: 'vhf-nmea-in-pos',
        deviceId: 'vhf-dsc',
        name: 'NMEA IN +',
        type: PortTypes.nmeaInPos,
        group: 'IN',
        side: 'left',
        color: colorForPort(PortTypes.nmeaInPos),
      ),
      PortModel(
        id: 'vhf-nmea-in-neg',
        deviceId: 'vhf-dsc',
        name: 'NMEA IN -',
        type: PortTypes.nmeaInNeg,
        group: 'IN',
        side: 'left',
        color: colorForPort(PortTypes.nmeaInNeg),
      ),
    ],
  ),
];

class CableModel {
  CableModel({
    required this.fromPortId,
    required this.toPortId,
    required this.type,
    this.isFault = false,
  });

  final String fromPortId;
  final String toPortId;
  final String type;
  bool isFault;
}

class _ResolvedPort {
  _ResolvedPort({required this.device, required this.port, required this.portIndex});

  final DeviceModel device;
  final PortModel port;
  final int portIndex;

  String get globalId => port.globalId;
}

class GlobalPortReference {
  GlobalPortReference({
    required this.deviceId,
    required this.deviceName,
    required this.port,
  });

  final String deviceId;
  final String deviceName;
  final PortModel port;

  String get name => '$deviceName ${port.name}';
  String get type => port.type;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFF0D1117);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final minorPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;
    final majorPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.8;

    const minorStep = 24.0;
    const majorStep = 120.0;

    for (double x = 0; x <= size.width; x += minorStep) {
      final paint = (x % majorStep == 0) ? majorPaint : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += minorStep) {
      final paint = (y % majorStep == 0) ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CablePainter extends CustomPainter {
  _CablePainter({
    required this.from,
    required this.to,
    required this.color,
    required this.strokeWidth,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final control1 = Offset(mid.dx, from.dy);
    final control2 = Offset(mid.dx, to.dy);

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, to.dx, to.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CablePainter oldDelegate) {
    return oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _TempCablePainter extends CustomPainter {
  _TempCablePainter({
    required this.start,
    required this.end,
    required this.color,
  });

  final Offset start;
  final Offset end;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _TempCablePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end || oldDelegate.color != color;
  }
}

class LogEntry {
  LogEntry({required this.level, required this.message, required this.timestamp});

  final LogLevel level;
  final String message;
  final DateTime timestamp;

  String get timestampString => '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
}

enum LogLevel { info, ok, warn, error }

extension LogLevelX on LogLevel {
  String get prefix {
    switch (this) {
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.ok:
        return '[OK]';
      case LogLevel.warn:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }

  Color get color {
    switch (this) {
      case LogLevel.info:
        return Colors.lightBlueAccent;
      case LogLevel.ok:
        return Colors.lightGreenAccent;
      case LogLevel.warn:
        return Colors.yellowAccent;
      case LogLevel.error:
        return Colors.redAccent;
    }
  }
}

enum DeviceCategory { power, navigation, communication }

extension DeviceCategoryX on DeviceCategory {
  String get label {
    switch (this) {
      case DeviceCategory.power:
        return 'Power';
      case DeviceCategory.navigation:
        return 'Navigation';
      case DeviceCategory.communication:
        return 'Communication';
    }
  }
}

String portTypeLabel(String type) {
  switch (type) {
    case PortTypes.powerPos:
      return 'Power +';
    case PortTypes.powerNeg:
      return 'Power -';
    case PortTypes.nmeaOutPos:
      return 'NMEA OUT +';
    case PortTypes.nmeaOutNeg:
      return 'NMEA OUT -';
    case PortTypes.nmeaInPos:
      return 'NMEA IN +';
    case PortTypes.nmeaInNeg:
      return 'NMEA IN -';
    default:
      return type;
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.white54))),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
