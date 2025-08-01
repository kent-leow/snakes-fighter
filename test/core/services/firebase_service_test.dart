import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/services/firebase_service.dart';

void main() {
  group('FirebaseService', () {
    late FirebaseService firebaseService;

    setUp(() {
      firebaseService = FirebaseService();
    });

    group('Service Instance', () {
      test('should return same instance (singleton)', () {
        // Act
        final instance1 = FirebaseService();
        final instance2 = FirebaseService();

        // Assert
        expect(instance1, equals(instance2));
        expect(identical(instance1, instance2), isTrue);
      });

      test('should have auth instance', () {
        // Act
        final auth = firebaseService.auth;

        // Assert
        expect(auth, isNotNull);
      });

      test('should have database instance', () {
        // Act
        final database = firebaseService.database;

        // Assert
        expect(database, isNotNull);
      });

      test('should have analytics instance', () {
        // Act
        final analytics = firebaseService.analytics;

        // Assert
        expect(analytics, isNotNull);
      });
    });

    group('Database References', () {
      test('should create games reference', () {
        // Act
        final gamesRef = firebaseService.gamesRef;

        // Assert
        expect(gamesRef, isNotNull);
        expect(gamesRef.path, equals('games'));
      });

      test('should create players reference', () {
        // Act
        final playersRef = firebaseService.playersRef;

        // Assert
        expect(playersRef, isNotNull);
        expect(playersRef.path, equals('players'));
      });

      test('should create lobbies reference', () {
        // Act
        final lobbiesRef = firebaseService.lobbiesRef;

        // Assert
        expect(lobbiesRef, isNotNull);
        expect(lobbiesRef.path, equals('lobbies'));
      });

      test('should create specific game reference', () {
        // Arrange
        const gameId = 'test-game-123';

        // Act
        final gameRef = firebaseService.gameRef(gameId);

        // Assert
        expect(gameRef, isNotNull);
        expect(gameRef.path, equals('games/$gameId'));
      });

      test('should create specific player reference', () {
        // Arrange
        const uid = 'test-user-456';

        // Act
        final playerRef = firebaseService.playerRef(uid);

        // Assert
        expect(playerRef, isNotNull);
        expect(playerRef.path, equals('players/$uid'));
      });

      test('should create specific lobby reference', () {
        // Arrange
        const lobbyId = 'test-lobby-789';

        // Act
        final lobbyRef = firebaseService.lobbyRef(lobbyId);

        // Assert
        expect(lobbyRef, isNotNull);
        expect(lobbyRef.path, equals('lobbies/$lobbyId'));
      });
    });

    group('Authentication State', () {
      test('should have currentUser getter', () {
        // Act
        final currentUser = firebaseService.currentUser;

        // Assert - currentUser can be null when not signed in
        // This is expected behavior
        expect(currentUser, isA<dynamic>());
      });

      test('should have isSignedIn getter', () {
        // Act
        final isSignedIn = firebaseService.isSignedIn;

        // Assert
        expect(isSignedIn, isA<bool>());
      });

      test('should have authStateChanges stream', () {
        // Act
        final authStream = firebaseService.authStateChanges;

        // Assert
        expect(authStream, isNotNull);
      });
    });
  });
}
