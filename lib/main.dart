import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/core.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize app services
  await AppInitializationService.instance.initialize();

  runApp(const ProviderScope(child: SnakesFightApp()));
}

class SnakesFightApp extends ConsumerWidget {
  const SnakesFightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthWrapper(), // Use AuthWrapper to determine initial route
      debugShowCheckedModeBanner: false,
    );
  }
}
