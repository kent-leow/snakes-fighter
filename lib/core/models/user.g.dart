// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
      lastActive: DateTime.parse(json['lastActive'] as String),
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'gamesPlayed': instance.gamesPlayed,
      'gamesWon': instance.gamesWon,
      'lastActive': instance.lastActive.toIso8601String(),
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'isAnonymous': instance.isAnonymous,
      'stats': instance.stats,
    };
