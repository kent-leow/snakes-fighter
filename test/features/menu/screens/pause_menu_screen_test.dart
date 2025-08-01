import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/menu/screens/pause_menu_screen.dart';

void main() {
  group('PauseMenuScreen', () {
    late bool resumeCalled;
    late bool restartCalled;
    late bool mainMenuCalled;
    
    setUp(() {
      resumeCalled = false;
      restartCalled = false;
      mainMenuCalled = false;
    });
    
    testWidgets('should display pause title and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check pause title and icon
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    });
    
    testWidgets('should display menu buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check menu buttons
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
      
      // Check button icons
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });
    
    testWidgets('should have transparent background overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the overlay container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.color, Colors.black.withOpacity(0.8));
    });
    
    testWidgets('should call resume callback when resume is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap resume button
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      
      // Check callback was called
      expect(resumeCalled, true);
      expect(restartCalled, false);
      expect(mainMenuCalled, false);
    });
    
    testWidgets('should show restart confirmation dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Restart Game'), findsOneWidget);
      expect(
        find.text('Are you sure you want to restart? Your current progress will be lost.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Restart'), findsNWidgets(2)); // Button and dialog button
    });
    
    testWidgets('should call restart callback when confirmed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      
      // Confirm restart in dialog
      await tester.tap(find.text('Restart').last);
      await tester.pumpAndSettle();
      
      // Check callback was called
      expect(restartCalled, true);
      expect(resumeCalled, false);
      expect(mainMenuCalled, false);
    });
    
    testWidgets('should cancel restart when cancel is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      
      // Cancel restart in dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Check callback was not called
      expect(restartCalled, false);
    });
    
    testWidgets('should show main menu confirmation dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap main menu button
      await tester.tap(find.text('Main Menu'));
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Return to Main Menu'), findsOneWidget);
      expect(
        find.text('Are you sure you want to return to the main menu? Your current progress will be lost.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Main Menu'), findsNWidgets(2)); // Button and dialog button
    });
    
    testWidgets('should call main menu callback when confirmed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseMenuScreen(
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap main menu button
      await tester.tap(find.text('Main Menu'));
      await tester.pumpAndSettle();
      
      // Confirm main menu in dialog
      await tester.tap(find.text('Main Menu').last);
      await tester.pumpAndSettle();
      
      // Check callback was called
      expect(mainMenuCalled, true);
      expect(resumeCalled, false);
      expect(restartCalled, false);
    });
    
    group('Button Styling', () {
      testWidgets('resume button should be primary style', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PauseMenuScreen(
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Resume button should be ElevatedButton (primary)
        expect(
          find.widgetWithText(ElevatedButton, 'Resume'),
          findsOneWidget,
        );
        
        // Other buttons should be OutlinedButton (secondary)
        expect(
          find.widgetWithText(OutlinedButton, 'Restart'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(OutlinedButton, 'Main Menu'),
          findsOneWidget,
        );
      });
    });
    
    group('Layout', () {
      testWidgets('should be properly centered and sized', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PauseMenuScreen(
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Should have a Card widget for the menu
        expect(find.byType(Card), findsOneWidget);
        
        // Should have proper constraints
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(Card),
            matching: find.byType(Container),
          ),
        );
        
        expect(container.constraints, const BoxConstraints(maxWidth: 300));
      });
    });
  });
}
