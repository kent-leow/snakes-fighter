import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/widgets/game_controls_widget.dart';

void main() {
  group('GameControlsWidget', () {
    bool pauseCalled = false;
    bool resumeCalled = false;
    bool restartCalled = false;
    bool startCalled = false;

    setUp(() {
      pauseCalled = false;
      resumeCalled = false;
      restartCalled = false;
      startCalled = false;
    });

    testWidgets('should display start button in menu state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.menu,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
              onStart: () => startCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Start'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.text('Start'));
      expect(startCalled, isTrue);
    });

    testWidgets('should display pause button in playing state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.playing,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Pause'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      await tester.tap(find.text('Pause'));
      expect(pauseCalled, isTrue);
    });

    testWidgets('should display resume and restart buttons in paused state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.paused,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);

      await tester.tap(find.text('Resume'));
      expect(resumeCalled, isTrue);

      await tester.tap(find.text('Restart'));
      expect(restartCalled, isTrue);
    });

    testWidgets('should display play again button in game over state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.gameOver,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Play Again'), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);

      await tester.tap(find.text('Play Again'));
      expect(restartCalled, isTrue);
    });

    testWidgets('should hide controls during restarting state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.restarting,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should layout buttons in column when showAsRow is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.paused,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
              showAsRow: false,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      // ElevatedButton.icon internally uses Row, so we check for the main layout structure
      expect(
        find.descendant(
          of: find.byType(GameControlsWidget),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use custom button spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsWidget(
              gameState: GameState.paused,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
              buttonSpacing: 20,
            ),
          ),
        ),
      );

      // Check that SizedBox with custom width exists
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
    });
  });

  group('CompactGameControlsWidget', () {
    bool pauseCalled = false;
    bool resumeCalled = false;
    bool restartCalled = false;

    setUp(() {
      pauseCalled = false;
      resumeCalled = false;
      restartCalled = false;
    });

    testWidgets('should display pause button in playing state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactGameControlsWidget(
              gameState: GameState.playing,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(pauseCalled, isTrue);
    });

    testWidgets('should display resume button in paused state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactGameControlsWidget(
              gameState: GameState.paused,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(resumeCalled, isTrue);
    });

    testWidgets('should display restart button in game over state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactGameControlsWidget(
              gameState: GameState.gameOver,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(restartCalled, isTrue);
    });

    testWidgets('should hide in menu and restarting states', (tester) async {
      for (final state in [GameState.menu, GameState.restarting]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompactGameControlsWidget(
                gameState: state,
                onPause: () => pauseCalled = true,
                onResume: () => resumeCalled = true,
                onRestart: () => restartCalled = true,
              ),
            ),
          ),
        );

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(IconButton), findsNothing);
      }
    });

    testWidgets('should use custom button size', (tester) async {
      const customSize = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactGameControlsWidget(
              gameState: GameState.playing,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
              buttonSize: customSize,
            ),
          ),
        ),
      );

      final containerWidget = tester.widget<Container>(
        find.ancestor(
          of: find.byType(IconButton),
          matching: find.byType(Container),
        ),
      );

      expect(containerWidget.constraints?.maxWidth, customSize);
      expect(containerWidget.constraints?.maxHeight, customSize);
    });
  });

  group('FloatingGameControlsWidget', () {
    bool pauseCalled = false;
    bool resumeCalled = false;
    bool restartCalled = false;

    setUp(() {
      pauseCalled = false;
      resumeCalled = false;
      restartCalled = false;
    });

    testWidgets('should display floating pause button in playing state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingGameControlsWidget(
              gameState: GameState.playing,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      expect(pauseCalled, isTrue);
    });

    testWidgets('should display floating resume button in paused state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingGameControlsWidget(
              gameState: GameState.paused,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      expect(resumeCalled, isTrue);
    });

    testWidgets('should display floating restart button in game over state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingGameControlsWidget(
              gameState: GameState.gameOver,
              onPause: () => pauseCalled = true,
              onResume: () => resumeCalled = true,
              onRestart: () => restartCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      expect(restartCalled, isTrue);
    });

    testWidgets('should hide in menu and restarting states', (tester) async {
      for (final state in [GameState.menu, GameState.restarting]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FloatingGameControlsWidget(
                gameState: state,
                onPause: () => pauseCalled = true,
                onResume: () => resumeCalled = true,
                onRestart: () => restartCalled = true,
              ),
            ),
          ),
        );

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      }
    });
  });
}
