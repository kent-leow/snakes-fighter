// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodImpl _$$FoodImplFromJson(Map<String, dynamic> json) => _$FoodImpl(
      position: _positionFromJson(json['position'] as Map<String, dynamic>),
      value: (json['value'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$FoodImplToJson(_$FoodImpl instance) =>
    <String, dynamic>{
      'position': _positionToJson(instance.position),
      'value': instance.value,
    };

_$SnakeImpl _$$SnakeImplFromJson(Map<String, dynamic> json) => _$SnakeImpl(
      positions: _positionsFromJson(json['positions'] as List),
      direction: $enumDecode(_$DirectionEnumMap, json['direction']),
      alive: json['alive'] as bool? ?? true,
      score: (json['score'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SnakeImplToJson(_$SnakeImpl instance) =>
    <String, dynamic>{
      'positions': _positionsToJson(instance.positions),
      'direction': _$DirectionEnumMap[instance.direction]!,
      'alive': instance.alive,
      'score': instance.score,
    };

const _$DirectionEnumMap = {
  Direction.up: 'up',
  Direction.down: 'down',
  Direction.left: 'left',
  Direction.right: 'right',
};

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      startedAt: DateTime.parse(json['startedAt'] as String),
      food: _foodFromJson(json['food'] as Map<String, dynamic>),
      snakes: _snakesFromJson(json['snakes'] as Map<String, dynamic>),
      winner: json['winner'] as String?,
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'startedAt': instance.startedAt.toIso8601String(),
      'food': _foodToJson(instance.food),
      'snakes': _snakesToJson(instance.snakes),
      'winner': instance.winner,
      'endedAt': instance.endedAt?.toIso8601String(),
    };
