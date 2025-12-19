import '../../domain/entities/extension.dart';

class ExtensionModel extends Extension {
  ExtensionModel({
    required super.name,
    required super.location,
    required super.status,
    required super.isOnline,
    super.latency,
    required super.isTrunk,
  });

  factory ExtensionModel.fromAmi(String amiResponse) {
    // Parse AMI response for PeerEntry event
    // Example: Event: PeerEntry\r\nChanneltype: SIP\r\nObjectName: 1001\r\n...
    final lines = amiResponse.split(RegExp(r'\r\n|\n'));
    String name = '', location = '', status = '';
    for (var line in lines) {
      if (line.startsWith('ObjectName: ')) name = line.substring(12);
      if (line.startsWith('IPaddress: ')) location = line.substring(11);
      if (line.startsWith('Status: ')) status = line.substring(8);
    }

    bool isOnline = status.contains('OK');
    int? latency;
    if (isOnline) {
      final match = RegExp(r'\((\d+)\s*ms\)').firstMatch(status);
      if (match != null) {
        latency = int.tryParse(match.group(1) ?? '');
      }
    }

    // Heuristic: if name is not numeric, it's likely a trunk (e.g. "shatel-trunk")
    bool isTrunk = int.tryParse(name) == null;

    return ExtensionModel(
      name: name,
      location: location,
      status: status,
      isOnline: isOnline,
      latency: latency,
      isTrunk: isTrunk,
    );
  }
}