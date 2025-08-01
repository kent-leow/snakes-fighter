import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/widgets/score_display_widget.dart';

void main() {
  group('ScoreDisplayWidget', () {
    late StreamController<int> scoreStreamController;

    setUp(() {
      scoreStreamController = StreamController<int>.broadcast();
    });

    tearDown(() {
      scoreStreamController.close();
    });

    testWidgets('should display current score', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 50,
            highScore: 100,
          ),
        ),
      ));

      expect(find.text('Score: 50'), findsOneWidget);
      expect(find.text('Best: 100'), findsOneWidget);
    });

    testWidgets('should update when stream emits new values', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 0,
            highScore: 0,
          ),
        ),
      ));

      expect(find.text('Score: 0'), findsOneWidget);

      // Emit new score
      scoreStreamController.add(25);
      await tester.pump();

      expect(find.text('Score: 25'), findsOneWidget);
    });

    testWidgets('should hide high score when showHighScore is false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 50,
            highScore: 100,
            showHighScore: false,
          ),
        ),
      ));

      expect(find.text('Score: 50'), findsOneWidget);
      expect(find.text('Best: 100'), findsNothing);
    });

    testWidgets('should hide high score when high score is zero', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 25,
            highScore: 0,
          ),
        ),
      ));

      expect(find.text('Score: 25'), findsOneWidget);
      expect(find.text('Best: 0'), findsNothing);
    });

    testWidgets('should use custom text styles', (tester) async {
      const customScoreStyle = TextStyle(fontSize: 24, color: Colors.red);
      const customHighScoreStyle = TextStyle(fontSize: 16, color: Colors.blue);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 50,
            highScore: 100,
            scoreTextStyle: customScoreStyle,
            highScoreTextStyle: customHighScoreStyle,
          ),
        ),
      ));

      final scoreText = tester.widget<Text>(find.text('Score: 50'));
      final highScoreText = tester.widget<Text>(find.text('Best: 100'));

      expect(scoreText.style?.fontSize, 24);
      expect(scoreText.style?.color, Colors.red);
      expect(highScoreText.style?.fontSize, 16);
      expect(highScoreText.style?.color, Colors.blue);
    });
  });

  group('CompactScoreDisplayWidget', () {
    late StreamController<int> scoreStreamController;

    setUp(() {
      scoreStreamController = StreamController<int>.broadcast();
    });

    tearDown(() {
      scoreStreamController.close();
    });

    testWidgets('should display score number only', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompactScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 75,
          ),
        ),
      ));

      expect(find.text('75'), findsOneWidget);
      expect(find.text('Score: 75'), findsNothing);
    });

    testWidgets('should update with stream', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompactScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 0,
          ),
        ),
      ));

      expect(find.text('0'), findsOneWidget);

      scoreStreamController.add(150);
      await tester.pump();

      expect(find.text('150'), findsOneWidget);
    });
  });

  group('AnimatedScoreDisplayWidget', () {
    late StreamController<int> scoreStreamController;

    setUp(() {
      scoreStreamController = StreamController<int>.broadcast();
    });

    tearDown(() {
      scoreStreamController.close();
    });

    testWidgets('should render basic score display', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 30,
            highScore: 100,
          ),
        ),
      ));

      expect(find.text('Score: 30'), findsOneWidget);
      expect(find.text('Best: 100'), findsOneWidget);
    });

    testWidgets('should animate on score change', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedScoreDisplayWidget(
            scoreStream: scoreStreamController.stream,
            currentScore: 0,
            highScore: 0,
            animationDuration: const Duration(milliseconds: 100),
          ),
        ),
      ));

      expect(find.text('Score: 0'), findsOneWidget);

      // Trigger score increase
      scoreStreamController.add(10);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50)); // Mid-animation

      // Should still show the updated score
      expect(find.text('Score: 10'), findsOneWidget);

      // Complete animation
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
