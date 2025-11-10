import 'dart:math' as math;

import 'package:flutter/material.dart';

const String portTypePowerPositive = 'POWER_POS';
const String portTypePowerNegative = 'POWER_NEG';
const String portTypeNmeaOutPositive = 'NMEA_OUT_POS';
const String portTypeNmeaOutNegative = 'NMEA_OUT_NEG';
const String portTypeNmeaInPositive = 'NMEA_IN_POS';
const String portTypeNmeaInNegative = 'NMEA_IN_NEG';
const String portTypeN2k = 'N2K';

Color colorForPort(String type) {
  switch (type) {
    case portTypePowerPositive:
      return const Color(0xFFFF3B30);
    case portTypePowerNegative:
      return const Color(0xFF000000);
    case portTypeNmeaOutPositive:
    case portTypeNmeaInPositive:
      return const Color(0xFF30C97A);
    case portTypeNmeaOutNegative:
    case portTypeNmeaInNegative:
      return const Color(0xFFE6C229);
    case portTypeN2k:
      return const Color(0xFF0080FF);
    default:
      return const Color(0xFF9E9E9E);
  }
}

Color colorForCable(String type) {
  return colorForPort(type);
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

  String? _selectedDeviceId;
  String? _selectedPortId;

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
          size: const Size(180, 110),
          nominalVoltage: 12.6,
          currentDraw: -5, // charge reserve placeholder
          batteryCapacityAh: 100,
          defaultVoltage: 12.6,
          ports: const [
            PortTemplate(name: 'Positive', type: portTypePowerPositive, offset: Offset(30, 90)),
            PortTemplate(name: 'Negative', type: portTypePowerNegative, offset: Offset(150, 90)),
          ],
        ),
        DeviceTemplate(
          catalogName: 'Battery 24V',
          manufacturer: 'BlueBus Energy',
          model: 'LiFePO4 24V 200Ah',
          category: DeviceCategory.power,
          size: const Size(190, 120),
          nominalVoltage: 25.2,
          currentDraw: -8,
          batteryCapacityAh: 200,
          defaultVoltage: 25.2,
          ports: const [
            PortTemplate(name: 'Positive', type: portTypePowerPositive, offset: Offset(40, 100)),
            PortTemplate(name: 'Negative', type: portTypePowerNegative, offset: Offset(150, 100)),
          ],
        ),
      ],
      DeviceCategory.navigation: [
        DeviceTemplate(
          catalogName: 'GPS Antenna',
          manufacturer: 'Garmin',
          model: 'GPS 19x',
          category: DeviceCategory.navigation,
          size: const Size(170, 120),
          nominalVoltage: 12.0,
          currentDraw: 0.3,
          defaultVoltage: 11.7,
          ports: const [
            PortTemplate(name: 'Power +', type: portTypePowerPositive, offset: Offset(20, 90)),
            PortTemplate(name: 'Power -', type: portTypePowerNegative, offset: Offset(60, 90)),
            PortTemplate(name: 'NMEA OUT +', type: portTypeNmeaOutPositive, offset: Offset(140, 30)),
            PortTemplate(name: 'NMEA OUT -', type: portTypeNmeaOutNegative, offset: Offset(140, 70)),
          ],
        ),
        DeviceTemplate(
          catalogName: 'Chartplotter',
          manufacturer: 'Raymarine',
          model: 'Axiom 7',
          category: DeviceCategory.navigation,
          size: const Size(220, 150),
          nominalVoltage: 12.0,
          currentDraw: 2.5,
          defaultVoltage: 11.4,
          ports: const [
            PortTemplate(name: 'Power +', type: portTypePowerPositive, offset: Offset(20, 120)),
            PortTemplate(name: 'Power -', type: portTypePowerNegative, offset: Offset(70, 120)),
            PortTemplate(name: 'NMEA IN +', type: portTypeNmeaInPositive, offset: Offset(10, 40)),
            PortTemplate(name: 'NMEA IN -', type: portTypeNmeaInNegative, offset: Offset(10, 80)),
            PortTemplate(name: 'NMEA OUT +', type: portTypeNmeaOutPositive, offset: Offset(210, 40)),
            PortTemplate(name: 'NMEA OUT -', type: portTypeNmeaOutNegative, offset: Offset(210, 80)),
            PortTemplate(name: 'N2K Backbone', type: portTypeN2k, offset: Offset(190, 120)),
          ],
        ),
        DeviceTemplate(
          catalogName: 'AIS Transponder',
          manufacturer: 'Vesper',
          model: 'Cortex M1',
          category: DeviceCategory.navigation,
          size: const Size(200, 130),
          nominalVoltage: 12.0,
          currentDraw: 1.8,
          defaultVoltage: 11.8,
          ports: const [
            PortTemplate(name: 'Power +', type: portTypePowerPositive, offset: Offset(30, 105)),
            PortTemplate(name: 'Power -', type: portTypePowerNegative, offset: Offset(80, 105)),
            PortTemplate(name: 'NMEA IN +', type: portTypeNmeaInPositive, offset: Offset(10, 40)),
            PortTemplate(name: 'NMEA IN -', type: portTypeNmeaInNegative, offset: Offset(10, 70)),
            PortTemplate(name: 'NMEA OUT +', type: portTypeNmeaOutPositive, offset: Offset(190, 40)),
            PortTemplate(name: 'NMEA OUT -', type: portTypeNmeaOutNegative, offset: Offset(190, 70)),
            PortTemplate(name: 'N2K Backbone', type: portTypeN2k, offset: Offset(160, 105)),
          ],
        ),
      ],
      DeviceCategory.communication: [
        DeviceTemplate(
          catalogName: 'VHF Radio',
          manufacturer: 'Standard Horizon',
          model: 'GX2200',
          category: DeviceCategory.communication,
          size: const Size(210, 140),
          nominalVoltage: 12.0,
          currentDraw: 1.5,
          defaultVoltage: 11.9,
          ports: const [
            PortTemplate(name: 'Power +', type: portTypePowerPositive, offset: Offset(30, 120)),
            PortTemplate(name: 'Power -', type: portTypePowerNegative, offset: Offset(80, 120)),
            PortTemplate(name: 'NMEA IN +', type: portTypeNmeaInPositive, offset: Offset(10, 50)),
            PortTemplate(name: 'NMEA IN -', type: portTypeNmeaInNegative, offset: Offset(10, 80)),
          ],
        ),
        DeviceTemplate(
          catalogName: 'Multiplexor 0183',
          manufacturer: 'ShipModul',
          model: 'MiniPlex-3',
          category: DeviceCategory.communication,
          size: const Size(200, 120),
          nominalVoltage: 12.0,
          currentDraw: 0.6,
          defaultVoltage: 11.6,
          ports: const [
            PortTemplate(name: 'Power +', type: portTypePowerPositive, offset: Offset(20, 95)),
            PortTemplate(name: 'Power -', type: portTypePowerNegative, offset: Offset(70, 95)),
            PortTemplate(name: 'NMEA IN +', type: portTypeNmeaInPositive, offset: Offset(10, 30)),
            PortTemplate(name: 'NMEA IN -', type: portTypeNmeaInNegative, offset: Offset(10, 60)),
            PortTemplate(name: 'NMEA OUT +', type: portTypeNmeaOutPositive, offset: Offset(190, 30)),
            PortTemplate(name: 'NMEA OUT -', type: portTypeNmeaOutNegative, offset: Offset(190, 60)),
          ],
        ),
      ],
    };
  }

  @override
  void initState() {
    super.initState();
    _addLog(LogLevel.info, 'Welcome to BlueBus Studio. Tap New to start a fresh project.');
  }

  void _addLog(LogLevel level, String message) {
    setState(() {
      _logs.insert(0, LogEntry(level: level, message: message, timestamp: DateTime.now()));
    });
  }

  void _handleAddDevice(DeviceTemplate template) {
    setState(() {
      final id = 'device_${_devices.length + 1}';
      final device = DeviceModel(
        id: id,
        name: template.catalogName,
        model: template.model,
        position: const Offset(80, 80),
        ports: template.ports
            .map((port) => PortModel(name: port.name, type: port.type, offset: port.offset))
            .toList(),
        nominalVoltage: template.nominalVoltage,
        actualVoltage: template.defaultVoltage,
        currentDraw: template.currentDraw,
        category: template.category.label,
        size: template.size,
        batteryCapacityAh: template.batteryCapacityAh,
        defaultVoltage: template.defaultVoltage,
      );
      _devices.add(device);
      _selectedDeviceId = id;
      _addLog(LogLevel.info, 'Added ${template.catalogName}.');
    });
  }

  void _handleSelectDevice(String deviceId) {
    setState(() {
      _selectedDeviceId = deviceId;
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

  void _handlePortTap(DeviceModel device, int portIndex) {
    final portId = '${device.id}:$portIndex';
    final selectedPort = _selectedPortId;
    if (selectedPort == null) {
      setState(() {
        _selectedPortId = portId;
      });
      return;
    }

    if (selectedPort == portId) {
      setState(() {
        _selectedPortId = null;
      });
      return;
    }

    final origin = _resolvePortById(selectedPort);
    final target = _resolvePortById(portId);

    if (origin == null || target == null) {
      setState(() {
        _selectedPortId = null;
      });
      return;
    }

    if (!_arePortsCompatible(origin.port.type, target.port.type)) {
      _addLog(LogLevel.warn, 'Ports are not compatible.');
      setState(() {
        _selectedPortId = null;
      });
      return;
    }

    final exists = _cables.any(
      (cable) => (cable.fromPortId == selectedPort && cable.toPortId == portId) ||
          (cable.fromPortId == portId && cable.toPortId == selectedPort),
    );

    if (exists) {
      _addLog(LogLevel.warn, 'These ports are already connected.');
      setState(() {
        _selectedPortId = null;
      });
      return;
    }

    setState(() {
      _cables.add(CableModel(fromPortId: selectedPort, toPortId: portId));
      _selectedPortId = null;
      _addLog(LogLevel.ok, 'Created connection between ${origin.device.name} and ${target.device.name}.');
    });
    checkForShortCircuits();
  }

  _ResolvedPort? _resolvePortById(String portId) {
    final split = portId.split(':');
    if (split.length != 2) return null;
    final device = _devices.where((d) => d.id == split.first).cast<DeviceModel?>().firstWhere((d) => d != null, orElse: () => null);
    if (device == null) return null;
    final index = int.tryParse(split.last);
    if (index == null || index < 0 || index >= device.ports.length) return null;
    return _ResolvedPort(device: device, port: device.ports[index], portIndex: index);
  }

  bool _arePortsCompatible(String a, String b) {
    if (a == b) {
      return a == portTypePowerPositive || a == portTypePowerNegative || a == portTypeN2k;
    }

    final bool isPositivePair =
        (a == portTypeNmeaOutPositive && b == portTypeNmeaInPositive) ||
            (a == portTypeNmeaInPositive && b == portTypeNmeaOutPositive);
    final bool isNegativePair =
        (a == portTypeNmeaOutNegative && b == portTypeNmeaInNegative) ||
            (a == portTypeNmeaInNegative && b == portTypeNmeaOutNegative);

    return isPositivePair || isNegativePair;
  }

  void _handleNewProject() {
    setState(() {
      _devices.clear();
      _cables.clear();
      _logs.clear();
      _selectedDeviceId = null;
      _selectedPortId = null;
      _simulationRunning = false;
      _hasShortCircuit = false;
    });
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

  void _handleRunSimulation() {
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
    runSimulation();
  }

  void checkForShortCircuits() {
    final Map<CableModel, String> shortMessages = {};

    for (final cable in _cables) {
      final from = _resolvePortById(cable.fromPortId);
      final to = _resolvePortById(cable.toPortId);
      if (from == null || to == null) continue;

      final bool connectsPowerPair =
          (from.port.type == portTypePowerPositive && to.port.type == portTypePowerNegative) ||
              (from.port.type == portTypePowerNegative && to.port.type == portTypePowerPositive);

      if (!connectsPowerPair) {
        continue;
      }

      final bool sameDevice = from.device.id == to.device.id;
      final bool bothSources = _isPowerSourceDevice(from.device) && _isPowerSourceDevice(to.device);

      if (sameDevice || bothSources) {
        final descriptionA = '${from.device.name} ${from.port.name}';
        final descriptionB = '${to.device.name} ${to.port.name}';
        shortMessages[cable] = 'Short circuit detected between $descriptionA and $descriptionB. Check wiring.';
      }
    }

    final shortSet = shortMessages.keys.toSet();

    setState(() {
      _hasShortCircuit = shortSet.isNotEmpty;
      for (final cable in _cables) {
        cable.isShortCircuit = shortSet.contains(cable);
      }
    });

    for (final message in shortMessages.values) {
      _addLog(LogLevel.error, message);
    }
  }

  void runSimulation() {
    final batteries = _devices.where(_isBatteryDevice).toList();
    final List<DeviceModel> warnings = [];

    setState(() {
      for (final device in _devices) {
        device.voltageWarning = false;
        if (device.nominalVoltage != null) {
          device.actualVoltage = device.nominalVoltage;
        } else {
          device.actualVoltage = null;
        }
      }

      for (final battery in batteries) {
        battery.actualVoltage = battery.nominalVoltage;
        for (final target in _devices) {
          if (target.id == battery.id) continue;
          final hasPositive = _hasDirectConnection(
            battery.id,
            portTypePowerPositive,
            target.id,
            portTypePowerPositive,
          );
          final hasNegative = _hasDirectConnection(
            battery.id,
            portTypePowerNegative,
            target.id,
            portTypePowerNegative,
          );

          if (hasPositive && hasNegative && battery.nominalVoltage != null) {
            final supplyVoltage = (battery.nominalVoltage! - 0.2).clamp(0.0, battery.nominalVoltage!);
            target.actualVoltage = supplyVoltage;
          }
        }
      }

      for (final device in _devices) {
        final nominal = device.nominalVoltage;
        final actual = device.actualVoltage;
        if (nominal != null && actual != null && actual < nominal - 0.5) {
          device.voltageWarning = true;
          warnings.add(device);
        }
      }
    });

    if (batteries.isEmpty) {
      _addLog(LogLevel.warn, 'No batteries available to power devices.');
    }

    for (final device in warnings) {
      _addLog(
        LogLevel.warn,
        '[WARN] ${device.name} low voltage: ${device.actualVoltage?.toStringAsFixed(1) ?? 'N/A'} V',
      );
    }

    _addLog(LogLevel.ok, 'Simulation completed.');
  }

  bool _isBatteryDevice(DeviceModel device) {
    if (device.category.toLowerCase() != 'power') {
      return false;
    }
    if (device.currentDraw != null && device.currentDraw! < 0) {
      return true;
    }
    return device.batteryCapacityAh != null;
  }

  bool _isPowerSourceDevice(DeviceModel device) {
    if (device.category.toLowerCase() == 'power') {
      return true;
    }
    if (device.currentDraw != null && device.currentDraw! < 0) {
      return true;
    }
    return false;
  }

  bool _hasDirectConnection(
    String fromDeviceId,
    String fromType,
    String toDeviceId,
    String toType,
  ) {
    for (final cable in _cables) {
      final from = _resolvePortById(cable.fromPortId);
      final to = _resolvePortById(cable.toPortId);
      if (from == null || to == null) continue;
      final bool matchesForward =
          from.device.id == fromDeviceId && from.port.type == fromType && to.device.id == toDeviceId && to.port.type == toType;
      final bool matchesBackward =
          to.device.id == fromDeviceId && to.port.type == fromType && from.device.id == toDeviceId && from.port.type == toType;
      if (matchesForward || matchesBackward) {
        return true;
      }
    }
    return false;
  }

  String _preferredCableType(String a, String b) {
    if (a == b) return a;
    if ({portTypeNmeaOutPositive, portTypeNmeaInPositive}.contains(a) &&
        {portTypeNmeaOutPositive, portTypeNmeaInPositive}.contains(b)) {
      return portTypeNmeaOutPositive;
    }
    if ({portTypeNmeaOutNegative, portTypeNmeaInNegative}.contains(a) &&
        {portTypeNmeaOutNegative, portTypeNmeaInNegative}.contains(b)) {
      return portTypeNmeaOutNegative;
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
            child: Stack(
              children: [
                CustomPaint(size: size, painter: _GridPainter()),
                ..._buildCables(),
                ..._devices.map((device) => _buildDeviceWidget(device, size)),
              ],
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
      final fromOffset = from.device.position + from.port.offset;
      final toOffset = to.device.position + to.port.offset;
      final cableType = _preferredCableType(from.port.type, to.port.type);
      final isShort = cable.isShortCircuit;
      final cableColor = isShort ? const Color(0xFFFF3B30) : colorForCable(cableType);
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
    final isSelected = _selectedDeviceId == device.id;
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
                        Icon(Icons.memory, size: 18, color: Theme.of(context).colorScheme.primary),
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
              ...List.generate(device.ports.length, (index) {
                final port = device.ports[index];
                final portId = '${device.id}:$index';
                final isPortSelected = _selectedPortId == portId;
                return PositionedPort(
                  port: port,
                  isSelected: isPortSelected,
                  onTap: () => _handlePortTap(device, index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesPanel(ColorScheme colorScheme) {
    final selected = _devices
        .where((d) => d.id == _selectedDeviceId)
        .cast<DeviceModel?>()
        .firstWhere((d) => d != null, orElse: () => null);
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
                      const SizedBox(height: 12),
                      Text('Ports', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      ...device.ports.map(
                        (port) {
                          final portColor = colorForPort(port.type);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
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
    this.batteryCapacityAh,
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
  final double? batteryCapacityAh;
  final List<PortTemplate> ports;
}

class PortTemplate {
  const PortTemplate({
    required this.name,
    required this.type,
    required this.offset,
  });

  final String name;
  final String type;
  final Offset offset;
}

class PortModel {
  PortModel({
    required this.name,
    required this.type,
    required this.offset,
  });

  final String name;
  final String type;
  final Offset offset;
}

class DeviceModel {
  DeviceModel({
    required this.id,
    required this.name,
    required this.position,
    required this.ports,
    required this.nominalVoltage,
    required this.actualVoltage,
    required this.currentDraw,
    required this.category,
    required this.size,
    this.model,
    this.batteryCapacityAh,
    this.defaultVoltage,
  });

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
  final double? batteryCapacityAh;
  final double? defaultVoltage;
  bool voltageWarning = false;
}

class CableModel {
  CableModel({
    required this.fromPortId,
    required this.toPortId,
    this.isShortCircuit = false,
  });

  final String fromPortId;
  final String toPortId;
  bool isShortCircuit;
}

class PositionedPort extends StatelessWidget {
  const PositionedPort({
    required this.port,
    required this.isSelected,
    required this.onTap,
  });

  final PortModel port;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = colorForPort(port.type);
    final fillColor = isSelected ? baseColor : baseColor.withOpacity(0.9);
    final borderColor = isSelected ? Colors.white : Colors.white24;
    return Positioned(
      left: port.offset.dx - 7,
      top: port.offset.dy - 7,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Tooltip(
          message: port.name,
          waitDuration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.6 : 0.45),
                  blurRadius: isSelected ? 6 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResolvedPort {
  _ResolvedPort({required this.device, required this.port, required this.portIndex});

  final DeviceModel device;
  final PortModel port;
  final int portIndex;
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
    case portTypePowerPositive:
      return 'Power +';
    case portTypePowerNegative:
      return 'Power -';
    case portTypeNmeaOutPositive:
      return 'NMEA OUT +';
    case portTypeNmeaOutNegative:
      return 'NMEA OUT -';
    case portTypeNmeaInPositive:
      return 'NMEA IN +';
    case portTypeNmeaInNegative:
      return 'NMEA IN -';
    case portTypeN2k:
      return 'N2K';
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
