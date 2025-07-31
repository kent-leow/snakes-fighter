import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/widgets/responsive_game_container.dart';

void main() {
  group('ResponsiveGameContainer', () {
    testWidgets('should create container with default properties', (tester) async {
      const testChild = SizedBox(width: 100, height: 100);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.byType(ResponsiveGameContainer), findsOneWidget);
      expect(find.byWidget(testChild), findsOneWidget);
    });

    testWidgets('should apply target aspect ratio', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      const testChild = ColoredBox(color: Colors.red);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              targetAspectRatio: 1.0, // Square
              child: testChild,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      final aspectRatio = sizedBox.width! / sizedBox.height!;
      
      expect(aspectRatio, closeTo(1.0, 0.1));
    });

    testWidgets('should respect minimum size constraints', (tester) async {
      await tester.binding.setSurfaceSize(const Size(150, 150));
      
      const testChild = ColoredBox(color: Colors.blue);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              minWidth: 200.0,
              minHeight: 200.0,
              child: testChild,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      
      expect(sizedBox.width, greaterThanOrEqualTo(200.0));
      expect(sizedBox.height, greaterThanOrEqualTo(200.0));
    });

    testWidgets('should respect maximum size constraints', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      
      const testChild = ColoredBox(color: Colors.green);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              maxWidth: 400.0,
              maxHeight: 400.0,
              child: testChild,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      
      expect(sizedBox.width, lessThanOrEqualTo(400.0));
      expect(sizedBox.height, lessThanOrEqualTo(400.0));
    });

    testWidgets('should apply padding', (tester) async {
      const testPadding = EdgeInsets.all(20.0);
      const testChild = ColoredBox(color: Colors.yellow);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              padding: testPadding,
              child: testChild,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ResponsiveGameContainer),
          matching: find.byType(Container).last,
        ),
      );
      
      expect(container.padding, testPadding);
    });

    testWidgets('should center content by default', (tester) async {
      const testChild = SizedBox(width: 100, height: 100);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should not center when centerContent is false', (tester) async {
      const testChild = SizedBox(width: 100, height: 100);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGameContainer(
              centerContent: false,
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsNothing);
    });
  });

  group('AdaptiveGameContainer', () {
    testWidgets('should use SquareGameContainer for tablets', (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 1000)); // Tablet size (shortest side >= 600)
      
      const testChild = ColoredBox(color: Colors.purple);
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 1000)),
            child: const Scaffold(
              body: AdaptiveGameContainer(
                child: testChild,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SquareGameContainer), findsOneWidget);
    });

    testWidgets('should use LandscapeGameContainer for landscape phones', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 400)); // Landscape phone (shortest side < 600)
      
      const testChild = ColoredBox(color: Colors.orange);
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(600, 400)),
            child: const Scaffold(
              body: AdaptiveGameContainer(
                child: testChild,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LandscapeGameContainer), findsOneWidget);
    });

    testWidgets('should use PortraitGameContainer for portrait phones', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 600)); // Portrait phone (shortest side < 600)
      
      const testChild = ColoredBox(color: Colors.pink);
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 600)),
            child: const Scaffold(
              body: AdaptiveGameContainer(
                child: testChild,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PortraitGameContainer), findsOneWidget);
    });
  });

  group('GameLayoutUtils', () {
    group('calculateOptimalCellSize', () {
      test('should calculate cell size based on grid dimensions', () {
        const screenSize = Size(400, 400);
        const gridWidth = 20;
        const gridHeight = 20;
        const padding = EdgeInsets.all(10);

        final cellSize = GameLayoutUtils.calculateOptimalCellSize(
          screenSize: screenSize,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          padding: padding,
        );

        // Available space: 400 - 20 = 380
        // Cell size: 380 / 20 = 19
        expect(cellSize, equals(19.0));
      });

      test('should respect minimum cell size', () {
        const screenSize = Size(100, 100);
        const gridWidth = 50;
        const gridHeight = 50;
        const padding = EdgeInsets.zero;
        const minCellSize = 5.0;

        final cellSize = GameLayoutUtils.calculateOptimalCellSize(
          screenSize: screenSize,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          padding: padding,
          minCellSize: minCellSize,
        );

        expect(cellSize, greaterThanOrEqualTo(minCellSize));
      });

      test('should respect maximum cell size', () {
        const screenSize = Size(1000, 1000);
        const gridWidth = 10;
        const gridHeight = 10;
        const padding = EdgeInsets.zero;
        const maxCellSize = 50.0;

        final cellSize = GameLayoutUtils.calculateOptimalCellSize(
          screenSize: screenSize,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          padding: padding,
          maxCellSize: maxCellSize,
        );

        expect(cellSize, lessThanOrEqualTo(maxCellSize));
      });

      test('should handle rectangular grids', () {
        const screenSize = Size(800, 400);
        const gridWidth = 40; // 800/40 = 20
        const gridHeight = 10; // 400/10 = 40
        const padding = EdgeInsets.zero;

        final cellSize = GameLayoutUtils.calculateOptimalCellSize(
          screenSize: screenSize,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          padding: padding,
        );

        // Should use the smaller dimension (20)
        expect(cellSize, equals(20.0));
      });
    });

    group('isScreenSuitable', () {
      test('should return true for suitable screens', () {
        const suitableSize = Size(400, 400);
        
        expect(
          GameLayoutUtils.isScreenSuitable(suitableSize),
          isTrue,
        );
      });

      test('should return false for too small screens', () {
        const tooSmallSize = Size(100, 100);
        
        expect(
          GameLayoutUtils.isScreenSuitable(tooSmallSize),
          isFalse,
        );
      });

      test('should respect custom minimum dimensions', () {
        const screenSize = Size(150, 150);
        
        expect(
          GameLayoutUtils.isScreenSuitable(
            screenSize,
            minWidth: 100.0,
            minHeight: 100.0,
          ),
          isTrue,
        );
        
        expect(
          GameLayoutUtils.isScreenSuitable(
            screenSize,
            minWidth: 200.0,
            minHeight: 200.0,
          ),
          isFalse,
        );
      });
    });

    group('getRecommendedGameSize', () {
      test('should maintain aspect ratio', () {
        const screenSize = Size(800, 600);
        const targetAspectRatio = 1.0; // Square

        final gameSize = GameLayoutUtils.getRecommendedGameSize(
          screenSize,
          targetAspectRatio,
        );

        final actualAspectRatio = gameSize.width / gameSize.height;
        expect(actualAspectRatio, closeTo(targetAspectRatio, 0.01));
      });

      test('should fit within screen bounds', () {
        const screenSize = Size(400, 300);
        const targetAspectRatio = 1.0;

        final gameSize = GameLayoutUtils.getRecommendedGameSize(
          screenSize,
          targetAspectRatio,
        );

        expect(gameSize.width, lessThanOrEqualTo(screenSize.width * 0.9));
        expect(gameSize.height, lessThanOrEqualTo(screenSize.height * 0.8));
      });

      test('should handle different aspect ratios', () {
        const screenSize = Size(800, 400);
        
        // Wide aspect ratio
        final wideGameSize = GameLayoutUtils.getRecommendedGameSize(
          screenSize,
          2.0, // 2:1 aspect ratio
        );
        
        expect(wideGameSize.width / wideGameSize.height, closeTo(2.0, 0.01));
        
        // Tall aspect ratio
        final tallGameSize = GameLayoutUtils.getRecommendedGameSize(
          screenSize,
          0.5, // 1:2 aspect ratio
        );
        
        expect(tallGameSize.width / tallGameSize.height, closeTo(0.5, 0.01));
      });
    });
  });
}
