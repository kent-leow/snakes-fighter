import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/auth_models.dart';

void main() {
  group('AuthStatus', () {
    test('should have all required values', () {
      expect(AuthStatus.values, [
        AuthStatus.initial,
        AuthStatus.loading,
        AuthStatus.authenticated,
        AuthStatus.unauthenticated,
        AuthStatus.error,
      ]);
    });
  });

  group('AuthState', () {
    test('should create with default values', () {
      const authState = AuthState();

      expect(authState.status, AuthStatus.initial);
      expect(authState.user, isNull);
      expect(authState.error, isNull);
      expect(authState.isAnonymous, false);
    });

    test('should correctly identify authenticated state', () {
      // Unauthenticated state
      const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
      expect(unauthenticated.isAuthenticated, false);

      // Loading state
      const loading = AuthState(status: AuthStatus.loading);
      expect(loading.isAuthenticated, false);

      // Error state
      const error = AuthState(status: AuthStatus.error, error: 'Error message');
      expect(error.isAuthenticated, false);
    });

    test('should correctly identify loading state', () {
      const loading = AuthState(status: AuthStatus.loading);
      expect(loading.isLoading, true);

      const notLoading = AuthState(status: AuthStatus.authenticated);
      expect(notLoading.isLoading, false);
    });

    test('should correctly identify error state', () {
      const errorState = AuthState(
        status: AuthStatus.error,
        error: 'Test error',
      );
      expect(errorState.hasError, true);

      const noErrorState = AuthState(status: AuthStatus.authenticated);
      expect(noErrorState.hasError, false);
    });

    test('should provide guest display name when no user', () {
      const authState = AuthState();
      expect(authState.displayName, 'Guest');
    });

    test('should create loading state correctly', () {
      const initial = AuthState(error: 'Previous error');
      final loading = initial.loading();

      expect(loading.status, AuthStatus.loading);
      expect(loading.error, isNull);
    });

    test('should create error state correctly', () {
      const initial = AuthState(status: AuthStatus.loading);
      const errorMessage = 'Test error';
      final errorState = initial.withError(errorMessage);

      expect(errorState.status, AuthStatus.error);
      expect(errorState.error, errorMessage);
    });

    test('should create unauthenticated state correctly', () {
      const initial = AuthState(
        status: AuthStatus.authenticated,
        error: 'Previous error',
      );
      final unauthenticated = initial.unauthenticated();

      expect(unauthenticated.status, AuthStatus.unauthenticated);
      expect(unauthenticated.user, isNull);
      expect(unauthenticated.error, isNull);
      expect(unauthenticated.isAnonymous, false);
    });

    test('should copy with updated fields', () {
      const original = AuthState(error: 'Original error');

      final updated = original.copyWith(
        status: AuthStatus.loading,
        clearError: true,
      );

      expect(updated.status, AuthStatus.loading);
      expect(updated.error, isNull);
    });

    test('equality should work correctly', () {
      const state1 = AuthState(status: AuthStatus.loading, error: 'Test error');
      const state2 = AuthState(status: AuthStatus.loading, error: 'Test error');
      const state3 = AuthState(status: AuthStatus.error, error: 'Test error');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('toString should provide meaningful output', () {
      const authState = AuthState(
        status: AuthStatus.loading,
        error: 'Test error',
        isAnonymous: true,
      );

      final string = authState.toString();
      expect(string, contains('AuthState'));
      expect(string, contains('loading'));
      expect(string, contains('Test error'));
      expect(string, contains('true'));
    });
  });

  group('UserData', () {
    test('should create from minimal data', () {
      final userData = UserData(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAnonymous: false,
        createdAt: DateTime(2024),
      );

      expect(userData.uid, 'test-uid');
      expect(userData.email, 'test@example.com');
      expect(userData.displayName, 'Test User');
      expect(userData.isAnonymous, false);
      expect(userData.createdAt, DateTime(2024));
      expect(userData.lastSignInAt, isNull);
      expect(userData.photoUrl, isNull);
    });

    test('should convert to and from JSON', () {
      final original = UserData(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAnonymous: false,
        createdAt: DateTime(2024),
        lastSignInAt: DateTime(2024, 1, 2),
        photoUrl: 'https://example.com/photo.jpg',
      );

      final json = original.toJson();
      final restored = UserData.fromJson(json);

      expect(restored.uid, original.uid);
      expect(restored.email, original.email);
      expect(restored.displayName, original.displayName);
      expect(restored.isAnonymous, original.isAnonymous);
      expect(restored.createdAt, original.createdAt);
      expect(restored.lastSignInAt, original.lastSignInAt);
      expect(restored.photoUrl, original.photoUrl);
    });

    test('equality should work correctly', () {
      final userData1 = UserData(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAnonymous: false,
        createdAt: DateTime(2024),
      );

      final userData2 = UserData(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAnonymous: false,
        createdAt: DateTime(2024),
      );

      final userData3 = UserData(
        uid: 'different-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAnonymous: false,
        createdAt: DateTime(2024),
      );

      expect(userData1, equals(userData2));
      expect(userData1, isNot(equals(userData3)));
    });

    test('toString should provide meaningful output', () {
      final userData = UserData(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isAnonymous: false,
        createdAt: DateTime(2024),
      );

      final string = userData.toString();
      expect(string, contains('UserData'));
      expect(string, contains('test-uid'));
      expect(string, contains('test@example.com'));
      expect(string, contains('Test User'));
      expect(string, contains('false'));
    });
  });
}
