import 'package:equatable/equatable.dart';

class SystemResource extends Equatable {
  final String uptime;
  final String version;
  final String cpuLoad;
  final String freeMemory;
  final String totalMemory;
  final String freeHddSpace;
  final String totalHddSpace;
  final String architectureName;
  final String boardName;
  final String platform;

  const SystemResource({
    required this.uptime,
    required this.version,
    required this.cpuLoad,
    required this.freeMemory,
    required this.totalMemory,
    required this.freeHddSpace,
    required this.totalHddSpace,
    required this.architectureName,
    required this.boardName,
    required this.platform,
  });

  @override
  List<Object> get props => [
        uptime,
        version,
        cpuLoad,
        freeMemory,
        totalMemory,
        freeHddSpace,
        totalHddSpace,
        architectureName,
        boardName,
        platform,
      ];
}