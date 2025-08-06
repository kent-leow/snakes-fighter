import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/core/services/auth_service.dart';
import 'package:snakes_fight/core/services/database_service.dart';
import 'package:snakes_fight/core/services/room_code_service.dart';
import 'package:snakes_fight/features/room/services/room_service.dart';
import 'room_creation_integration_test.mocks.dart';

@GenerateMocks([DatabaseService, AuthService])
class MockFirebaseUser extends Mock implements firebase_auth.User {
  @override
  String get uid => 'test-uid';

  @override
  String? get displayName => 'Test User';
}

void main() {
  group('Room Creation Integration', () {
    late MockDatabaseService mockDatabaseService;
    late MockAuthService mockAuthService;
    late RoomCodeService roomCodeService;
    late RoomService roomService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockAuthService = MockAuthService();
      roomCodeService = RoomCodeService(mockDatabaseService);
      roomService = RoomService(
        mockDatabaseService,
        mockAuthService,
        roomCodeService,
      );
    });

    test('should complete full room creation flow', () async {
      // Arrange
      final mockUser = MockFirebaseUser();

      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(
        mockDatabaseService.getRoomByCode(any),
      ).thenAnswer((_) async => null);
      when(mockDatabaseService.createRoom(any)).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Room,
      );

      // Act
      final room = await roomService.createRoom();

      // Assert
      expect(room.hostId, equals('test-uid'));
      expect(room.maxPlayers, equals(4));
      expect(room.status, equals(RoomStatus.waiting));
      expect(room.roomCode.length, equals(6));
      expect(room.players.length, equals(1));
      expect(room.players['test-uid']?.displayName, equals('Test User'));
      expect(room.players['test-uid']?.isConnected, isTrue);
      expect(room.players['test-uid']?.isReady, isFalse);
      expect(room.players['test-uid']?.color, equals(PlayerColor.red));

      // Verify interactions
      verify(mockAuthService.currentUser).called(1);
      verify(mockDatabaseService.getRoomByCode(room.roomCode)).called(1);
      verify(mockDatabaseService.createRoom(any)).called(1);
    });

    test('should handle room code collision and retry', () async {
      // Arrange
      final mockUser = MockFirebaseUser();
      final existingRoom = Room(
        id: 'existing-room',
        roomCode: 'EXIST1',
        hostId: 'other-user',
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
      );

      var callCount = 0;
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockDatabaseService.getRoomByCode(any)).thenAnswer((
        invocation,
      ) async {
        callCount++;
        // First call returns existing room, subsequent calls return null
        if (callCount == 1) {
          return existingRoom;
        }
        return null;
      });
      when(mockDatabaseService.createRoom(any)).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Room,
      );

      // Act
      final room = await roomService.createRoom();

      // Assert
      expect(room.roomCode, isNot(equals('EXIST1')));
      expect(room.hostId, equals('test-uid'));

      // Verify retries happened
      verify(mockDatabaseService.getRoomByCode(any)).called(2);
      verify(mockDatabaseService.createRoom(any)).called(1);
    });

    test('should assign available player colors', () async {
      // Arrange
      final mockUser = MockFirebaseUser();

      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(
        mockDatabaseService.getRoomByCode(any),
      ).thenAnswer((_) async => null);
      when(mockDatabaseService.createRoom(any)).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Room,
      );

      // Act
      final room = await roomService.createRoom();

      // Assert
      final hostPlayer = room.players['test-uid'];
      expect(
        hostPlayer?.color,
        equals(PlayerColor.red),
      ); // First available color
    });
  });
}
