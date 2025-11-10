import 'package:flutter/foundation.dart';

import '../models/device_instance.dart';
import '../models/project.dart';

class ProjectController extends ChangeNotifier {
  ProjectController()
      : _currentProject = Project(name: 'Nuevo proyecto');

  Project _currentProject;

  Project get currentProject => _currentProject;

  void setProject(Project project) {
    _currentProject = project;
    notifyListeners();
  }

  void addDevice(DeviceInstance device) {
    _currentProject.devices.add(device);
    notifyListeners();
  }
}
