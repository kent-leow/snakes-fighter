import 'package:flutter/material.dart';

import 'core/core.dart';
import 'core/navigation/app_router.dart';

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
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.mainMenu,
      debugShowCheckedModeBanner: false,
    );
  }
}
