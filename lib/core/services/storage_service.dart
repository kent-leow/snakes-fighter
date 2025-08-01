import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';

/// Service for secure storage of authentication tokens and user data
class StorageService {
  StorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  // Storage keys
  static const String _userDataKey = 'user_data';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionValidKey = 'session_valid';

  /// Store user data securely
  Future<void> storeUserData(UserData userData) async {
    try {
      final userDataJson = jsonEncode(userData.toJson());
      await _secureStorage.write(key: _userDataKey, value: userDataJson);

      // Mark session as valid
      await _secureStorage.write(key: _sessionValidKey, value: 'true');
    } catch (e) {
      throw StorageException('Failed to store user data: $e');
    }
  }

  /// Retrieve stored user data
  Future<UserData?> getUserData() async {
    try {
      final userDataJson = await _secureStorage.read(key: _userDataKey);
      if (userDataJson == null) return null;

      final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
      return UserData.fromJson(userDataMap);
    } catch (e) {
      // If there's an error reading, clear corrupted data
      await clearUserData();
      return null;
    }
  }

  /// Store authentication token
  Future<void> storeAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
    } catch (e) {
      throw StorageException('Failed to store auth token: $e');
    }
  }

  /// Retrieve authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw StorageException('Failed to store refresh token: $e');
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      final sessionValid = await _secureStorage.read(key: _sessionValidKey);
      return sessionValid == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Clear all user data and tokens
  Future<void> clearUserData() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _userDataKey),
        _secureStorage.delete(key: _authTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _sessionValidKey),
      ]);
    } catch (e) {
      throw StorageException('Failed to clear user data: $e');
    }
  }

  /// Clear only authentication tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _authTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);
    } catch (e) {
      throw StorageException('Failed to clear tokens: $e');
    }
  }

  /// Invalidate session
  Future<void> invalidateSession() async {
    try {
      await _secureStorage.write(key: _sessionValidKey, value: 'false');
    } catch (e) {
      throw StorageException('Failed to invalidate session: $e');
    }
  }

  /// Get all stored keys (useful for debugging)
  Future<Set<String>> getAllKeys() async {
    try {
      final allData = await _secureStorage.readAll();
      return allData.keys.toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Clear all stored data (use with caution)
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }
}

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => 'StorageException: $message';
}
