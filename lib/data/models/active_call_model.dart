import '../../domain/entities/active_call.dart';

class ActiveCallModel extends ActiveCall {
  ActiveCallModel({
    required super.channel,
    required super.caller,
    required super.callee,
    required super.duration,
  });

  factory ActiveCallModel.fromAmi(String amiEvent) {
    final lines = amiEvent.split(RegExp(r'\r\n|\n'));
    String channel = '', caller = '', callee = '', duration = '';
    for (final line in lines) {
      if (line.startsWith('Channel: ')) channel = line.substring(9);
      if (line.startsWith('CallerIDNum: ')) caller = line.substring(13);
      if (line.startsWith('ConnectedLineNum: ')) callee = line.substring(18);
      if (line.startsWith('Duration: ')) duration = line.substring(10);
    }
    return ActiveCallModel(
      channel: channel,
      caller: caller,
      callee: callee,
      duration: duration,
    );
  }
}
