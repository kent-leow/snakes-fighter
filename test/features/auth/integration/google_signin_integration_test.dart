import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snakes_fight/core/providers/auth_provider.dart';
import 'package:snakes_fight/core/services/auth_service.dart';
import 'package:snakes_fight/features/auth/presentation/auth_screen.dart';

import '../../../core/services/auth_service_test.mocks.dart';

void main() {
  group('Google Sign-In Integration Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late AuthService authService;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockSecureStorage = MockFlutterSecureStorage();
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        secureStorage: mockSecureStorage,
        googleSignIn: mockGoogleSignIn,
      );

      // Set up common mocks
      when(
        mockFirebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));
      when(mockFirebaseAuth.currentUser).thenReturn(null);
    });

    testWidgets('should complete Google Sign-In flow when button is tapped', (
      WidgetTester tester,
    ) async {
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
      when(mockUser.displayName).thenReturn('Test User');
      when(
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(authService)],
          child: MaterialApp(
            home: const AuthScreen(),
            routes: {
              '/': (context) =>
                  const Scaffold(body: Center(child: Text('Main Menu'))),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the Google Sign-In button
      final googleSignInButton = find.text('Sign in with Google');
      expect(googleSignInButton, findsOneWidget);

      await tester.tap(googleSignInButton);
      await tester.pump(); // Start loading state

      // Simulate authentication success by updating the stream
      when(
        mockFirebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await tester.pumpAndSettle();

      // Assert
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      verify(
        mockSecureStorage.write(key: 'user_id', value: 'google-uid'),
      ).called(1);
      verify(
        mockSecureStorage.write(key: 'is_anonymous', value: 'false'),
      ).called(1);
    });

    testWidgets('should handle Google Sign-In cancellation gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(authService)],
          child: const MaterialApp(home: AuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the Google Sign-In button
      final googleSignInButton = find.text('Sign in with Google');
      expect(googleSignInButton, findsOneWidget);

      await tester.tap(googleSignInButton);
      await tester.pumpAndSettle();

      // Assert - should still be on auth screen since sign-in was cancelled
      expect(find.byType(AuthScreen), findsOneWidget);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockFirebaseAuth.signInWithCredential(any));
    });

    testWidgets('should display error dialog on Google Sign-In failure', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockGoogleSignIn.signIn(),
      ).thenThrow(Exception('Google sign-in failed'));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(authService)],
          child: const MaterialApp(home: AuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the Google Sign-In button
      final googleSignInButton = find.text('Sign in with Google');
      expect(googleSignInButton, findsOneWidget);

      await tester.tap(googleSignInButton);
      await tester.pumpAndSettle();

      // Assert - should show error dialog
      expect(find.text('Authentication Error'), findsOneWidget);
      expect(find.textContaining('Google sign-in failed'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockFirebaseAuth.signInWithCredential(any));
    });

    testWidgets('should show loading state during Google Sign-In', (
      WidgetTester tester,
    ) async {
      // Arrange - create a completer to control the timing
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
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(authService)],
          child: const MaterialApp(home: AuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the Google Sign-In button
      final googleSignInButton = find.text('Sign in with Google');
      expect(googleSignInButton, findsOneWidget);

      await tester.tap(googleSignInButton);
      await tester.pump(); // Only pump once to catch loading state

      // Assert - should show loading state
      expect(find.text('Signing In...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the sign-in
      await tester.pumpAndSettle();
    });
  });
}
