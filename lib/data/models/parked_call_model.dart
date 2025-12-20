import '../../domain/entities/parked_call.dart';

class ParkedCallModel extends ParkedCall {
  ParkedCallModel({
    required super.exten,
    required super.channel,
    required super.channelState,
    required super.channelStateDesc,
    required super.callerIdNum,
    required super.callerIdName,
    required super.parkDate,
    required super.parkTimeout,
  });

  factory ParkedCallModel.fromAmi(String event) {
    final lines = event.split(RegExp('\\r\\n|\\n'));
    String exten = '';
    String channel = '';
    String channelState = '';
    String channelStateDesc = '';
    String callerIdNum = '';
    String callerIdName = '';
    int parkTimeout = 45;

    for (final line in lines) {
      if (line.startsWith('Exten: ')) {
        exten = line.substring(7);
      } else if (line.startsWith('Channel: ')) {
        channel = line.substring(9);
      } else if (line.startsWith('ChannelState: ')) {
        channelState = line.substring(14);
      } else if (line.startsWith('ChannelStateDesc: ')) {
        channelStateDesc = line.substring(18);
      } else if (line.startsWith('CallerIDNum: ')) {
        callerIdNum = line.substring(13);
      } else if (line.startsWith('CallerIDName: ')) {
        callerIdName = line.substring(14);
      } else if (line.startsWith('ParkTimeout: ')) {
        parkTimeout = int.tryParse(line.substring(13)) ?? 45;
      }
    }

    return ParkedCallModel(
      exten: exten,
      channel: channel,
      channelState: channelState,
      channelStateDesc: channelStateDesc,
      callerIdNum: callerIdNum,
      callerIdName: callerIdName,
      parkDate: DateTime.now(),
      parkTimeout: parkTimeout,
    );
  }

  @override
  ParkedCallModel copyWith({
    String? exten,
    String? channel,
    String? channelState,
    String? channelStateDesc,
    String? callerIdNum,
    String? callerIdName,
    DateTime? parkDate,
    int? parkTimeout,
  }) {
    return ParkedCallModel(
      exten: exten ?? this.exten,
      channel: channel ?? this.channel,
      channelState: channelState ?? this.channelState,
      channelStateDesc: channelStateDesc ?? this.channelStateDesc,
      callerIdNum: callerIdNum ?? this.callerIdNum,
      callerIdName: callerIdName ?? this.callerIdName,
      parkDate: parkDate ?? this.parkDate,
      parkTimeout: parkTimeout ?? this.parkTimeout,
    );
  }
}
