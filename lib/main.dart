import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/core.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize app services
  await AppInitializationService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SnakesFightApp(),
    ),
  );
}

class SnakesFightApp extends ConsumerWidget {
  const SnakesFightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthWrapper(), // Use AuthWrapper to determine initial route
      debugShowCheckedModeBanner: false,
    );
  }
}
