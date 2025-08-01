import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snakes_fight/core/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  FlutterSecureStorage,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockGoogleSignIn mockGoogleSignIn;
    late AuthService authService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockSecureStorage = MockFlutterSecureStorage();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        secureStorage: mockSecureStorage,
        googleSignIn: mockGoogleSignIn,
      );
    });

    group('signInAnonymously', () {
      test('should return UserCredential on successful sign in', () async {
        // Arrange
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.isAnonymous).thenReturn(true);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.signInAnonymously(),
        ).thenAnswer((_) async => mockUserCredential);
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await authService.signInAnonymously();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.signInAnonymously()).called(1);
        verify(
          mockSecureStorage.write(key: 'user_id', value: 'test-uid'),
        ).called(1);
        verify(
          mockSecureStorage.write(key: 'is_anonymous', value: 'true'),
        ).called(1);
      });

      test('should throw AuthException on FirebaseAuthException', () async {
        // Arrange
        when(mockFirebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(code: 'unknown', message: 'Test error'),
        );

        // Act & Assert
        expect(
          () => authService.signInAnonymously(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Anonymous sign-in failed: Test error'),
            ),
          ),
        );
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(
          mockSecureStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockSecureStorage.delete(key: 'user_id')).called(1);
        verify(mockSecureStorage.delete(key: 'is_anonymous')).called(1);
      });

      test(
        'should sign out from Google when user is signed in with Google',
        () async {
          // Arrange
          final mockProviderData = <UserInfo>[];
          when(mockUser.providerData).thenReturn(mockProviderData);
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
          when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
          when(
            mockSecureStorage.delete(key: anyNamed('key')),
          ).thenAnswer((_) async {});

          // Act
          await authService.signOut();

          // Assert
          verify(mockFirebaseAuth.signOut()).called(1);
          verify(mockSecureStorage.delete(key: 'user_id')).called(1);
          verify(mockSecureStorage.delete(key: 'is_anonymous')).called(1);
        },
      );

      test('should throw AuthException on FirebaseAuthException', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        when(mockFirebaseAuth.signOut()).thenThrow(
          FirebaseAuthException(code: 'unknown', message: 'Sign out error'),
        );

        // Act & Assert
        expect(
          () => authService.signOut(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Sign out failed: Sign out error'),
            ),
          ),
        );
      });
    });

    group('currentUser', () {
      test('should return current user from Firebase Auth', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = authService.currentUser;

        // Assert
        expect(result, equals(mockUser));
      });
    });

    group('authStateChanges', () {
      test('should return auth state changes stream from Firebase Auth', () {
        // Arrange
        final stream = Stream<User?>.fromIterable([null, mockUser]);
        when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => stream);

        // Act
        final result = authService.authStateChanges;

        // Assert
        expect(result, equals(stream));
      });
    });

    group('isSignedIn', () {
      test('should return true when user is signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = authService.isSignedIn;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when user is not signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = authService.isSignedIn;

        // Assert
        expect(result, isFalse);
      });
    });

    group('isAnonymous', () {
      test('should return true when user is anonymous', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);

        // Act
        final result = authService.isAnonymous;

        // Assert
        expect(result, isTrue);
      });

      test('should return false when user is not anonymous', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);

        // Act
        final result = authService.isAnonymous;

        // Assert
        expect(result, isFalse);
      });

      test('should return false when no user is signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = authService.isAnonymous;

        // Assert
        expect(result, isFalse);
      });
    });

    group('userDisplayName', () {
      test('should return Guest when no user is signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = authService.userDisplayName;

        // Assert
        expect(result, equals('Guest'));
      });

      test('should return Player [shortId] for anonymous user', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);
        when(mockUser.uid).thenReturn('test-uid-123');

        // Act
        final result = authService.userDisplayName;

        // Assert
        expect(result, equals('Player test-u'));
      });

      test('should return display name for non-anonymous user', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);
        when(mockUser.displayName).thenReturn('John Doe');

        // Act
        final result = authService.userDisplayName;

        // Assert
        expect(result, equals('John Doe'));
      });

      test('should return email when display name is null', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.email).thenReturn('test@example.com');

        // Act
        final result = authService.userDisplayName;

        // Assert
        expect(result, equals('test@example.com'));
      });

      test(
        'should return Unknown User when both display name and email are null',
        () {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.isAnonymous).thenReturn(false);
          when(mockUser.displayName).thenReturn(null);
          when(mockUser.email).thenReturn(null);

          // Act
          final result = authService.userDisplayName;

          // Assert
          expect(result, equals('Unknown User'));
        },
      );
    });

    group('deleteAnonymousUser', () {
      test('should delete anonymous user successfully', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);
        when(mockUser.delete()).thenAnswer((_) async {});
        when(
          mockSecureStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async {});

        // Act
        await authService.deleteAnonymousUser();

        // Assert
        verify(mockUser.delete()).called(1);
        verify(mockSecureStorage.delete(key: 'user_id')).called(1);
        verify(mockSecureStorage.delete(key: 'is_anonymous')).called(1);
      });

      test('should throw AuthException when no user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => authService.deleteAnonymousUser(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              equals('No anonymous user to delete'),
            ),
          ),
        );
      });

      test('should throw AuthException when user is not anonymous', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);

        // Act & Assert
        expect(
          () => authService.deleteAnonymousUser(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              equals('No anonymous user to delete'),
            ),
          ),
        );
      });
    });

    group('secure storage operations', () {
      test('getStoredUserId should return stored user ID', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'user_id'),
        ).thenAnswer((_) async => 'test-uid');

        // Act
        final result = await authService.getStoredUserId();

        // Assert
        expect(result, equals('test-uid'));
      });

      test('getStoredUserId should return null on error', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'user_id'),
        ).thenThrow(Exception('Storage error'));

        // Act
        final result = await authService.getStoredUserId();

        // Assert
        expect(result, isNull);
      });

      test(
        'getStoredAnonymousStatus should return stored anonymous status',
        () async {
          // Arrange
          when(
            mockSecureStorage.read(key: 'is_anonymous'),
          ).thenAnswer((_) async => 'true');

          // Act
          final result = await authService.getStoredAnonymousStatus();

          // Assert
          expect(result, isTrue);
        },
      );

      test('getStoredAnonymousStatus should return false on error', () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'is_anonymous'),
        ).thenThrow(Exception('Storage error'));

        // Act
        final result = await authService.getStoredAnonymousStatus();

        // Assert
        expect(result, isFalse);
      });
    });

    group('signInWithGoogle', () {
      test(
        'should return UserCredential on successful Google sign in',
        () async {
          // Arrange
          when(
            mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleSignInAccount);
          when(
            mockGoogleSignInAccount.authentication,
          ).thenAnswer((_) async => mockGoogleSignInAuthentication);
          when(
            mockGoogleSignInAuthentication.accessToken,
          ).thenReturn('access_token');
          when(mockGoogleSignInAuthentication.idToken).thenReturn('id_token');
          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => mockUserCredential);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('google-uid');
          when(mockUser.isAnonymous).thenReturn(false);
          when(
            mockSecureStorage.write(
              key: anyNamed('key'),
              value: anyNamed('value'),
            ),
          ).thenAnswer((_) async {});

          // Act
          final result = await authService.signInWithGoogle();

          // Assert
          expect(result, equals(mockUserCredential));
          verify(mockGoogleSignIn.signIn()).called(1);
          verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
          verify(
            mockSecureStorage.write(key: 'user_id', value: 'google-uid'),
          ).called(1);
          verify(
            mockSecureStorage.write(key: 'is_anonymous', value: 'false'),
          ).called(1);
        },
      );

      test('should return null when user cancels Google sign in', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isNull);
        verify(mockGoogleSignIn.signIn()).called(1);
        verifyNever(mockFirebaseAuth.signInWithCredential(any));
      });

      test('should throw AuthException on Google sign-in failure', () async {
        // Arrange
        when(
          mockGoogleSignIn.signIn(),
        ).thenThrow(Exception('Google sign-in failed'));

        // Act & Assert
        expect(
          () => authService.signInWithGoogle(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Google sign-in failed'),
            ),
          ),
        );
      });
    });

    group('linkAnonymousWithGoogle', () {
      test('should link anonymous account with Google successfully', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);
        when(
          mockGoogleSignIn.signIn(),
        ).thenAnswer((_) async => mockGoogleSignInAccount);
        when(
          mockGoogleSignInAccount.authentication,
        ).thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(
          mockGoogleSignInAuthentication.accessToken,
        ).thenReturn('access_token');
        when(mockGoogleSignInAuthentication.idToken).thenReturn('id_token');
        when(
          mockUser.linkWithCredential(any),
        ).thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('linked-uid');
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await authService.linkAnonymousWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockUser.linkWithCredential(any)).called(1);
        verify(
          mockSecureStorage.write(key: 'user_id', value: 'linked-uid'),
        ).called(1);
      });

      test(
        'should throw AuthException when no anonymous user exists',
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(null);

          // Act & Assert
          expect(
            () => authService.linkAnonymousWithGoogle(),
            throwsA(
              isA<AuthException>().having(
                (e) => e.message,
                'message',
                'No anonymous user to link',
              ),
            ),
          );
        },
      );

      test('should throw AuthException when user is not anonymous', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);

        // Act & Assert
        expect(
          () => authService.linkAnonymousWithGoogle(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'No anonymous user to link',
            ),
          ),
        );
      });

      test(
        'should return null when user cancels Google sign in during linking',
        () async {
          // Arrange
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.isAnonymous).thenReturn(true);
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

          // Act
          final result = await authService.linkAnonymousWithGoogle();

          // Assert
          expect(result, isNull);
          verify(mockGoogleSignIn.signIn()).called(1);
          verifyNever(mockUser.linkWithCredential(any));
        },
      );
    });
  });
}
