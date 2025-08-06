// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get roomCode => throw _privateConstructorUsedError;
  String get hostId => throw _privateConstructorUsedError;
  RoomStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get maxPlayers => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
  Map<String, Player> get players => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
  GameState? get gameState => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call(
      {String id,
      String roomCode,
      String hostId,
      RoomStatus status,
      DateTime createdAt,
      int maxPlayers,
      @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
      Map<String, Player> players,
      @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
      GameState? gameState});

  $GameStateCopyWith<$Res>? get gameState;
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomCode = null,
    Object? hostId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? maxPlayers = null,
    Object? players = null,
    Object? gameState = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomCode: null == roomCode
          ? _value.roomCode
          : roomCode // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as Map<String, Player>,
      gameState: freezed == gameState
          ? _value.gameState
          : gameState // ignore: cast_nullable_to_non_nullable
              as GameState?,
    ) as $Val);
  }

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameStateCopyWith<$Res>? get gameState {
    if (_value.gameState == null) {
      return null;
    }

    return $GameStateCopyWith<$Res>(_value.gameState!, (value) {
      return _then(_value.copyWith(gameState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
          _$RoomImpl value, $Res Function(_$RoomImpl) then) =
      __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String roomCode,
      String hostId,
      RoomStatus status,
      DateTime createdAt,
      int maxPlayers,
      @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
      Map<String, Player> players,
      @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
      GameState? gameState});

  @override
  $GameStateCopyWith<$Res>? get gameState;
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomCode = null,
    Object? hostId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? maxPlayers = null,
    Object? players = null,
    Object? gameState = freezed,
  }) {
    return _then(_$RoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomCode: null == roomCode
          ? _value.roomCode
          : roomCode // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as Map<String, Player>,
      gameState: freezed == gameState
          ? _value.gameState
          : gameState // ignore: cast_nullable_to_non_nullable
              as GameState?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl(
      {required this.id,
      required this.roomCode,
      required this.hostId,
      required this.status,
      required this.createdAt,
      this.maxPlayers = 4,
      @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
      final Map<String, Player> players = const {},
      @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
      this.gameState})
      : _players = players;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String roomCode;
  @override
  final String hostId;
  @override
  final RoomStatus status;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int maxPlayers;
  final Map<String, Player> _players;
  @override
  @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
  Map<String, Player> get players {
    if (_players is EqualUnmodifiableMapView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_players);
  }

  @override
  @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
  final GameState? gameState;

  @override
  String toString() {
    return 'Room(id: $id, roomCode: $roomCode, hostId: $hostId, status: $status, createdAt: $createdAt, maxPlayers: $maxPlayers, players: $players, gameState: $gameState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomCode, roomCode) ||
                other.roomCode == roomCode) &&
            (identical(other.hostId, hostId) || other.hostId == hostId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.gameState, gameState) ||
                other.gameState == gameState));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      roomCode,
      hostId,
      status,
      createdAt,
      maxPlayers,
      const DeepCollectionEquality().hash(_players),
      gameState);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(
      this,
    );
  }
}

abstract class _Room implements Room {
  const factory _Room(
      {required final String id,
      required final String roomCode,
      required final String hostId,
      required final RoomStatus status,
      required final DateTime createdAt,
      final int maxPlayers,
      @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
      final Map<String, Player> players,
      @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
      final GameState? gameState}) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get roomCode;
  @override
  String get hostId;
  @override
  RoomStatus get status;
  @override
  DateTime get createdAt;
  @override
  int get maxPlayers;
  @override
  @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
  Map<String, Player> get players;
  @override
  @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
  GameState? get gameState;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
