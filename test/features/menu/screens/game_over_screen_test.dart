import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/menu/screens/game_over_screen.dart';

void main() {
  group('GameOverScreen', () {
    late bool restartCalled;
    late bool mainMenuCalled;
    
    setUp(() {
      restartCalled = false;
      mainMenuCalled = false;
    });
    
    testWidgets('should display game over title for normal score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 50,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show game over title
      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
      expect(find.text('NEW HIGH SCORE!'), findsNothing);
    });
    
    testWidgets('should display new high score title for high score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 150,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show new high score title
      expect(find.text('NEW HIGH SCORE!'), findsOneWidget);
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('GAME OVER'), findsNothing);
    });
    
    testWidgets('should display final score', (tester) async {
      const finalScore = 75;
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: finalScore,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show final score
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.text(finalScore.toString()), findsOneWidget);
    });
    
    testWidgets('should display high score when not beaten', (tester) async {
      const finalScore = 50;
      const highScore = 100;
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: finalScore,
            highScore: highScore,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show both scores
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.text(finalScore.toString()), findsOneWidget);
      expect(find.text('High Score'), findsOneWidget);
      expect(find.text(highScore.toString()), findsOneWidget);
    });
    
    testWidgets('should not display high score section for new high score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 150,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should only show final score (which is the new high score)
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.text('High Score'), findsNothing);
    });
    
    testWidgets('should display action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 50,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check action buttons
      expect(find.text('PLAY AGAIN'), findsOneWidget);
      expect(find.text('MAIN MENU'), findsOneWidget);
      
      // Check button icons
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });
    
    testWidgets('should call restart callback when play again is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 50,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap play again button
      await tester.tap(find.text('PLAY AGAIN'));
      await tester.pumpAndSettle();
      
      // Check callback was called
      expect(restartCalled, true);
      expect(mainMenuCalled, false);
    });
    
    testWidgets('should call main menu callback when main menu is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 50,
            highScore: 100,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap main menu button
      await tester.tap(find.text('MAIN MENU'));
      await tester.pumpAndSettle();
      
      // Check callback was called
      expect(mainMenuCalled, true);
      expect(restartCalled, false);
    });
    
    testWidgets('should handle zero scores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverScreen(
            finalScore: 0,
            highScore: 0,
            onRestart: () => restartCalled = true,
            onMainMenu: () => mainMenuCalled = true,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show game over (not new high score)
      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.text('NEW HIGH SCORE!'), findsNothing);
      
      // Should show final score
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
    
    group('Background Gradient', () {
      testWidgets('should have red gradient background', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameOverScreen(
              finalScore: 50,
              highScore: 100,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
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
        expect(gradient.colors[0], Colors.red.shade800);
        expect(gradient.colors[1], Colors.red.shade600);
      });
    });
    
    group('Button Styling', () {
      testWidgets('should have different button styles', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameOverScreen(
              finalScore: 50,
              highScore: 100,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Play again should be ElevatedButton (primary)
        expect(
          find.widgetWithText(ElevatedButton, 'PLAY AGAIN'),
          findsOneWidget,
        );
        
        // Main menu should be OutlinedButton (secondary)
        expect(
          find.widgetWithText(OutlinedButton, 'MAIN MENU'),
          findsOneWidget,
        );
      });
      
      testWidgets('should have proper button sizes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameOverScreen(
              finalScore: 50,
              highScore: 100,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Find button size containers
        final sizedBoxes = tester.widgetList<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ),
        );
        
        expect(sizedBoxes.isNotEmpty, true);
        
        final buttonSizeBox = sizedBoxes.first;
        expect(buttonSizeBox.width, 200);
        expect(buttonSizeBox.height, 50);
      });
    });
    
    group('Score Highlighting', () {
      testWidgets('should highlight new high score', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameOverScreen(
              finalScore: 150,
              highScore: 100,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Final score should be present
        expect(find.text('Final Score'), findsOneWidget);
        expect(find.text('150'), findsOneWidget);
      });
    });
  });
}
