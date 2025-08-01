// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isReady: json['isReady'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? true,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'color': _$PlayerColorEnumMap[instance.color]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isReady': instance.isReady,
      'isConnected': instance.isConnected,
    };

const _$PlayerColorEnumMap = {
  PlayerColor.red: 'red',
  PlayerColor.blue: 'blue',
  PlayerColor.green: 'green',
  PlayerColor.yellow: 'yellow',
};
