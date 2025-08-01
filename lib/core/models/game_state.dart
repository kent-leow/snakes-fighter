import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'position.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

/// Represents food in the game.
@freezed
class Food with _$Food {
  const factory Food({
    @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
    required Position position,
    @Default(1) int value,
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
}

Position _positionFromJson(Map<String, dynamic> json) =>
    Position.fromJson(json);
Map<String, dynamic> _positionToJson(Position position) => position.toJson();

/// Represents a snake in the game.
@freezed
class Snake with _$Snake {
  const factory Snake({
    @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
    required List<Position> positions,
    required Direction direction,
    @Default(true) bool alive,
    @Default(0) int score,
  }) = _Snake;

  factory Snake.fromJson(Map<String, dynamic> json) => _$SnakeFromJson(json);
}

List<Position> _positionsFromJson(List<dynamic> json) {
  return json.map((e) => Position.fromJson(e as Map<String, dynamic>)).toList();
}

List<Map<String, dynamic>> _positionsToJson(List<Position> positions) {
  return positions.map((p) => p.toJson()).toList();
}

/// Represents the complete game state.
@freezed
class GameState with _$GameState {
  const factory GameState({
    required DateTime startedAt,
    @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson) required Food food,
    @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
    required Map<String, Snake> snakes,
    String? winner,
    DateTime? endedAt,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}

Food _foodFromJson(Map<String, dynamic> json) => Food.fromJson(json);
Map<String, dynamic> _foodToJson(Food food) => food.toJson();

Map<String, Snake> _snakesFromJson(Map<String, dynamic> json) {
  return json.map(
    (key, value) =>
        MapEntry(key, Snake.fromJson(value as Map<String, dynamic>)),
  );
}

Map<String, dynamic> _snakesToJson(Map<String, Snake> snakes) {
  return snakes.map((key, value) => MapEntry(key, value.toJson()));
}

/// Extension methods for GameState.
extension GameStateExtension on GameState {
  /// Checks if the game is active.
  bool get isActive => endedAt == null;

  /// Checks if the game has ended.
  bool get hasEnded => endedAt != null;

  /// Gets all alive snakes.
  Map<String, Snake> get aliveSnakes {
    return Map.fromEntries(snakes.entries.where((entry) => entry.value.alive));
  }

  /// Gets the number of alive snakes.
  int get aliveSnakeCount => aliveSnakes.length;
}

/// Extension methods for Snake.
extension SnakeExtension on Snake {
  /// Gets the head position of the snake.
  Position get head =>
      positions.isNotEmpty ? positions.first : const Position(0, 0);

  /// Gets the tail position of the snake.
  Position get tail =>
      positions.isNotEmpty ? positions.last : const Position(0, 0);

  /// Gets the body positions (excluding head).
  List<Position> get body => positions.length > 1 ? positions.sublist(1) : [];

  /// Checks if the snake occupies a given position.
  bool occupiesPosition(Position position) => positions.contains(position);

  /// Checks if the snake has collided with itself.
  bool get hasSelfCollision => positions.length != positions.toSet().length;

  /// Gets the next head position based on current direction.
  Position getNextHeadPosition() => head + direction.toPosition();
}
