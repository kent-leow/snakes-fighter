import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/models/collision.dart';

void main() {
  group('Collision Models', () {
    group('CollisionType', () {
      test('should have all expected collision types', () {
        const types = CollisionType.values;
        expect(types, contains(CollisionType.none));
        expect(types, contains(CollisionType.wall));
        expect(types, contains(CollisionType.selfCollision));
        expect(types, contains(CollisionType.otherSnake));
        expect(types, contains(CollisionType.food));
      });
    });

    group('CollisionResult', () {
      test('should create collision result with required properties', () {
        const position = Position(5, 5);
        const detectionTime = 0.05;

        const result = CollisionResult(
          type: CollisionType.wall,
          collisionPoint: position,
          isGameEnding: true,
          detectionTime: detectionTime,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.detectionTime, equals(detectionTime));
        expect(result.metadata, isEmpty);
      });

      test('should create no collision result', () {
        final result = CollisionResult.none(detectionTime: 0.02);

        expect(result.type, equals(CollisionType.none));
        expect(result.collisionPoint, isNull);
        expect(result.isGameEnding, isFalse);
        expect(result.detectionTime, equals(0.02));
        expect(result.hasCollision, isFalse);
      });

      test('should create wall collision result', () {
        const position = Position(-1, 5);
        final result = CollisionResult.wallCollision(
          collisionPoint: position,
          detectionTime: 0.03,
          metadata: {'boundary': 'left'},
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.hasCollision, isTrue);
        expect(result.metadata['boundary'], equals('left'));
      });

      test('should create self collision result', () {
        const position = Position(10, 10);
        final result = CollisionResult.selfCollision(
          collisionPoint: position,
          detectionTime: 0.04,
          metadata: {'segment_index': 3},
        );

        expect(result.type, equals(CollisionType.selfCollision));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.hasCollision, isTrue);
        expect(result.metadata['segment_index'], equals(3));
      });

      test('should create food collision result', () {
        const position = Position(8, 8);
        final result = CollisionResult.foodCollision(
          collisionPoint: position,
          detectionTime: 0.01,
          metadata: {'score': 10},
        );

        expect(result.type, equals(CollisionType.food));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isFalse);
        expect(result.hasCollision, isTrue);
        expect(result.metadata['score'], equals(10));
      });

      test('should have proper equality comparison', () {
        const position = Position(5, 5);

        final result1 = CollisionResult.wallCollision(
          collisionPoint: position,
          detectionTime: 0.05,
        );

        final result2 = CollisionResult.wallCollision(
          collisionPoint: position,
          detectionTime: 0.03, // Different time should not affect equality
        );

        expect(result1, equals(result2));
      });

      test('should have proper string representation', () {
        final result = CollisionResult.wallCollision(
          collisionPoint: const Position(10, 20),
          detectionTime: 0.123,
        );

        final string = result.toString();
        expect(string, contains('wall'));
        expect(string, contains('(10, 20)'));
        expect(string, contains('true'));
        expect(string, contains('0.123'));
      });
    });
  });
}
