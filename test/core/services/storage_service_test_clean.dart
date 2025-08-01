import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snakes_fight/core/models/auth_models.dart';
import 'package:snakes_fight/core/services/storage_service.dart';

// Simple mock implementation for testing
class TestSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = <String, String>{};
  bool _shouldThrow = false;

  void throwOnNextOperation() {
    _shouldThrow = true;
  }

  void _checkForThrow() {
    if (_shouldThrow) {
      _shouldThrow = false;
      throw Exception('Mock storage error');
    }
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _checkForThrow();
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
    _checkForThrow();
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _checkForThrow();
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _checkForThrow();
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _checkForThrow();
    return Map<String, String>.from(_storage);
  }

  @override
  Future<bool> containsKey({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
  }) async {
    _checkForThrow();
    return _storage.containsKey(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('StorageService', () {
    late TestSecureStorage testStorage;
    late StorageService storageService;

    setUp(() {
      testStorage = TestSecureStorage();
      storageService = StorageService(secureStorage: testStorage);
    });

    group('User Data Management', () {
      test('should store and retrieve user data successfully', () async {
        final userData = UserData(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAnonymous: false,
          createdAt: DateTime(2024),
        );

        await storageService.storeUserData(userData);

        // Verify data was stored
        final storedData = await testStorage.read(key: 'user_data');
        expect(storedData, isNotNull);
        expect(storedData, contains('test-uid'));

        final sessionValid = await testStorage.read(key: 'session_valid');
        expect(sessionValid, 'true');

        // Retrieve and verify
        final result = await storageService.getUserData();
        expect(result, isNotNull);
        expect(result!.uid, userData.uid);
        expect(result.email, userData.email);
        expect(result.displayName, userData.displayName);
        expect(result.isAnonymous, userData.isAnonymous);
      });

      test('should return null when no user data stored', () async {
        final result = await storageService.getUserData();
        expect(result, isNull);
      });

      test('should handle corrupted user data gracefully', () async {
        // Store invalid JSON
        await testStorage.write(key: 'user_data', value: 'invalid-json');

        final result = await storageService.getUserData();

        expect(result, isNull);
        // Should have cleared corrupted data
        final storedData = await testStorage.read(key: 'user_data');
        expect(storedData, isNull);
      });

      test('should clear user data successfully', () async {
        // Store some data first
        await testStorage.write(key: 'user_data', value: 'test');
        await testStorage.write(key: 'auth_token', value: 'token');
        await testStorage.write(key: 'refresh_token', value: 'refresh');
        await testStorage.write(key: 'session_valid', value: 'true');

        await storageService.clearUserData();

        // Verify all data was cleared
        expect(await testStorage.read(key: 'user_data'), isNull);
        expect(await testStorage.read(key: 'auth_token'), isNull);
        expect(await testStorage.read(key: 'refresh_token'), isNull);
        expect(await testStorage.read(key: 'session_valid'), isNull);
      });

      test(
        'should throw StorageException when storing user data fails',
        () async {
          final userData = UserData(
            uid: 'test-uid',
            email: 'test@example.com',
            displayName: 'Test User',
            isAnonymous: false,
            createdAt: DateTime(2024),
          );

          testStorage.throwOnNextOperation();

          expect(
            () => storageService.storeUserData(userData),
            throwsA(isA<StorageException>()),
          );
        },
      );
    });

    group('Token Management', () {
      test('should store and retrieve auth token', () async {
        const token = 'test-auth-token';

        await storageService.storeAuthToken(token);
        final result = await storageService.getAuthToken();

        expect(result, token);
      });

      test('should store and retrieve refresh token', () async {
        const token = 'test-refresh-token';

        await storageService.storeRefreshToken(token);
        final result = await storageService.getRefreshToken();

        expect(result, token);
      });

      test('should return null for missing tokens', () async {
        final authToken = await storageService.getAuthToken();
        final refreshToken = await storageService.getRefreshToken();

        expect(authToken, isNull);
        expect(refreshToken, isNull);
      });

      test('should clear tokens successfully', () async {
        await testStorage.write(key: 'auth_token', value: 'auth');
        await testStorage.write(key: 'refresh_token', value: 'refresh');

        await storageService.clearTokens();

        expect(await testStorage.read(key: 'auth_token'), isNull);
        expect(await testStorage.read(key: 'refresh_token'), isNull);
      });

      test('should handle token read errors gracefully', () async {
        testStorage.throwOnNextOperation();
        final authToken = await storageService.getAuthToken();
        expect(authToken, isNull);

        testStorage.throwOnNextOperation();
        final refreshToken = await storageService.getRefreshToken();
        expect(refreshToken, isNull);
      });
    });

    group('Session Management', () {
      test('should check session validity', () async {
        await testStorage.write(key: 'session_valid', value: 'true');

        final isValid = await storageService.isSessionValid();

        expect(isValid, true);
      });

      test('should return false for invalid session', () async {
        await testStorage.write(key: 'session_valid', value: 'false');

        final isValid = await storageService.isSessionValid();

        expect(isValid, false);
      });

      test('should return false for missing session data', () async {
        final isValid = await storageService.isSessionValid();
        expect(isValid, false);
      });

      test('should invalidate session', () async {
        await storageService.invalidateSession();

        final sessionValid = await testStorage.read(key: 'session_valid');
        expect(sessionValid, 'false');
      });

      test('should handle session read errors gracefully', () async {
        testStorage.throwOnNextOperation();
        final isValid = await storageService.isSessionValid();
        expect(isValid, false);
      });
    });

    group('Utility Methods', () {
      test('should get all keys', () async {
        await testStorage.write(key: 'user_data', value: 'user_value');
        await testStorage.write(key: 'auth_token', value: 'token_value');

        final keys = await storageService.getAllKeys();

        expect(keys, containsAll(['user_data', 'auth_token']));
      });

      test('should handle readAll errors gracefully', () async {
        testStorage.throwOnNextOperation();

        final keys = await storageService.getAllKeys();

        expect(keys, isEmpty);
      });

      test('should clear all data', () async {
        await testStorage.write(key: 'test', value: 'value');

        await storageService.clearAll();

        final allData = await testStorage.readAll();
        expect(allData, isEmpty);
      });

      test('should throw StorageException when clear all fails', () async {
        testStorage.throwOnNextOperation();

        expect(
          () => storageService.clearAll(),
          throwsA(isA<StorageException>()),
        );
      });
    });
  });

  group('StorageException', () {
    test('should create with message', () {
      const exception = StorageException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.toString(), 'StorageException: Test error');
    });
  });
}
