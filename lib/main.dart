// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'core/core.dart';

void main() {
  runApp(const SnakesFightApp());
}

class SnakesFightApp extends StatelessWidget {
  const SnakesFightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snakes Fight'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Snakes Fight!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('A multiplayer Snake game', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
