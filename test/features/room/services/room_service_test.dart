import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/core/services/auth_service.dart';
import 'package:snakes_fight/core/services/database_service.dart';
import 'package:snakes_fight/core/services/room_code_service.dart';
import 'package:snakes_fight/features/room/services/room_service.dart';

import 'room_service_test.mocks.dart';

@GenerateMocks([DatabaseService, AuthService, RoomCodeService])
class MockFirebaseUser extends Mock implements firebase_auth.User {
  @override
  String get uid => 'test-uid';

  @override
  String? get displayName => 'Test User';
}

void main() {
  group('RoomService', () {
    late RoomService roomService;
    late MockDatabaseService mockDatabaseService;
    late MockAuthService mockAuthService;
    late MockRoomCodeService mockRoomCodeService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockAuthService = MockAuthService();
      mockRoomCodeService = MockRoomCodeService();

      roomService = RoomService(
        mockDatabaseService,
        mockAuthService,
        mockRoomCodeService,
      );
    });

    group('createRoom', () {
      test(
        'should create room successfully with default max players',
        () async {
          // Arrange
          final mockUser = MockFirebaseUser();
          const roomCode = 'ABC123';

          when(mockAuthService.currentUser).thenReturn(mockUser);
          when(
            mockRoomCodeService.generateUniqueRoomCode(),
          ).thenAnswer((_) async => roomCode);
          when(mockDatabaseService.createRoom(any)).thenAnswer(
            (invocation) async => invocation.positionalArguments[0] as Room,
          );

          // Act
          final result = await roomService.createRoom();

          // Assert
          expect(result.roomCode, equals(roomCode));
          expect(result.hostId, equals('test-uid'));
          expect(result.maxPlayers, equals(4));
          expect(result.status, equals(RoomStatus.waiting));
          expect(result.players.length, equals(1));
          expect(result.players['test-uid']?.displayName, equals('Test User'));
          expect(result.players['test-uid']?.isConnected, isTrue);
          expect(result.players['test-uid']?.isReady, isFalse);

          verify(mockAuthService.currentUser).called(1);
          verify(mockRoomCodeService.generateUniqueRoomCode()).called(1);
          verify(mockDatabaseService.createRoom(any)).called(1);
        },
      );

      test('should create room successfully with custom max players', () async {
        // Arrange
        final mockUser = MockFirebaseUser();
        const roomCode = 'ABC123';
        const maxPlayers = 6;

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(
          mockRoomCodeService.generateUniqueRoomCode(),
        ).thenAnswer((_) async => roomCode);
        when(mockDatabaseService.createRoom(any)).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Room,
        );

        // Act
        final result = await roomService.createRoom(maxPlayers: maxPlayers);

        // Assert
        expect(result.maxPlayers, equals(maxPlayers));
      });

      test('should throw RoomException if user is not authenticated', () async {
        // Arrange
        when(mockAuthService.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => roomService.createRoom(),
          throwsA(
            isA<RoomException>().having(
              (e) => e.message,
              'message',
              'User must be authenticated to create room',
            ),
          ),
        );

        verify(mockAuthService.currentUser).called(1);
        verifyNever(mockRoomCodeService.generateUniqueRoomCode());
        verifyNever(mockDatabaseService.createRoom(any));
      });

      test('should throw RoomException if maxPlayers is too low', () async {
        // Arrange
        final mockUser = MockFirebaseUser();
        when(mockAuthService.currentUser).thenReturn(mockUser);

        // Act & Assert
        expect(
          () => roomService.createRoom(maxPlayers: 1),
          throwsA(
            isA<RoomException>().having(
              (e) => e.message,
              'message',
              'Max players must be between 2 and 8',
            ),
          ),
        );

        verify(mockAuthService.currentUser).called(1);
        verifyNever(mockRoomCodeService.generateUniqueRoomCode());
        verifyNever(mockDatabaseService.createRoom(any));
      });

      test('should throw RoomException if maxPlayers is too high', () async {
        // Arrange
        final mockUser = MockFirebaseUser();
        when(mockAuthService.currentUser).thenReturn(mockUser);

        // Act & Assert
        expect(
          () => roomService.createRoom(maxPlayers: 9),
          throwsA(
            isA<RoomException>().having(
              (e) => e.message,
              'message',
              'Max players must be between 2 and 8',
            ),
          ),
        );

        verify(mockAuthService.currentUser).called(1);
        verifyNever(mockRoomCodeService.generateUniqueRoomCode());
        verifyNever(mockDatabaseService.createRoom(any));
      });

      test(
        'should throw RoomException if room code generation fails',
        () async {
          // Arrange
          final mockUser = MockFirebaseUser();

          when(mockAuthService.currentUser).thenReturn(mockUser);
          when(mockRoomCodeService.generateUniqueRoomCode()).thenThrow(
            const RoomCodeException('Failed to generate unique code'),
          );

          // Act & Assert
          await expectLater(
            roomService.createRoom(),
            throwsA(isA<RoomException>()),
          );

          verify(mockAuthService.currentUser).called(1);
          verify(mockRoomCodeService.generateUniqueRoomCode()).called(1);
          verifyNever(mockDatabaseService.createRoom(any));
        },
      );

      test('should throw RoomException if database creation fails', () async {
        // Arrange
        final mockUser = MockFirebaseUser();
        const roomCode = 'ABC123';

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(
          mockRoomCodeService.generateUniqueRoomCode(),
        ).thenAnswer((_) async => roomCode);
        when(
          mockDatabaseService.createRoom(any),
        ).thenThrow(const DatabaseException('Database error'));

        // Act & Assert
        await expectLater(
          roomService.createRoom(),
          throwsA(
            isA<RoomException>().having(
              (e) => e.message,
              'message',
              'Failed to create room: DatabaseException: Database error',
            ),
          ),
        );

        verify(mockAuthService.currentUser).called(1);
        verify(mockRoomCodeService.generateUniqueRoomCode()).called(1);
        verify(mockDatabaseService.createRoom(any)).called(1);
      });

      test('should handle user with null displayName', () async {
        // Arrange
        final mockUser = MockFirebaseUserWithNullName();
        const roomCode = 'ABC123';

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(
          mockRoomCodeService.generateUniqueRoomCode(),
        ).thenAnswer((_) async => roomCode);
        when(mockDatabaseService.createRoom(any)).thenAnswer(
          (invocation) async => invocation.positionalArguments[0] as Room,
        );

        // Act
        final result = await roomService.createRoom();

        // Assert
        expect(result.players['test-uid']?.displayName, equals('Anonymous'));
      });
    });
  });
}

class MockFirebaseUserWithNullName extends Mock implements firebase_auth.User {
  @override
  String get uid => 'test-uid';

  @override
  String? get displayName => null;
}
