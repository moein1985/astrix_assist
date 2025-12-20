import 'dart:math';

class MockDataGenerator {
  static String generateActiveChannel({
    required String extension,
    required String callee,
    required Duration duration,
  }) {
    return '''Event: CoreShowChannel
Channel: SIP/$extension-${_randomId()}
ChannelState: 6
ChannelStateDesc: Up
CallerIDNum: $extension
ConnectedLineNum: $callee
Duration: ${_formatDuration(duration)}
Context: internal
Exten: $callee
Application: Dial
''';
  }

  static String _randomId() {
    return Random().nextInt(999999).toString().padLeft(8, '0');
  }

  static String _formatDuration(Duration d) {
    return '${d.inHours.toString().padLeft(2, '0')}:'
           '${(d.inMinutes % 60).toString().padLeft(2, '0')}:'
           '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}