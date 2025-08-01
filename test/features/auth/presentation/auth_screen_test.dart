import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snakes_fight/core/providers/auth_provider.dart';
import 'package:snakes_fight/core/services/auth_service.dart';
import 'package:snakes_fight/features/auth/presentation/auth_screen.dart';

import '../../../core/services/auth_service_test.mocks.dart';

void main() {
  group('AuthScreen', () {
    testWidgets('should display auth screen elements', (WidgetTester tester) async {
      // Arrange
      final mockFirebaseAuth = MockFirebaseAuth();
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
      
      final testAuthService = AuthService(firebaseAuth: mockFirebaseAuth);

      // Act
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(testAuthService),
        ],
        child: const MaterialApp(home: AuthScreen()),
      ));
      await tester.pump();

      // Assert
      expect(find.text('Welcome to Snakes Fight!'), findsOneWidget);
      expect(find.text('Play as Guest'), findsOneWidget);
      expect(find.text('Sign in with Google (Coming Soon)'), findsOneWidget);
      expect(find.byIcon(Icons.videogame_asset), findsOneWidget);
    });

    testWidgets('should display anonymous user info', (WidgetTester tester) async {
      // Arrange
      final mockFirebaseAuth = MockFirebaseAuth();
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
      
      final testAuthService = AuthService(firebaseAuth: mockFirebaseAuth);

      // Act
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(testAuthService),
        ],
        child: const MaterialApp(home: AuthScreen()),
      ));
      await tester.pump();

      // Assert - should show anonymous user information
      expect(
        find.text('Anonymous sessions are temporary. Progress will be lost if you uninstall the app.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
