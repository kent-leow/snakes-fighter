// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  roomCode: json['roomCode'] as String,
  hostId: json['hostId'] as String,
  status: $enumDecode(_$RoomStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 4,
  players: json['players'] == null
      ? const {}
      : _playersFromJson(json['players'] as Map<String, dynamic>),
  gameState: _gameStateFromJson(json['gameState'] as Map<String, dynamic>?),
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomCode': instance.roomCode,
      'hostId': instance.hostId,
      'status': _$RoomStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'maxPlayers': instance.maxPlayers,
      'players': _playersToJson(instance.players),
      'gameState': _gameStateToJson(instance.gameState),
    };

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'waiting',
  RoomStatus.active: 'active',
  RoomStatus.ended: 'ended',
};
