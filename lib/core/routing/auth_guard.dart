import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_models.dart';
import '../providers/auth_provider.dart';

/// Navigation guard for protecting authenticated routes
class AuthGuard {
  /// Check if user can access a protected route
  static bool canAccess(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    return authState.isAuthenticated;
  }

  /// Redirect logic for route protection
  static String? redirectLogic(
    BuildContext context,
    WidgetRef ref,
    String currentRoute,
  ) {
    final authState = ref.read(authProvider);

    // If user is not authenticated and trying to access protected routes
    if (!authState.isAuthenticated && _isProtectedRoute(currentRoute)) {
      return '/auth';
    }

    // If user is authenticated and on auth route, redirect to main menu
    if (authState.isAuthenticated && currentRoute == '/auth') {
      return '/';
    }

    return null; // Allow navigation
  }

  /// Check if a route requires authentication
  static bool _isProtectedRoute(String route) {
    const protectedRoutes = [
      '/',
      '/game',
      '/settings',
      '/pause-menu',
      '/game-over',
    ];

    return protectedRoutes.contains(route);
  }
}

/// Widget that protects routes based on authentication state
class AuthenticationGuard extends ConsumerWidget {
  const AuthenticationGuard({
    required this.child,
    this.fallback,
    this.requireAuth = true,
    super.key,
  });

  final Widget child;
  final Widget? fallback;
  final bool requireAuth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading while auth state is being determined
    if (authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.initial) {
      return const AuthLoadingScreen();
    }

    // Check authentication requirement
    if (requireAuth && !authState.isAuthenticated) {
      return fallback ?? const AuthRequiredScreen();
    }

    if (!requireAuth && authState.isAuthenticated) {
      return fallback ?? const AlreadyAuthenticatedScreen();
    }

    return child;
  }
}

/// Screen shown while authentication state is loading
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videogame_asset, size: 80, color: Colors.white),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen shown when authentication is required
class AuthRequiredScreen extends StatelessWidget {
  const AuthRequiredScreen({super.key});

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
                const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Authentication Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You need to sign in to access this feature.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/auth');
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen shown when user is already authenticated
class AlreadyAuthenticatedScreen extends StatelessWidget {
  const AlreadyAuthenticatedScreen({super.key});

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
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Already Signed In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You are already authenticated. Redirecting to main menu...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('Go to Main Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
