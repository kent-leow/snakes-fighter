import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/models/direction.dart';

void main() {
  group('Direction', () {
    group('opposite', () {
      test('should return correct opposite directions', () {
        expect(Direction.up.opposite, Direction.down);
        expect(Direction.down.opposite, Direction.up);
        expect(Direction.left.opposite, Direction.right);
        expect(Direction.right.opposite, Direction.left);
      });
    });

    group('delta', () {
      test('should return correct coordinate deltas', () {
        expect(Direction.up.delta, (0, -1));
        expect(Direction.down.delta, (0, 1));
        expect(Direction.left.delta, (-1, 0));
        expect(Direction.right.delta, (1, 0));
      });
    });

    group('isHorizontal', () {
      test('should correctly identify horizontal directions', () {
        expect(Direction.left.isHorizontal, isTrue);
        expect(Direction.right.isHorizontal, isTrue);
        expect(Direction.up.isHorizontal, isFalse);
        expect(Direction.down.isHorizontal, isFalse);
      });
    });

    group('isVertical', () {
      test('should correctly identify vertical directions', () {
        expect(Direction.up.isVertical, isTrue);
        expect(Direction.down.isVertical, isTrue);
        expect(Direction.left.isVertical, isFalse);
        expect(Direction.right.isVertical, isFalse);
      });
    });

    group('canChangeTo', () {
      test('should allow valid direction changes', () {
        expect(Direction.up.canChangeTo(Direction.left), isTrue);
        expect(Direction.up.canChangeTo(Direction.right), isTrue);
        expect(Direction.up.canChangeTo(Direction.up), isTrue);

        expect(Direction.right.canChangeTo(Direction.up), isTrue);
        expect(Direction.right.canChangeTo(Direction.down), isTrue);
        expect(Direction.right.canChangeTo(Direction.right), isTrue);
      });

      test('should prevent 180-degree turns', () {
        expect(Direction.up.canChangeTo(Direction.down), isFalse);
        expect(Direction.down.canChangeTo(Direction.up), isFalse);
        expect(Direction.left.canChangeTo(Direction.right), isFalse);
        expect(Direction.right.canChangeTo(Direction.left), isFalse);
      });
    });
  });
}
