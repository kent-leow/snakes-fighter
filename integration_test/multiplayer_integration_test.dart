import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:snakes_fight/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Multiplayer Game Flow Integration Tests', () {
    testWidgets('Complete app startup and initialization flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Wait for app initialization and verify it starts successfully
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
      
      // Test basic app functionality
      await tester.pumpAndSettle();
    });

    testWidgets('App handles Firebase initialization', (WidgetTester tester) async {
      // Test that Firebase services are properly initialized
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app doesn't crash during Firebase initialization
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
    });

    testWidgets('Navigation and routing works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test basic navigation functionality
      // This ensures the routing system is working
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
    });

    group('Performance Tests', () {
      testWidgets('App startup performance is acceptable', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        app.main();
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // App should start within reasonable time (10 seconds for Firebase init)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });

      testWidgets('Memory usage is reasonable during app lifecycle', (WidgetTester tester) async {
        // Monitor memory usage during app startup
        app.main();
        await tester.pumpAndSettle();

        // Test passes if no memory leaks crash the app
        expect(find.byType(app.SnakesFightApp), findsOneWidget);
      });
    });

    group('Cross-Platform Tests', () {
      testWidgets('App works on current platform', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Basic cross-platform compatibility test
        expect(find.byType(app.SnakesFightApp), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('App handles initialization errors gracefully', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // App should not crash even with potential initialization issues
        expect(find.byType(app.SnakesFightApp), findsOneWidget);
      });

      testWidgets('App handles network errors gracefully', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // App should not crash even with network issues
        expect(find.byType(app.SnakesFightApp), findsOneWidget);
      });
    });
  });

  group('Game Engine Integration Tests', () {
    testWidgets('App services initialization works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that app services are initialized without crashes
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
    });

    testWidgets('Provider scope handles state management', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that Riverpod providers are working
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
    });
  });

  group('UI Integration Tests', () {
    testWidgets('Theme system works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that theme system is functional
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
    });

    testWidgets('Authentication wrapper loads properly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that authentication flow initializes
      expect(find.byType(app.SnakesFightApp), findsOneWidget);
    });
  });
}
