class Trunk {
  final String name;
  final String host;
  final String status; // Registered, Unregistered, Unknown
  final int activeChannels;
  final DateTime? lastUpdate;

  Trunk({
    required this.name,
    required this.host,
    required this.status,
    required this.activeChannels,
    this.lastUpdate,
  });

  bool get isRegistered => status.toLowerCase() == 'registered';

  Trunk copyWith({
    String? name,
    String? host,
    String? status,
    int? activeChannels,
    DateTime? lastUpdate,
  }) {
    return Trunk(
      name: name ?? this.name,
      host: host ?? this.host,
      status: status ?? this.status,
      activeChannels: activeChannels ?? this.activeChannels,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
