import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/navigation/app_router.dart';
import 'auth_screen.dart';

/// Widget that determines the initial route based on authentication state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Handle different authentication states
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const AuthLoadingScreen();

      case AuthStatus.authenticated:
        return const MainMenuWrapper();

      case AuthStatus.unauthenticated:
        return const AuthScreen();

      case AuthStatus.error:
        return ErrorScreen(error: authState.error ?? 'Unknown error');
    }
  }
}

/// Wrapper for main menu that ensures user is authenticated
class MainMenuWrapper extends ConsumerWidget {
  const MainMenuWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This widget would normally load the main menu
    // For now, we'll show a placeholder that navigates to main menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRouter.mainMenu);
    });

    return const LoadingScreen();
  }
}

/// Loading screen shown during authentication state checks
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLoadingScreen();
  }
}

/// Error screen shown when authentication fails
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.error, super.key});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Authentication Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.auth,
                      (route) => false,
                    );
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
