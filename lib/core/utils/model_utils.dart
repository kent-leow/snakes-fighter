import 'dart:math';

import '../models/enums.dart';
import '../models/position.dart';

/// Utility functions for working with data models.
class ModelUtils {
  ModelUtils._();

  /// Generates a random room code.
  static String generateRoomCode({int length = 6}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Validates a room code format.
  static bool isValidRoomCode(String code) {
    if (code.isEmpty || code.length != 6) return false;
    return RegExp(r'^[A-Z0-9]{6}$').hasMatch(code);
  }

  /// Generates a random position within bounds.
  static Position generateRandomPosition({
    required int maxX,
    required int maxY,
    int minX = 0,
    int minY = 0,
  }) {
    final random = Random();
    final x = minX + random.nextInt(maxX - minX);
    final y = minY + random.nextInt(maxY - minY);
    return Position(x, y);
  }

  /// Gets the next available player color.
  static PlayerColor? getNextAvailableColor(List<PlayerColor> usedColors) {
    for (final color in PlayerColor.values) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }
    return null; // All colors are used
  }

  /// Validates a display name.
  static bool isValidDisplayName(String name) {
    if (name.isEmpty || name.length > 20) return false;
    return RegExp(r'^[a-zA-Z0-9_\-\s]+$').hasMatch(name);
  }

  /// Sanitizes a display name.
  static String sanitizeDisplayName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_\-\s]'), '');
    final maxLength = min(cleaned.length, 20);
    return cleaned.substring(0, maxLength);
  }

  /// Calculates the distance between two positions.
  static double calculateDistance(Position a, Position b) {
    return a.distanceTo(b);
  }

  /// Checks if a position is within bounds.
  static bool isPositionInBounds(
    Position position, {
    required int width,
    required int height,
  }) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < height;
  }

  /// Generates initial snake positions for multiple players.
  static List<Position> generateInitialSnakePositions({
    required int playerCount,
    required int gridWidth,
    required int gridHeight,
    int snakeLength = 3,
  }) {
    final positions = <Position>[];
    final spacing = gridWidth ~/ (playerCount + 1);
    final y = gridHeight ~/ 2;

    for (int i = 0; i < playerCount; i++) {
      final x = spacing * (i + 1);
      positions.add(Position(x, y));
    }

    return positions;
  }

  /// Converts a Direction to a human-readable string.
  static String directionToString(Direction direction) {
    switch (direction) {
      case Direction.up:
        return 'Up';
      case Direction.down:
        return 'Down';
      case Direction.left:
        return 'Left';
      case Direction.right:
        return 'Right';
    }
  }

  /// Converts a PlayerColor to a hex color string.
  static String playerColorToHex(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return '#FF4444';
      case PlayerColor.blue:
        return '#4444FF';
      case PlayerColor.green:
        return '#44FF44';
      case PlayerColor.yellow:
        return '#FFFF44';
    }
  }

  /// Converts a PlayerColor to a display name.
  static String playerColorToDisplayName(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return 'Red';
      case PlayerColor.blue:
        return 'Blue';
      case PlayerColor.green:
        return 'Green';
      case PlayerColor.yellow:
        return 'Yellow';
    }
  }

  /// Validates game configuration.
  static bool isValidGameConfig({
    required int maxPlayers,
    required int gridWidth,
    required int gridHeight,
  }) {
    return maxPlayers >= 2 &&
        maxPlayers <= 4 &&
        gridWidth >= 10 &&
        gridHeight >= 10 &&
        gridWidth <= 50 &&
        gridHeight <= 50;
  }

  /// Formats a duration for display.
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a timestamp for display.
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
