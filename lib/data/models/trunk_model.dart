import '../../domain/entities/trunk.dart';

class TrunkModel extends Trunk {
  TrunkModel({
    required super.name,
    required super.host,
    required super.status,
    required super.activeChannels,
    super.lastUpdate,
  });

  factory TrunkModel.fromAmi(String event) {
    final lines = event.split(RegExp('\\r\\n|\\n'));
    String name = '';
    String host = '';
    String status = 'Unknown';

    for (final line in lines) {
      if (line.startsWith('ChannelType: ')) {
        name = line.substring(13);
      } else if (line.startsWith('ObjectName: ')) {
        name = line.substring(12);
      } else if (line.startsWith('Peer: ')) {
        name = line.substring(6);
      } else if (line.startsWith('Host: ')) {
        host = line.substring(6);
      } else if (line.startsWith('Status: ')) {
        status = line.substring(8).split(' ').first;
      }
    }

    return TrunkModel(
      name: name,
      host: host,
      status: status,
      activeChannels: 0,
      lastUpdate: DateTime.now(),
    );
  }

  @override
  TrunkModel copyWith({
    String? name,
    String? host,
    String? status,
    int? activeChannels,
    DateTime? lastUpdate,
  }) {
    return TrunkModel(
      name: name ?? this.name,
      host: host ?? this.host,
      status: status ?? this.status,
      activeChannels: activeChannels ?? this.activeChannels,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
