import 'package:flutter/material.dart';

import 'ui/pages/editor_page.dart';
import 'ui/pages/splash_page.dart';
import 'ui/theme/app_theme.dart';

class BlueBusApp extends StatelessWidget {
  const BlueBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueBus Studio',
      theme: AppTheme.buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/editor': (context) => const EditorPage(),
      },
    );
  }
}
