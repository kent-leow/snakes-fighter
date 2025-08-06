// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Food _$FoodFromJson(Map<String, dynamic> json) {
  return _Food.fromJson(json);
}

/// @nodoc
mixin _$Food {
  @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
  Position get position => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;

  /// Serializes this Food to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Food
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodCopyWith<Food> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodCopyWith<$Res> {
  factory $FoodCopyWith(Food value, $Res Function(Food) then) =
      _$FoodCopyWithImpl<$Res, Food>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
    Position position,
    int value,
  });
}

/// @nodoc
class _$FoodCopyWithImpl<$Res, $Val extends Food>
    implements $FoodCopyWith<$Res> {
  _$FoodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Food
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? position = null, Object? value = null}) {
    return _then(
      _value.copyWith(
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as Position,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FoodImplCopyWith<$Res> implements $FoodCopyWith<$Res> {
  factory _$$FoodImplCopyWith(
    _$FoodImpl value,
    $Res Function(_$FoodImpl) then,
  ) = __$$FoodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
    Position position,
    int value,
  });
}

/// @nodoc
class __$$FoodImplCopyWithImpl<$Res>
    extends _$FoodCopyWithImpl<$Res, _$FoodImpl>
    implements _$$FoodImplCopyWith<$Res> {
  __$$FoodImplCopyWithImpl(_$FoodImpl _value, $Res Function(_$FoodImpl) _then)
    : super(_value, _then);

  /// Create a copy of Food
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? position = null, Object? value = null}) {
    return _then(
      _$FoodImpl(
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as Position,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodImpl implements _Food {
  const _$FoodImpl({
    @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
    required this.position,
    this.value = 1,
  });

  factory _$FoodImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodImplFromJson(json);

  @override
  @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
  final Position position;
  @override
  @JsonKey()
  final int value;

  @override
  String toString() {
    return 'Food(position: $position, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, value);

  /// Create a copy of Food
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodImplCopyWith<_$FoodImpl> get copyWith =>
      __$$FoodImplCopyWithImpl<_$FoodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodImplToJson(this);
  }
}

abstract class _Food implements Food {
  const factory _Food({
    @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
    required final Position position,
    final int value,
  }) = _$FoodImpl;

  factory _Food.fromJson(Map<String, dynamic> json) = _$FoodImpl.fromJson;

  @override
  @JsonKey(fromJson: _positionFromJson, toJson: _positionToJson)
  Position get position;
  @override
  int get value;

  /// Create a copy of Food
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodImplCopyWith<_$FoodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Snake _$SnakeFromJson(Map<String, dynamic> json) {
  return _Snake.fromJson(json);
}

/// @nodoc
mixin _$Snake {
  @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
  List<Position> get positions => throw _privateConstructorUsedError;
  Direction get direction => throw _privateConstructorUsedError;
  bool get alive => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Serializes this Snake to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Snake
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnakeCopyWith<Snake> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnakeCopyWith<$Res> {
  factory $SnakeCopyWith(Snake value, $Res Function(Snake) then) =
      _$SnakeCopyWithImpl<$Res, Snake>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
    List<Position> positions,
    Direction direction,
    bool alive,
    int score,
  });
}

/// @nodoc
class _$SnakeCopyWithImpl<$Res, $Val extends Snake>
    implements $SnakeCopyWith<$Res> {
  _$SnakeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Snake
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? positions = null,
    Object? direction = null,
    Object? alive = null,
    Object? score = null,
  }) {
    return _then(
      _value.copyWith(
            positions: null == positions
                ? _value.positions
                : positions // ignore: cast_nullable_to_non_nullable
                      as List<Position>,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as Direction,
            alive: null == alive
                ? _value.alive
                : alive // ignore: cast_nullable_to_non_nullable
                      as bool,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnakeImplCopyWith<$Res> implements $SnakeCopyWith<$Res> {
  factory _$$SnakeImplCopyWith(
    _$SnakeImpl value,
    $Res Function(_$SnakeImpl) then,
  ) = __$$SnakeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
    List<Position> positions,
    Direction direction,
    bool alive,
    int score,
  });
}

/// @nodoc
class __$$SnakeImplCopyWithImpl<$Res>
    extends _$SnakeCopyWithImpl<$Res, _$SnakeImpl>
    implements _$$SnakeImplCopyWith<$Res> {
  __$$SnakeImplCopyWithImpl(
    _$SnakeImpl _value,
    $Res Function(_$SnakeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Snake
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? positions = null,
    Object? direction = null,
    Object? alive = null,
    Object? score = null,
  }) {
    return _then(
      _$SnakeImpl(
        positions: null == positions
            ? _value._positions
            : positions // ignore: cast_nullable_to_non_nullable
                  as List<Position>,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as Direction,
        alive: null == alive
            ? _value.alive
            : alive // ignore: cast_nullable_to_non_nullable
                  as bool,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnakeImpl implements _Snake {
  const _$SnakeImpl({
    @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
    required final List<Position> positions,
    required this.direction,
    this.alive = true,
    this.score = 0,
  }) : _positions = positions;

  factory _$SnakeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnakeImplFromJson(json);

  final List<Position> _positions;
  @override
  @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
  List<Position> get positions {
    if (_positions is EqualUnmodifiableListView) return _positions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_positions);
  }

  @override
  final Direction direction;
  @override
  @JsonKey()
  final bool alive;
  @override
  @JsonKey()
  final int score;

  @override
  String toString() {
    return 'Snake(positions: $positions, direction: $direction, alive: $alive, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnakeImpl &&
            const DeepCollectionEquality().equals(
              other._positions,
              _positions,
            ) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.alive, alive) || other.alive == alive) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_positions),
    direction,
    alive,
    score,
  );

  /// Create a copy of Snake
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnakeImplCopyWith<_$SnakeImpl> get copyWith =>
      __$$SnakeImplCopyWithImpl<_$SnakeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnakeImplToJson(this);
  }
}

abstract class _Snake implements Snake {
  const factory _Snake({
    @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
    required final List<Position> positions,
    required final Direction direction,
    final bool alive,
    final int score,
  }) = _$SnakeImpl;

  factory _Snake.fromJson(Map<String, dynamic> json) = _$SnakeImpl.fromJson;

  @override
  @JsonKey(fromJson: _positionsFromJson, toJson: _positionsToJson)
  List<Position> get positions;
  @override
  Direction get direction;
  @override
  bool get alive;
  @override
  int get score;

  /// Create a copy of Snake
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnakeImplCopyWith<_$SnakeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return _GameState.fromJson(json);
}

/// @nodoc
mixin _$GameState {
  DateTime get startedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson)
  Food get food => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
  Map<String, Snake> get snakes => throw _privateConstructorUsedError;
  String? get winner => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    DateTime startedAt,
    @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson) Food food,
    @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
    Map<String, Snake> snakes,
    String? winner,
    DateTime? endedAt,
  });

  $FoodCopyWith<$Res> get food;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? food = null,
    Object? snakes = null,
    Object? winner = freezed,
    Object? endedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            food: null == food
                ? _value.food
                : food // ignore: cast_nullable_to_non_nullable
                      as Food,
            snakes: null == snakes
                ? _value.snakes
                : snakes // ignore: cast_nullable_to_non_nullable
                      as Map<String, Snake>,
            winner: freezed == winner
                ? _value.winner
                : winner // ignore: cast_nullable_to_non_nullable
                      as String?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodCopyWith<$Res> get food {
    return $FoodCopyWith<$Res>(_value.food, (value) {
      return _then(_value.copyWith(food: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime startedAt,
    @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson) Food food,
    @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
    Map<String, Snake> snakes,
    String? winner,
    DateTime? endedAt,
  });

  @override
  $FoodCopyWith<$Res> get food;
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? food = null,
    Object? snakes = null,
    Object? winner = freezed,
    Object? endedAt = freezed,
  }) {
    return _then(
      _$GameStateImpl(
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        food: null == food
            ? _value.food
            : food // ignore: cast_nullable_to_non_nullable
                  as Food,
        snakes: null == snakes
            ? _value._snakes
            : snakes // ignore: cast_nullable_to_non_nullable
                  as Map<String, Snake>,
        winner: freezed == winner
            ? _value.winner
            : winner // ignore: cast_nullable_to_non_nullable
                  as String?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateImpl implements _GameState {
  const _$GameStateImpl({
    required this.startedAt,
    @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson) required this.food,
    @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
    required final Map<String, Snake> snakes,
    this.winner,
    this.endedAt,
  }) : _snakes = snakes;

  factory _$GameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateImplFromJson(json);

  @override
  final DateTime startedAt;
  @override
  @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson)
  final Food food;
  final Map<String, Snake> _snakes;
  @override
  @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
  Map<String, Snake> get snakes {
    if (_snakes is EqualUnmodifiableMapView) return _snakes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_snakes);
  }

  @override
  final String? winner;
  @override
  final DateTime? endedAt;

  @override
  String toString() {
    return 'GameState(startedAt: $startedAt, food: $food, snakes: $snakes, winner: $winner, endedAt: $endedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.food, food) || other.food == food) &&
            const DeepCollectionEquality().equals(other._snakes, _snakes) &&
            (identical(other.winner, winner) || other.winner == winner) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    startedAt,
    food,
    const DeepCollectionEquality().hash(_snakes),
    winner,
    endedAt,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateImplToJson(this);
  }
}

abstract class _GameState implements GameState {
  const factory _GameState({
    required final DateTime startedAt,
    @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson)
    required final Food food,
    @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
    required final Map<String, Snake> snakes,
    final String? winner,
    final DateTime? endedAt,
  }) = _$GameStateImpl;

  factory _GameState.fromJson(Map<String, dynamic> json) =
      _$GameStateImpl.fromJson;

  @override
  DateTime get startedAt;
  @override
  @JsonKey(fromJson: _foodFromJson, toJson: _foodToJson)
  Food get food;
  @override
  @JsonKey(fromJson: _snakesFromJson, toJson: _snakesToJson)
  Map<String, Snake> get snakes;
  @override
  String? get winner;
  @override
  DateTime? get endedAt;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
