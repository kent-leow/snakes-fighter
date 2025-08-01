import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Authentication state data class
class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final User? user;
  final bool isLoading;
  final String? error;

  /// Check if user is authenticated
  bool get isAuthenticated => user != null;

  /// Check if current user is anonymous
  bool get isAnonymous => user?.isAnonymous ?? false;

  /// Get user display name
  String get displayName {
    if (user == null) return 'Guest';

    if (user!.isAnonymous) {
      // Generate a friendly name for anonymous users
      final uid = user!.uid;
      final shortId = uid.length > 6 ? uid.substring(0, 6) : uid;
      return 'Player $shortId';
    }

    return user!.displayName ?? user!.email ?? 'Unknown User';
  }

  /// Create a copy with updated fields
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Create loading state
  AuthState loading() => copyWith(isLoading: true, clearError: true);

  /// Create error state
  AuthState withError(String error) => copyWith(isLoading: false, error: error);

  /// Create success state
  AuthState withUser(User? user) =>
      copyWith(user: user, isLoading: false, clearError: true);

  @override
  String toString() {
    return 'AuthState(user: ${user?.uid}, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.user?.uid == user?.uid &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(user?.uid, isLoading, error);
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState()) {
    // Listen to auth state changes
    _authStateSubscription = _authService.authStateChanges.listen(
      (user) {
        if (!mounted) return;
        state = state.withUser(user);
      },
      onError: (error) {
        if (!mounted) return;
        state = state.withError('Authentication error: $error');
      },
    );

    // Initialize with current user
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      state = state.withUser(currentUser);
    }
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _authStateSubscription;

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
    if (state.error != null) {
      state = state.copyWith(clearError: true);
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
      // User state will be updated via authStateChanges stream
    } on AuthException catch (e) {
      state = state.withError(e.message);
    } catch (e) {
      state = state.withError('Unexpected error deleting user: $e');
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
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
