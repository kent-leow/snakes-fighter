import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';

void main() {
  group('Position', () {
    test('should create position with correct coordinates', () {
      const position = Position(5, 10);
      expect(position.x, equals(5));
      expect(position.y, equals(10));
    });

    test('should create origin position', () {
      const position = Position.origin();
      expect(position.x, equals(0));
      expect(position.y, equals(0));
    });

    group('operators', () {
      test('should add positions correctly', () {
        const pos1 = Position(3, 4);
        const pos2 = Position(2, 1);
        final result = pos1 + pos2;

        expect(result.x, equals(5));
        expect(result.y, equals(5));
      });

      test('should subtract positions correctly', () {
        const pos1 = Position(5, 7);
        const pos2 = Position(2, 3);
        final result = pos1 - pos2;

        expect(result.x, equals(3));
        expect(result.y, equals(4));
      });

      test('should multiply position by scalar', () {
        const position = Position(3, 4);
        final result = position * 2;

        expect(result.x, equals(6));
        expect(result.y, equals(8));
      });

      test('should check equality correctly', () {
        const pos1 = Position(3, 4);
        const pos2 = Position(3, 4);
        const pos3 = Position(3, 5);

        expect(pos1, equals(pos2));
        expect(pos1, isNot(equals(pos3)));
      });

      test('should have consistent hashCode', () {
        const pos1 = Position(3, 4);
        const pos2 = Position(3, 4);

        expect(pos1.hashCode, equals(pos2.hashCode));
      });
    });

    group('distance calculations', () {
      test('should calculate Euclidean distance correctly', () {
        const pos1 = Position(0, 0);
        const pos2 = Position(3, 4);
        final distance = pos1.distanceTo(pos2);

        expect(distance, equals(5.0));
      });

      test('should calculate Manhattan distance correctly', () {
        const pos1 = Position(1, 1);
        const pos2 = Position(4, 5);
        final distance = pos1.manhattanDistanceTo(pos2);

        expect(distance, equals(7));
      });

      test('should calculate distance to itself as zero', () {
        const position = Position(5, 5);
        expect(position.distanceTo(position), equals(0.0));
        expect(position.manhattanDistanceTo(position), equals(0));
      });
    });

    group('neighbors', () {
      test('should return four adjacent neighbors', () {
        const position = Position(5, 5);
        final neighbors = position.getNeighbors();

        expect(neighbors, hasLength(4));
        expect(neighbors, contains(const Position(5, 4))); // Up
        expect(neighbors, contains(const Position(6, 5))); // Right
        expect(neighbors, contains(const Position(5, 6))); // Down
        expect(neighbors, contains(const Position(4, 5))); // Left
      });

      test('should return all eight neighbors', () {
        const position = Position(5, 5);
        final neighbors = position.getAllNeighbors();

        expect(neighbors, hasLength(8));
        expect(neighbors, contains(const Position(4, 4))); // Top-left
        expect(neighbors, contains(const Position(5, 4))); // Top
        expect(neighbors, contains(const Position(6, 4))); // Top-right
        expect(neighbors, contains(const Position(6, 5))); // Right
        expect(neighbors, contains(const Position(6, 6))); // Bottom-right
        expect(neighbors, contains(const Position(5, 6))); // Bottom
        expect(neighbors, contains(const Position(4, 6))); // Bottom-left
        expect(neighbors, contains(const Position(4, 5))); // Left
      });
    });

    group('adjacency checks', () {
      test('should detect adjacent positions', () {
        const center = Position(5, 5);
        const adjacent = Position(5, 6);
        const diagonal = Position(6, 6);
        const distant = Position(8, 8);

        expect(center.isAdjacentTo(adjacent), isTrue);
        expect(center.isAdjacentTo(diagonal), isTrue);
        expect(center.isAdjacentTo(distant), isFalse);
        expect(center.isAdjacentTo(center), isFalse);
      });

      test('should detect directly adjacent positions', () {
        const center = Position(5, 5);
        const directlyAdjacent = Position(5, 6);
        const diagonal = Position(6, 6);

        expect(center.isDirectlyAdjacentTo(directlyAdjacent), isTrue);
        expect(center.isDirectlyAdjacentTo(diagonal), isFalse);
      });
    });

    test('should create copy with modified coordinates', () {
      const original = Position(3, 4);
      final copiedX = original.copyWith(x: 5);
      final copiedY = original.copyWith(y: 7);
      final copiedBoth = original.copyWith(x: 8, y: 9);

      expect(copiedX, equals(const Position(5, 4)));
      expect(copiedY, equals(const Position(3, 7)));
      expect(copiedBoth, equals(const Position(8, 9)));
    });

    test('should have proper string representation', () {
      const position = Position(3, 4);
      expect(position.toString(), equals('Position(3, 4)'));
    });
  });
}
