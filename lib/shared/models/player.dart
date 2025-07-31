/// Base player model
class Player {
  const Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.isReady = false,
  });

  final String id;
  final String name;
  final bool isHost;
  final bool isReady;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isHost': isHost,
        'isReady': isReady,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        isHost: json['isHost'] as bool? ?? false,
        isReady: json['isReady'] as bool? ?? false,
      );

  Player copyWith({
    String? id,
    String? name,
    bool? isHost,
    bool? isReady,
  }) =>
      Player(
        id: id ?? this.id,
        name: name ?? this.name,
        isHost: isHost ?? this.isHost,
        isReady: isReady ?? this.isReady,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          isHost == other.isHost &&
          isReady == other.isReady;

  @override
  int get hashCode => Object.hash(id, name, isHost, isReady);

  @override
  String toString() =>
      'Player(id: $id, name: $name, isHost: $isHost, isReady: $isReady)';
}
