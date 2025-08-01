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
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );
      
      // Wait for settings initialization
      await tester.pumpAndSettle();
      
      // Check for app title
      expect(
        find.text(AppConstants.appName.toUpperCase()),
        findsOneWidget,
      );
      
      // Check for version
      expect(
        find.text('v${AppConstants.appVersion}'),
        findsOneWidget,
      );
    });
    
    testWidgets('should display menu buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );
      
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
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the container with gradient
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
      
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, hasLength(2));
      expect(gradient.colors[0], Colors.green.shade800);
      expect(gradient.colors[1], Colors.green.shade600);
    });
    
    testWidgets('should show game screen when play is pressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap the play button
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      
      // Should navigate to game screen
      expect(find.byType(MainMenuScreen), findsNothing);
    });
    
    testWidgets('should show exit confirmation dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );
      
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
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );
      
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
        await tester.pumpWidget(
          const MaterialApp(
            home: MainMenuScreen(),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Find play button
        final playButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'PLAY'),
        );
        
        // Check button style
        expect(playButton.style, isNotNull);
        
        // Check button size
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.widgetWithText(ElevatedButton, 'PLAY'),
            matching: find.byType(SizedBox),
          ).first,
        );
        
        expect(sizedBox.width, 200);
        expect(sizedBox.height, 50);
      });
    });
    
    group('Accessibility', () {
      testWidgets('should be accessible', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MainMenuScreen(),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Check semantic labels
        final semantics = tester.binding.pipelineOwner.semanticsOwner;
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
