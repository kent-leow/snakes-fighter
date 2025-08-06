import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/core/utils/model_utils.dart';

void main() {
  group('ModelUtils', () {
    group('Room Code Generation', () {
      test('should generate valid room codes', () {
        final code = ModelUtils.generateRoomCode();
        expect(code.length, equals(6));
        expect(ModelUtils.isValidRoomCode(code), isTrue);
      });

      test('should generate unique room codes', () {
        final codes = <String>{};
        for (int i = 0; i < 100; i++) {
          codes.add(ModelUtils.generateRoomCode());
        }
        expect(codes.length, equals(100)); // All should be unique
      });

      test('should validate room codes correctly', () {
        expect(ModelUtils.isValidRoomCode('ABCD12'), isTrue);
        expect(ModelUtils.isValidRoomCode('ABC123'), isTrue);
        expect(ModelUtils.isValidRoomCode('123456'), isTrue);

        // Invalid cases
        expect(ModelUtils.isValidRoomCode(''), isFalse);
        expect(ModelUtils.isValidRoomCode('ABC12'), isFalse); // Too short
        expect(ModelUtils.isValidRoomCode('ABCD123'), isFalse); // Too long
        expect(ModelUtils.isValidRoomCode('abcd12'), isFalse); // Lowercase
        expect(ModelUtils.isValidRoomCode('ABC-12'), isFalse); // Special chars
      });
    });

    group('Position Generation', () {
      test('should generate positions within bounds', () {
        final position = ModelUtils.generateRandomPosition(maxX: 10, maxY: 20);

        expect(position.x, greaterThanOrEqualTo(0));
        expect(position.x, lessThan(10));
        expect(position.y, greaterThanOrEqualTo(0));
        expect(position.y, lessThan(20));
      });

      test('should respect min bounds', () {
        final position = ModelUtils.generateRandomPosition(
          minX: 5,
          minY: 10,
          maxX: 15,
          maxY: 20,
        );

        expect(position.x, greaterThanOrEqualTo(5));
        expect(position.x, lessThan(15));
        expect(position.y, greaterThanOrEqualTo(10));
        expect(position.y, lessThan(20));
      });
    });

    group('Player Colors', () {
      test('should find next available color', () {
        final usedColors = [PlayerColor.red, PlayerColor.blue];
        final nextColor = ModelUtils.getNextAvailableColor(usedColors);

        expect(nextColor, isNotNull);
        expect(usedColors, isNot(contains(nextColor)));
      });

      test('should return null when all colors are used', () {
        const allColors = PlayerColor.values;
        final nextColor = ModelUtils.getNextAvailableColor(allColors);

        expect(nextColor, isNull);
      });

      test('should convert colors to hex', () {
        expect(ModelUtils.playerColorToHex(PlayerColor.red), equals('#FF4444'));
        expect(
          ModelUtils.playerColorToHex(PlayerColor.blue),
          equals('#4444FF'),
        );
        expect(
          ModelUtils.playerColorToHex(PlayerColor.green),
          equals('#44FF44'),
        );
        expect(
          ModelUtils.playerColorToHex(PlayerColor.yellow),
          equals('#FFFF44'),
        );
      });

      test('should convert colors to display names', () {
        expect(
          ModelUtils.playerColorToDisplayName(PlayerColor.red),
          equals('Red'),
        );
        expect(
          ModelUtils.playerColorToDisplayName(PlayerColor.blue),
          equals('Blue'),
        );
        expect(
          ModelUtils.playerColorToDisplayName(PlayerColor.green),
          equals('Green'),
        );
        expect(
          ModelUtils.playerColorToDisplayName(PlayerColor.yellow),
          equals('Yellow'),
        );
      });
    });

    group('Display Name Validation', () {
      test('should validate display names', () {
        expect(ModelUtils.isValidDisplayName('ValidName'), isTrue);
        expect(ModelUtils.isValidDisplayName('Valid_Name'), isTrue);
        expect(ModelUtils.isValidDisplayName('Valid-Name'), isTrue);
        expect(ModelUtils.isValidDisplayName('Valid Name'), isTrue);
        expect(ModelUtils.isValidDisplayName('Player123'), isTrue);

        // Invalid cases
        expect(ModelUtils.isValidDisplayName(''), isFalse);
        expect(ModelUtils.isValidDisplayName('A' * 21), isFalse); // Too long
        expect(ModelUtils.isValidDisplayName('Invalid@Name'), isFalse);
        expect(ModelUtils.isValidDisplayName('Invalid#Name'), isFalse);
      });

      test('should sanitize display names', () {
        expect(
          ModelUtils.sanitizeDisplayName('  ValidName  '),
          equals('ValidName'),
        );
        expect(
          ModelUtils.sanitizeDisplayName('Invalid@Name'),
          equals('InvalidName'),
        );
        expect(ModelUtils.sanitizeDisplayName('A' * 25), equals('A' * 20));
      });
    });

    group('Position Utilities', () {
      test('should check if position is in bounds', () {
        expect(
          ModelUtils.isPositionInBounds(
            const Position(5, 10),
            width: 20,
            height: 20,
          ),
          isTrue,
        );

        expect(
          ModelUtils.isPositionInBounds(
            const Position(-1, 10),
            width: 20,
            height: 20,
          ),
          isFalse,
        );

        expect(
          ModelUtils.isPositionInBounds(
            const Position(25, 10),
            width: 20,
            height: 20,
          ),
          isFalse,
        );
      });

      test('should calculate distance between positions', () {
        const pos1 = Position(0, 0);
        const pos2 = Position(3, 4);

        expect(ModelUtils.calculateDistance(pos1, pos2), equals(5.0));
      });
    });

    group('Snake Position Generation', () {
      test('should generate initial snake positions', () {
        final positions = ModelUtils.generateInitialSnakePositions(
          playerCount: 3,
          gridWidth: 20,
          gridHeight: 20,
        );

        expect(positions.length, equals(3));

        // All positions should be at the same y coordinate
        final y = positions.first.y;
        for (final position in positions) {
          expect(position.y, equals(y));
        }
      });
    });

    group('Direction Utilities', () {
      test('should convert directions to strings', () {
        expect(ModelUtils.directionToString(Direction.up), equals('Up'));
        expect(ModelUtils.directionToString(Direction.down), equals('Down'));
        expect(ModelUtils.directionToString(Direction.left), equals('Left'));
        expect(ModelUtils.directionToString(Direction.right), equals('Right'));
      });
    });

    group('Game Configuration', () {
      test('should validate game configuration', () {
        expect(
          ModelUtils.isValidGameConfig(
            maxPlayers: 4,
            gridWidth: 20,
            gridHeight: 20,
          ),
          isTrue,
        );

        // Invalid cases
        expect(
          ModelUtils.isValidGameConfig(
            maxPlayers: 1, // Too few
            gridWidth: 20,
            gridHeight: 20,
          ),
          isFalse,
        );

        expect(
          ModelUtils.isValidGameConfig(
            maxPlayers: 4,
            gridWidth: 5, // Too small
            gridHeight: 20,
          ),
          isFalse,
        );

        expect(
          ModelUtils.isValidGameConfig(
            maxPlayers: 4,
            gridWidth: 20,
            gridHeight: 60, // Too large
          ),
          isFalse,
        );
      });
    });

    group('Time Formatting', () {
      test('should format durations', () {
        expect(
          ModelUtils.formatDuration(const Duration(minutes: 2, seconds: 30)),
          equals('02:30'),
        );

        expect(
          ModelUtils.formatDuration(const Duration(seconds: 45)),
          equals('00:45'),
        );

        expect(
          ModelUtils.formatDuration(const Duration(minutes: 10, seconds: 5)),
          equals('10:05'),
        );
      });

      test('should format timestamps', () {
        final now = DateTime.now();

        expect(ModelUtils.formatTimestamp(now), equals('Just now'));

        expect(
          ModelUtils.formatTimestamp(now.subtract(const Duration(minutes: 30))),
          equals('30m ago'),
        );

        expect(
          ModelUtils.formatTimestamp(now.subtract(const Duration(hours: 2))),
          equals('2h ago'),
        );

        expect(
          ModelUtils.formatTimestamp(now.subtract(const Duration(days: 3))),
          equals('3d ago'),
        );
      });
    });
  });
}
