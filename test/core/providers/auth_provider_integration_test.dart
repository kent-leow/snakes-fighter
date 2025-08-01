import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snakes_fight/core/models/auth_models.dart';
import 'package:snakes_fight/core/providers/auth_provider.dart';
import 'package:snakes_fight/core/services/auth_service.dart';
import 'package:snakes_fight/core/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Test implementation
class TestAuthService implements AuthService {
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  TestAuthService() {
    // Initialize with null user
    _authStateController.add(null);
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  bool get isSignedIn => _currentUser != null;

  @override
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;

  @override
  String get userDisplayName => _currentUser?.displayName ?? 'Guest';

  @override
  Future<UserCredential?> signInAnonymously() async {
    // Create a mock User
    _currentUser = _createMockUser(uid: 'anonymous-uid', isAnonymous: true);
    _authStateController.add(_currentUser);

    // Return a mock UserCredential
    return _MockUserCredential(_currentUser!);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    _currentUser = _createMockUser(
      uid: 'google-uid',
      email: 'test@gmail.com',
      displayName: 'Test User',
      isAnonymous: false,
    );
    _authStateController.add(_currentUser);
    return _MockUserCredential(_currentUser!);
  }

  @override
  Future<UserCredential?> linkAnonymousWithGoogle() async {
    if (_currentUser?.isAnonymous == true) {
      _currentUser = _createMockUser(
        uid: _currentUser!.uid,
        email: 'linked@gmail.com',
        displayName: 'Linked User',
        isAnonymous: false,
      );
      _authStateController.add(_currentUser);
      return _MockUserCredential(_currentUser!);
    }
    throw const AuthException('User is not anonymous');
  }

  @override
  Future<void> deleteAnonymousUser() async {
    if (_currentUser?.isAnonymous == true) {
      _currentUser = null;
      _authStateController.add(null);
    } else {
      throw const AuthException('User is not anonymous');
    }
  }

  @override
  Future<String?> getStoredUserId() async => _currentUser?.uid;

  @override
  Future<bool> getStoredAnonymousStatus() async =>
      _currentUser?.isAnonymous ?? false;

  User _createMockUser({
    required String uid,
    String? email,
    String? displayName,
    required bool isAnonymous,
  }) {
    return _MockUser(
      uid: uid,
      email: email,
      displayName: displayName,
      isAnonymous: isAnonymous,
    );
  }

  void dispose() {
    _authStateController.close();
  }
}

class _MockUser implements User {
  _MockUser({
    required this.uid,
    this.email,
    this.displayName,
    required this.isAnonymous,
  });

  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final bool isAnonymous;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockUserCredential implements UserCredential {
  _MockUserCredential(this.user);

  @override
  final User user;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class TestSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    return Map<String, String>.from(_storage);
  }

  @override
  Future<bool> containsKey({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Authentication State Management Integration', () {
    late ProviderContainer container;
    late TestAuthService testAuthService;
    late StorageService testStorageService;

    setUp(() {
      testAuthService = TestAuthService();
      testStorageService = StorageService(secureStorage: TestSecureStorage());

      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(testAuthService),
          storageServiceProvider.overrideWithValue(testStorageService),
        ],
      );
    });

    tearDown(() {
      testAuthService.dispose();
      container.dispose();
    });

    test('should initialize with unauthenticated state', () async {
      // Give some time for initialization
      await Future.delayed(const Duration(milliseconds: 50));

      final authState = container.read(authProvider);

      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.user, isNull);
      expect(authState.isLoading, false);
      expect(authState.error, isNull);
    });

    test('should handle successful anonymous sign in', () async {
      final authNotifier = container.read(authProvider.notifier);

      await authNotifier.signInAnonymously();

      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.authenticated);
      expect(authState.user, isNotNull);
      expect(authState.user!.isAnonymous, true);
      expect(authState.isLoading, false);
      expect(authState.error, isNull);
    });

    test('should persist user data after sign in', () async {
      final authNotifier = container.read(authProvider.notifier);

      await authNotifier.signInAnonymously();

      // Give some time for async operations
      await Future.delayed(const Duration(milliseconds: 50));

      // Check that data was stored
      final storedUser = await testStorageService.getUserData();
      expect(storedUser, isNotNull);
      expect(storedUser!.isAnonymous, true);

      final isSessionValid = await testStorageService.isSessionValid();
      expect(isSessionValid, true);
    });

    test('should handle sign out and clear data', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Sign in first
      await authNotifier.signInAnonymously();
      await Future.delayed(const Duration(milliseconds: 50));

      // Sign out
      await authNotifier.signOut();
      await Future.delayed(const Duration(milliseconds: 50));

      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.user, isNull);

      // Check that data was cleared
      final storedUser = await testStorageService.getUserData();
      expect(storedUser, isNull);

      final isSessionValid = await testStorageService.isSessionValid();
      expect(isSessionValid, false);
    });

    test('should handle Google sign in', () async {
      final authNotifier = container.read(authProvider.notifier);

      await authNotifier.signInWithGoogle();

      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.authenticated);
      expect(authState.user, isNotNull);
      expect(authState.user!.isAnonymous, false);
      expect(authState.user!.email, 'test@gmail.com');
    });

    test('should provide computed authentication state', () async {
      // Check unauthenticated state
      await Future.delayed(const Duration(milliseconds: 50));

      bool isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, false);

      User? currentUser = container.read(currentUserProvider);
      expect(currentUser, isNull);

      // Sign in
      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.signInAnonymously();

      // Check authenticated state
      isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, true);

      currentUser = container.read(currentUserProvider);
      expect(currentUser, isNotNull);
      expect(currentUser!.isAnonymous, true);
    });

    test('should handle account linking', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Start with anonymous user
      await authNotifier.signInAnonymously();

      var authState = container.read(authProvider);
      expect(authState.user!.isAnonymous, true);

      // Link with Google
      await authNotifier.linkAnonymousWithGoogle();

      authState = container.read(authProvider);
      expect(authState.user!.isAnonymous, false);
      expect(authState.user!.email, 'linked@gmail.com');
    });

    test('should handle anonymous user deletion', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Sign in anonymously
      await authNotifier.signInAnonymously();

      var authState = container.read(authProvider);
      expect(authState.isAnonymous, true);

      // Delete anonymous user
      await authNotifier.deleteAnonymousUser();
      await Future.delayed(const Duration(milliseconds: 50));

      authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.user, isNull);
    });
  });
}
