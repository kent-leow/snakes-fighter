import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._storageService)
    : super(const AuthState()) {
    _initializeAuth();
  }

  final AuthService _authService;
  final StorageService _storageService;
  StreamSubscription<User?>? _authStateSubscription;

  /// Initialize authentication state
  void _initializeAuth() {
    // Listen to auth state changes
    _authStateSubscription = _authService.authStateChanges.listen(
      (user) {
        if (!mounted) return;
        _handleAuthStateChange(user);
      },
      onError: (error) {
        if (!mounted) return;
        state = state.withError('Authentication error: $error');
      },
    );

    // Check for stored session
    _checkStoredSession();
  }

  /// Handle Firebase auth state changes
  void _handleAuthStateChange(User? user) async {
    if (user == null) {
      // User signed out or session expired
      await _storageService.clearUserData();
      state = state.unauthenticated();
    } else {
      // User signed in
      final userData = UserData.fromFirebaseUser(user);
      await _storageService.storeUserData(userData);

      state = state.withUser(user);
    }
  }

  /// Check for stored authentication session
  Future<void> _checkStoredSession() async {
    try {
      final isSessionValid = await _storageService.isSessionValid();
      final userData = await _storageService.getUserData();

      if (isSessionValid && userData != null) {
        // We have a valid stored session, but Firebase auth state
        // will be the source of truth
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          state = state.withUser(currentUser);
        } else {
          // Stored session is invalid, clear it
          await _storageService.clearUserData();
          state = state.unauthenticated();
        }
      } else {
        // No valid stored session
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          state = state.withUser(currentUser);
        } else {
          state = state.unauthenticated();
        }
      }
    } catch (e) {
      // If there's an error checking stored session, default to checking current user
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        state = state.withUser(currentUser);
      } else {
        state = state.unauthenticated();
      }
    }
  }

  /// Sign in anonymously
  Future<void> signInAnonymously() async {
    try {
      state = state.loading();
      await _authService.signInAnonymously();
      // User state will be updated via authStateChanges stream
    } on AuthException catch (e) {
      state = state.withError(e.message);
    } catch (e) {
      state = state.withError('Unexpected error during sign in: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      state = state.loading();
      await _authService.signOut();
      // Clear stored session data
      await _storageService.clearUserData();
      // User state will be updated via authStateChanges stream
    } on AuthException catch (e) {
      state = state.withError(e.message);
    } catch (e) {
      state = state.withError('Unexpected error during sign out: $e');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.loading();
      await _authService.signInWithGoogle();
      // User state will be updated via authStateChanges stream
    } on AuthException catch (e) {
      state = state.withError(e.message);
    } catch (e) {
      state = state.withError('Unexpected error during Google sign in: $e');
    }
  }

  /// Link anonymous account with Google
  Future<void> linkAnonymousWithGoogle() async {
    if (!state.isAnonymous) {
      state = state.withError('Cannot link non-anonymous user');
      return;
    }

    try {
      state = state.loading();
      await _authService.linkAnonymousWithGoogle();
      // User state will be updated via authStateChanges stream
    } on AuthException catch (e) {
      state = state.withError(e.message);
    } catch (e) {
      state = state.withError('Unexpected error during account linking: $e');
    }
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: state.isAuthenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        clearError: true,
      );
    }
  }

  /// Delete anonymous user account
  Future<void> deleteAnonymousUser() async {
    if (!state.isAnonymous) {
      state = state.withError('Cannot delete non-anonymous user');
      return;
    }

    try {
      state = state.loading();
      await _authService.deleteAnonymousUser();
      // Clear stored session data
      await _storageService.clearUserData();
      // User state will be updated via authStateChanges stream
    } on AuthException catch (e) {
      state = state.withError(e.message);
    } catch (e) {
      state = state.withError('Unexpected error deleting user: $e');
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(storageServiceProvider),
  );
});

/// Stream provider for auth state changes (alternative approach)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for anonymous status
final isAnonymousProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAnonymous;
});

/// Provider for loading status
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Provider for error status
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
