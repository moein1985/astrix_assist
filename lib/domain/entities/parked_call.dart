class ParkedCall {
  final String exten;
  final String channel;
  final String channelState;
  final String channelStateDesc;
  final String callerIdNum;
  final String callerIdName;
  final DateTime parkDate;
  final int parkTimeout;

  ParkedCall({
    required this.exten,
    required this.channel,
    required this.channelState,
    required this.channelStateDesc,
    required this.callerIdNum,
    required this.callerIdName,
    required this.parkDate,
    required this.parkTimeout,
  });

  int get secondsRemaining {
    final elapsed = DateTime.now().difference(parkDate).inSeconds;
    return max(0, parkTimeout - elapsed);
  }

  ParkedCall copyWith({
    String? exten,
    String? channel,
    String? channelState,
    String? channelStateDesc,
    String? callerIdNum,
    String? callerIdName,
    DateTime? parkDate,
    int? parkTimeout,
  }) {
    return ParkedCall(
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

int max(int a, int b) => a > b ? a : b;
