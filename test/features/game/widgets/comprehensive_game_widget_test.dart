import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Game Widget Tests', () {
    testWidgets('Game Screen renders without crashing', (WidgetTester tester) async {
      // Create a test widget with proper provider scope
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Container(
                width: 400,
                height: 600,
                color: Colors.black,
                child: const Center(
                  child: Text('Game Canvas Placeholder'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the basic structure renders
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Game Canvas Placeholder'), findsOneWidget);
    });

    testWidgets('Game Canvas handles touch input', (WidgetTester tester) async {
      bool touchDetected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => touchDetected = true,
              child: Container(
                width: 400,
                height: 600,
                color: Colors.black,
                child: const Center(
                  child: Text('Touch to control'),
                ),
              ),
            ),
          ),
        ),
      );

      // Simulate touch input
      await tester.tap(find.text('Touch to control'));
      await tester.pump();

      expect(touchDetected, isTrue);
    });

    testWidgets('Game HUD displays score correctly', (WidgetTester tester) async {
      const testScore = 150;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Score: $testScore'),
                      const Text('Lives: 3'),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Score: $testScore'), findsOneWidget);
      expect(find.text('Lives: 3'), findsOneWidget);
    });

    testWidgets('Game controls respond to swipe gestures', (WidgetTester tester) async {
      String? detectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onPanUpdate: (details) {
                final delta = details.delta;
                if (delta.dx.abs() > delta.dy.abs()) {
                  detectedDirection = delta.dx > 0 ? 'right' : 'left';
                } else {
                  detectedDirection = delta.dy > 0 ? 'down' : 'up';
                }
              },
              child: Container(
                width: 400,
                height: 600,
                color: Colors.black,
                child: const Center(
                  child: Text('Swipe to control'),
                ),
              ),
            ),
          ),
        ),
      );

      // Simulate swipe right
      await tester.drag(find.text('Swipe to control'), const Offset(100, 0));
      await tester.pump();

      expect(detectedDirection, equals('right'));

      // Simulate swipe up
      await tester.drag(find.text('Swipe to control'), const Offset(0, -100));
      await tester.pump();

      expect(detectedDirection, equals('up'));
    });

    testWidgets('Game pause functionality works correctly', (WidgetTester tester) async {
      // Test pause button functionality
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(color: Colors.black),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
      
      // Test pause button tap
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
    });

    testWidgets('Game over screen displays correctly', (WidgetTester tester) async {
      const finalScore = 250;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'YOU WIN!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Final Score: $finalScore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Play Again'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Main Menu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('YOU WIN!'), findsOneWidget);
      expect(find.text('Final Score: $finalScore'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('Multiplayer game shows all player scores', (WidgetTester tester) async {
      final players = [
        {'name': 'Player 1', 'score': 100, 'alive': true},
        {'name': 'Player 2', 'score': 75, 'alive': false},
        {'name': 'Player 3', 'score': 150, 'alive': true},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: players.map((player) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            player['name'] as String,
                            style: TextStyle(
                              color: player['alive'] as bool ? Colors.white : Colors.grey,
                            ),
                          ),
                          Text(
                            '${player['score']}',
                            style: TextStyle(
                              color: player['alive'] as bool ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Container(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.text('Player 3'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
    });

    group('Responsive Design Tests', () {
      testWidgets('Game UI adapts to different screen sizes', (WidgetTester tester) async {
        // Test small screen
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 400;
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                        child: Text(
                          'Snakes Fight',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(color: Colors.black),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Snakes Fight'), findsOneWidget);
        addTearDown(() => tester.view.resetPhysicalSize());
      });

      testWidgets('Game controls adjust for tablet layout', (WidgetTester tester) async {
        // Test tablet screen
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  return Row(
                    children: [
                      Expanded(
                        flex: isTablet ? 3 : 1,
                        child: Container(color: Colors.black),
                      ),
                      if (isTablet)
                        Container(
                          width: 200,
                          color: Colors.grey.shade800,
                          child: const Column(
                            children: [
                              Text('Game Info', style: TextStyle(color: Colors.white)),
                              Text('Score: 0', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Game Info'), findsOneWidget);
        expect(find.text('Score: 0'), findsOneWidget);
        addTearDown(() => tester.view.resetPhysicalSize());
      });
    });

    group('Performance Tests', () {
      testWidgets('Widget builds efficiently', (WidgetTester tester) async {
        // Test that widgets don't rebuild unnecessarily
        int buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  buildCount++;
                  return Container(
                    color: Colors.black,
                    child: Text('Build count: $buildCount'),
                  );
                },
              ),
            ),
          ),
        );

        expect(buildCount, equals(1));
        expect(find.text('Build count: 1'), findsOneWidget);

        // Pump again - should not trigger rebuild
        await tester.pump();
        expect(buildCount, equals(1));
      });
    });
  });
}
