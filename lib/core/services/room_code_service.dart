import 'dart:math';

import 'database_service.dart';

/// Exception thrown when room code generation fails.
class RoomCodeException implements Exception {
  const RoomCodeException(this.message);

  final String message;

  @override
  String toString() => 'RoomCodeException: $message';
}

/// Service for generating unique room codes.
class RoomCodeService {
  RoomCodeService(this._databaseService);

  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _codeLength = 6;
  static const int _maxAttempts = 10;

  final DatabaseService _databaseService;
  final Random _random = Random.secure();

  /// Generates a unique room code.
  ///
  /// Throws [RoomCodeException] if unable to generate unique code after max attempts.
  Future<String> generateUniqueRoomCode() async {
    int attempts = 0;

    while (attempts < _maxAttempts) {
      final code = _generateCode();

      // Check if code is already in use
      final existingRoom = await _databaseService.getRoomByCode(code);
      if (existingRoom == null) {
        return code;
      }

      attempts++;
    }

    throw const RoomCodeException(
      'Failed to generate unique room code after $_maxAttempts attempts',
    );
  }

  /// Generates a random room code.
  String _generateCode() {
    return List.generate(_codeLength, (index) {
      return _chars[_random.nextInt(_chars.length)];
    }).join();
  }
}
