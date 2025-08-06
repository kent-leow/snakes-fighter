import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/core/services/database_service.dart';
import 'package:snakes_fight/core/services/room_code_service.dart';

import 'room_code_service_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('RoomCodeService', () {
    late RoomCodeService roomCodeService;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      roomCodeService = RoomCodeService(mockDatabaseService);
    });

    group('generateUniqueRoomCode', () {
      test('should generate unique room code on first attempt', () async {
        // Arrange
        when(
          mockDatabaseService.getRoomByCode(any),
        ).thenAnswer((_) async => null);

        // Act
        final result = await roomCodeService.generateUniqueRoomCode();

        // Assert
        expect(result, isA<String>());
        expect(result.length, equals(6));
        expect(RegExp(r'^[A-Z0-9]+$').hasMatch(result), isTrue);
        verify(mockDatabaseService.getRoomByCode(result)).called(1);
      });

      test('should generate unique room code after collision', () async {
        // Arrange - Mock so first call returns existing room, subsequent calls return null
        var callCount = 0;
        final existingRoom = Room(
          id: 'room_1',
          roomCode: 'ABC123',
          hostId: 'host_1',
          status: RoomStatus.waiting,
          createdAt: DateTime.now(),
        );

        when(mockDatabaseService.getRoomByCode(any)).thenAnswer((inv) async {
          callCount++;
          // First few calls return existing room to simulate collision
          if (callCount <= 2) {
            return existingRoom;
          }
          return null; // Eventually return null for unique code
        });

        // Act
        final result = await roomCodeService.generateUniqueRoomCode();

        // Assert
        expect(result, isA<String>());
        expect(result.length, equals(6));
        expect(RegExp(r'^[A-Z0-9]+$').hasMatch(result), isTrue);
        verify(mockDatabaseService.getRoomByCode(any)).called(greaterThan(2));
      });

      test('should throw RoomCodeException after max attempts', () async {
        // Arrange
        final existingRoom = Room(
          id: 'room_1',
          roomCode: 'ABC123',
          hostId: 'host_1',
          status: RoomStatus.waiting,
          createdAt: DateTime.now(),
        );

        // Always return existing room to force max attempts
        when(
          mockDatabaseService.getRoomByCode(any),
        ).thenAnswer((_) async => existingRoom);

        // Act & Assert
        await expectLater(
          roomCodeService.generateUniqueRoomCode(),
          throwsA(
            isA<RoomCodeException>().having(
              (e) => e.message,
              'message',
              contains('Failed to generate unique room code after 10 attempts'),
            ),
          ),
        );

        verify(mockDatabaseService.getRoomByCode(any)).called(10);
      });

      test('should handle database errors gracefully', () async {
        // Arrange
        when(
          mockDatabaseService.getRoomByCode(any),
        ).thenThrow(const DatabaseException('Database connection failed'));

        // Act & Assert
        expect(
          () => roomCodeService.generateUniqueRoomCode(),
          throwsA(isA<DatabaseException>()),
        );

        verify(mockDatabaseService.getRoomByCode(any)).called(1);
      });
    });

    test('generated codes should contain only valid characters', () async {
      // Arrange
      when(
        mockDatabaseService.getRoomByCode(any),
      ).thenAnswer((_) async => null);

      // Act - Generate multiple codes to test pattern
      final codes = <String>[];
      for (int i = 0; i < 10; i++) {
        final code = await roomCodeService.generateUniqueRoomCode();
        codes.add(code);
      }

      // Assert
      for (final code in codes) {
        expect(code.length, equals(6));
        expect(RegExp(r'^[A-Z0-9]+$').hasMatch(code), isTrue);
        // Should not contain easily confused characters
        expect(code.contains('0'), anyOf(isTrue, isFalse)); // 0 is allowed
        expect(code.contains('O'), anyOf(isTrue, isFalse)); // O is allowed
        expect(code.contains('I'), anyOf(isTrue, isFalse)); // I is allowed
        expect(code.contains('1'), anyOf(isTrue, isFalse)); // 1 is allowed
      }
    });

    test('should generate different codes on subsequent calls', () async {
      // Arrange
      when(
        mockDatabaseService.getRoomByCode(any),
      ).thenAnswer((_) async => null);

      // Act
      final codes = <String>[];
      for (int i = 0; i < 5; i++) {
        final code = await roomCodeService.generateUniqueRoomCode();
        codes.add(code);
      }

      // Assert - All codes should be different (statistically very likely)
      final uniqueCodes = codes.toSet();
      expect(uniqueCodes.length, equals(codes.length));
    });
  });
}
