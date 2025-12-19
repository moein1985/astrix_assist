class Extension {
  final String name;
  final String location;
  final String status;
  final bool isOnline;
  final int? latency;
  final bool isTrunk;

  Extension({
    required this.name,
    required this.location,
    required this.status,
    required this.isOnline,
    this.latency,
    required this.isTrunk,
  });
}