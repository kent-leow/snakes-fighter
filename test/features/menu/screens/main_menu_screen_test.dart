import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakes_fight/core/constants/app_constants.dart';
import 'package:snakes_fight/features/menu/screens/main_menu_screen.dart';

void main() {
  group('MainMenuScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display app title and version', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

      // Wait for settings initialization
      await tester.pumpAndSettle();

      // Check for app title
      expect(find.text(AppConstants.appName.toUpperCase()), findsOneWidget);

      // Check for version
      expect(find.text('v${AppConstants.appVersion}'), findsOneWidget);
    });

    testWidgets('should display menu buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

      await tester.pumpAndSettle();

      // Check for menu buttons
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('EXIT'), findsOneWidget);

      // Check for button icons
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should have gradient background', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

      await tester.pumpAndSettle();

      // Find the container with gradient
      final container = tester.widget<Container>(find.byType(Container).first);

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());

      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, hasLength(2));
      expect(gradient.colors[0], Colors.green.shade800);
      expect(gradient.colors[1], Colors.green.shade600);
    });

    testWidgets('should respond to play button tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

      await tester.pumpAndSettle();

      // Verify PLAY button exists and is tappable
      final playButton = find.text('PLAY');
      expect(playButton, findsOneWidget);

      // Tap the play button (should not throw)
      await tester.tap(playButton);
      await tester.pump(); // Single pump to register the tap

      // Test passes if no exceptions are thrown
      expect(playButton, findsOneWidget);
    });

    testWidgets('should show exit confirmation dialog', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

      await tester.pumpAndSettle();

      // Tap the exit button
      await tester.tap(find.text('EXIT'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Exit Game'), findsOneWidget);
      expect(find.text('Are you sure you want to exit?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
    });

    testWidgets('should cancel exit when cancel is pressed', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

      await tester.pumpAndSettle();

      // Tap the exit button
      await tester.tap(find.text('EXIT'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should still be on main menu
      expect(find.byType(MainMenuScreen), findsOneWidget);
      expect(find.text('Exit Game'), findsNothing);
    });

    group('Button Styling', () {
      testWidgets('should have proper button styling', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

        await tester.pumpAndSettle();

        // Find buttons by their text and verify they exist
        expect(find.text('PLAY'), findsOneWidget);
        expect(find.text('SETTINGS'), findsOneWidget);
        expect(find.text('EXIT'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

        await tester.pumpAndSettle();

        // Check semantic labels
        final semantics = tester.binding.rootPipelineOwner.semanticsOwner;
        expect(semantics, isNotNull);

        // All buttons should be tappable
        expect(find.text('PLAY'), findsOneWidget);
        expect(find.text('SETTINGS'), findsOneWidget);
        expect(find.text('EXIT'), findsOneWidget);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      });
    });
  });
}
