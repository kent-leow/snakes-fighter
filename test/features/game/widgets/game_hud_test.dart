import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/models/score_manager.dart';
import 'package:snakes_fight/features/game/widgets/game_controls_widget.dart';
import 'package:snakes_fight/features/game/widgets/game_hud.dart';

void main() {
  group('GameHUD', () {
    late ScoreManager scoreManager;
    late GameStateManager stateManager;
    late Widget testWidget;

    bool pauseCalled = false;
    bool resumeCalled = false;
    bool restartCalled = false;

    setUp(() {
      scoreManager = ScoreManager();
      stateManager = GameStateManager();
      pauseCalled = false;
      resumeCalled = false;
      restartCalled = false;

      testWidget = MaterialApp(
        home: Scaffold(
          body: GameHUD(
            scoreManager: scoreManager,
            stateManager: stateManager,
            onPause: () => pauseCalled = true,
            onResume: () => resumeCalled = true,
            onRestart: () => restartCalled = true,
          ),
        ),
      );
    });

    tearDown(() {
      scoreManager.dispose();
      stateManager.dispose();
    });

    group('widget rendering', () {
      testWidgets('should render HUD in menu state', (tester) async {
        await tester.pumpWidget(testWidget);

        // Should show score display
        expect(find.text('Score: 0'), findsOneWidget);

        // Should show menu status message
        expect(find.text('TAP TO START'), findsOneWidget);
      });

      testWidgets('should render HUD in playing state', (tester) async {
        stateManager.transitionTo(GameState.playing);
        await tester.pumpWidget(testWidget);
        await tester.pump(); // Allow state changes to propagate

        // Should show score display
        expect(find.text('Score: 0'), findsOneWidget);

        // Should show pause button
        expect(find.text('Pause'), findsOneWidget);

        // Should not show status message during gameplay
        expect(find.text('TAP TO START'), findsNothing);
      });

      testWidgets('should render HUD in paused state', (tester) async {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Should show paused message
        expect(find.text('PAUSED'), findsOneWidget);

        // Should show resume and restart buttons
        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('Restart'), findsOneWidget);
      });

      testWidgets('should render HUD in game over state', (tester) async {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.gameOver);
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Should show game over message
        expect(find.text('GAME OVER'), findsOneWidget);

        // Should show play again button
        expect(find.text('Play Again'), findsOneWidget);
      });
    });

    group('score display', () {
      testWidgets('should update score display', (tester) async {
        await tester.pumpWidget(testWidget);

        // Initial score
        expect(find.text('Score: 0'), findsOneWidget);

        // Update score
        scoreManager.addPoints(50);
        await tester.pump();

        expect(find.text('Score: 50'), findsOneWidget);
      });

      testWidgets('should show high score when available', (tester) async {
        scoreManager.updateHighScore(100);
        await tester.pumpWidget(testWidget);

        expect(find.text('Best: 100'), findsOneWidget);
      });

      testWidgets('should show food count and session info', (tester) async {
        scoreManager.startNewSession();
        scoreManager.addFoodPoints();
        scoreManager.addFoodPoints();

        await tester.pumpWidget(testWidget);
        await tester.pump();

        expect(find.text('Food: 2'), findsOneWidget);
        expect(find.text('Session: 1'), findsOneWidget);
      });
    });

    group('button interactions', () {
      testWidgets('should call pause callback when pause button tapped', (
        tester,
      ) async {
        stateManager.transitionTo(GameState.playing);
        await tester.pumpWidget(testWidget);
        await tester.pump();

        await tester.tap(find.text('Pause'));
        await tester.pump();

        expect(pauseCalled, isTrue);
      });

      testWidgets('should call resume callback when resume button tapped', (
        tester,
      ) async {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);
        await tester.pumpWidget(testWidget);
        await tester.pump();

        await tester.tap(find.text('Resume'));
        await tester.pump();

        expect(resumeCalled, isTrue);
      });

      testWidgets('should call restart callback when restart button tapped', (
        tester,
      ) async {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);
        await tester.pumpWidget(testWidget);
        await tester.pump();

        await tester.tap(find.text('Restart'));
        await tester.pump();

        expect(restartCalled, isTrue);
      });

      testWidgets('should call restart callback from game over state', (
        tester,
      ) async {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.gameOver);
        await tester.pumpWidget(testWidget);
        await tester.pump();

        await tester.tap(find.text('Play Again'));
        await tester.pump();

        expect(restartCalled, isTrue);
      });
    });

    group('responsive design', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test small screen
        await tester.binding.setSurfaceSize(const Size(300, 600));
        await tester.pumpWidget(testWidget);

        // HUD should still be visible and functional
        expect(find.text('Score: 0'), findsOneWidget);

        // Test large screen
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(testWidget);

        expect(find.text('Score: 0'), findsOneWidget);

        // Reset to default
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('animations', () {
      testWidgets('should animate state transitions', (tester) async {
        await tester.pumpWidget(testWidget);

        // Transition from menu to playing
        stateManager.transitionTo(GameState.playing);
        await tester.pumpAndSettle(); // Wait for all animations to complete

        // Verify GameControlsWidget is present and responsive to state changes
        expect(find.byType(GameControlsWidget), findsOneWidget);
      });
    });
  });
}
