class MockData {
  static const List<Map<String, String>> mockSipPeers = [
    {
      'Event': 'PeerEntry',
      'ObjectName': '101',
      'IPaddress': '192.168.1.10',
      'IPport': '5060',
      'Status': 'OK (25 ms)',
      'Dynamic': 'yes',
    },
    {
      'Event': 'PeerEntry',
      'ObjectName': '102',
      'IPaddress': '192.168.1.11',
      'IPport': '5060',
      'Status': 'OK (30 ms)',
      'Dynamic': 'yes',
    },
    {
      'Event': 'PeerEntry',
      'ObjectName': '103',
      'IPaddress': '-none-',
      'IPport': '0',
      'Status': 'UNREACHABLE',
      'Dynamic': 'yes',
    },
  ];

  static const List<String> mockActiveChannels = [
    '''Event: CoreShowChannel
Channel: SIP/101-00000123
ChannelState: 6
ChannelStateDesc: Up
CallerIDNum: 101
ConnectedLineNum: 102
Duration: 00:03:25
Context: internal
Exten: 102
Application: Dial
''',
    '''Event: CoreShowChannel
Channel: SIP/103-00000124
ChannelState: 4
ChannelStateDesc: Ring
CallerIDNum: 103
ConnectedLineNum:
Duration: 00:00:05
Context: internal
Exten: 104
Application: Dial
''',
    // این یکی باید فیلتر شود (Local channel)
    '''Event: CoreShowChannel
Channel: Local/s@voicemail-00000125;1
ChannelState: 6
ChannelStateDesc: Up
CallerIDNum:
ConnectedLineNum:
Duration: 00:00:12
Context: voicemail
Exten: s
Application: VoiceMailMain
''',
  ];

  static const List<String> mockQueueStatus = [
    '''Event: QueueParams
Queue: support
Completed: 45
Abandoned: 3
Calls: 2
Holdtime: 35
TalkTime: 180
''',
    '''Event: QueueMember
Queue: support
Name: SIP/101
Status: 1
Paused: 0
CallsTaken: 12
''',
    '''Event: QueueMember
Queue: support
Name: SIP/102
Status: 2
Paused: 0
CallsTaken: 15
''',
  ];
}