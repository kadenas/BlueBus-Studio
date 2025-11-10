import 'package:flutter/material.dart';

import '../widgets/bluebus_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const BlueBusLogo(size: 120),
            const SizedBox(height: 24),
            Text(
              'BlueBus Studio',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Simulador de redes náuticas',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/editor'),
                child: const Text('Nuevo proyecto'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 240,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Abrir proyecto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
