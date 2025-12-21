# AMI Listen Client

کلاینت TCP مستقیم برای ارتباط با Asterisk AMI جهت پیاده‌سازی قابلیت‌های Listen Live و Playback.

## ویژگی‌ها

- ✅ اتصال مستقیم TCP به Asterisk AMI (پورت 5038)
- ✅ احراز هویت با username/password
- ✅ ارسال دستورات AMI (Originate, Hangup, ControlPlayback, etc.)
- ✅ دریافت Event های AMI به صورت Real-time
- ✅ پشتیبانی از ChanSpy برای Listen Live
- ✅ پشتیبانی از Playback برای پخش ضبط‌ها
- ✅ کنترل پخش (Pause, Resume, Forward, Reverse, Stop)
- ✅ مدیریت خودکار connection و reconnection
- ✅ Mock server برای تست محلی

## نحوه استفاده

### 1. ایجاد Client

```dart
import 'package:astrix_assist/core/ami_listen_client.dart';

final client = AmiListenClient(
  host: '192.168.85.88',
  port: 5038,
  username: 'moein_api',
  secret: '123456',
);
```

### 2. اتصال به AMI

```dart
await client.connect();
// Client automatically logs in after connection
```

### 3. گوش دادن به Event ها

```dart
client.eventsStream.listen((event) {
  final eventType = event['Event'];
  
  switch (eventType) {
    case 'ChanSpyStart':
      print('گوش دادن شروع شد: ${event['SpyerChannel']} -> ${event['SpyeeChannel']}');
      break;
    case 'ChanSpyStop':
      print('گوش دادن متوقف شد');
      break;
    case 'PlaybackStart':
      print('پخش شروع شد: ${event['Playback']}');
      break;
    case 'PlaybackFinish':
      print('پخش تمام شد');
      break;
  }
});
```

### 4. شروع Listen (ChanSpy)

```dart
final actionId = await client.originateListen(
  targetChannel: 'SIP/202',        // کانالی که می‌خواهیم گوش دهیم
  listenerExtension: '201',        // داخلی که گوش می‌دهد
  whisperMode: false,              // آیا listener بتواند صحبت کند؟
  bargeMode: false,                // آیا listener بتواند وارد مکالمه شود؟
);

print('Listen started with ActionID: $actionId');
```

#### انواع Mode های Listen:

- **Normal Mode** (whisper=false, barge=false): فقط گوش دادن
- **Whisper Mode** (whisper=true): گوش دادن + صحبت با یک طرف
- **Barge Mode** (barge=true): گوش دادن + صحبت با هر دو طرف

### 5. شروع Playback

```dart
final actionId = await client.originatePlayback(
  targetExtension: '201',
  recordingPath: '/var/spool/asterisk/monitor/recording-2024-01-15.wav',
  allowControl: true,  // اجازه کنترل پخش (pause, forward, etc.)
);

print('Playback started with ActionID: $actionId');
```

### 6. کنترل پخش

```dart
// مکث
await client.controlPlayback(
  channel: 'Local/201@playback-context',
  command: 'pause',
);

// از سر گیری
await client.controlPlayback(
  channel: 'Local/201@playback-context',
  command: 'restart',
);

// جلو بردن (3 ثانیه)
await client.controlPlayback(
  channel: 'Local/201@playback-context',
  command: 'forward',
);

// عقب بردن (3 ثانیه)
await client.controlPlayback(
  channel: 'Local/201@playback-context',
  command: 'reverse',
);

// توقف کامل
await client.controlPlayback(
  channel: 'Local/201@playback-context',
  command: 'stop',
);
```

### 7. قطع تماس (Hangup)

```dart
await client.hangup('Local/201@spy-context');
```

### 8. دریافت لیست کانال‌های فعال

```dart
final channels = await client.getActiveChannels();
for (final channel in channels) {
  print('${channel['Channel']}: ${channel['CallerIDName']} -> ${channel['ConnectedLineName']}');
}
```

### 9. قطع اتصال

```dart
await client.disconnect();
// یا
client.dispose(); // قطع اتصال + پاک کردن منابع
```

## تست با Mock Server

برای تست بدون نیاز به سرور واقعی Asterisk:

### 1. اجرای Mock Server

```bash
dart tools/mock_ami_server.dart
```

خروجی:
```
🚀 Mock AMI Server started on port 5038
📡 Waiting for connections...
```

### 2. اجرای تست Client

```bash
# تست با Mock Server
dart run tools/test_ami_client.dart

# تست با Isabel واقعی
dart run tools/test_ami_client.dart --real
```

## تست در Flutter

یک صفحه مثال برای تست در Flutter فراهم شده است:

```dart
import 'package:astrix_assist/presentation/pages/ami_listen_example.dart';

// Add to your routes
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AmiListenExample()),
);
```

## رویدادهای AMI (Events)

### رویدادهای ChanSpy

#### ChanSpyStart
زمانی که گوش دادن شروع می‌شود.

```dart
{
  'Event': 'ChanSpyStart',
  'SpyerChannel': 'Local/201@spy-context',
  'SpyeeChannel': 'SIP/202-00000001',
  'Uniqueid': '1234567890.123',
}
```

#### ChanSpyStop
زمانی که گوش دادن متوقف می‌شود.

```dart
{
  'Event': 'ChanSpyStop',
  'SpyerChannel': 'Local/201@spy-context',
  'Uniqueid': '1234567890.123',
}
```

### رویدادهای Playback

#### PlaybackStart
زمانی که پخش شروع می‌شود.

```dart
{
  'Event': 'PlaybackStart',
  'Channel': 'Local/201@playback-context',
  'Playback': '/var/spool/asterisk/monitor/recording',
  'Uniqueid': '1234567890.123',
}
```

#### PlaybackFinish
زمانی که پخش تمام می‌شود.

```dart
{
  'Event': 'PlaybackFinish',
  'Channel': 'Local/201@playback-context',
  'Playback': '/var/spool/asterisk/monitor/recording',
  'Uniqueid': '1234567890.123',
}
```

### رویدادهای عمومی

#### OriginateResponse
پاسخ به دستور Originate.

```dart
{
  'Event': 'OriginateResponse',
  'ActionID': 'listen_1234567890',
  'Response': 'Success',
  'Channel': 'Local/201@spy-context',
  'Reason': '0',
}
```

#### Hangup
زمانی که تماس قطع می‌شود.

```dart
{
  'Event': 'Hangup',
  'Channel': 'Local/201@spy-context',
  'Cause': '16',
  'Cause-txt': 'Normal Clearing',
  'Uniqueid': '1234567890.123',
}
```

## پیکربندی Asterisk

برای استفاده از این کلاینت، باید context های مربوطه را در Asterisk تنظیم کنید.

### extensions.conf

```ini
[spy-context]
; Context for ChanSpy (Listen)
exten => _X.,1,NoOp(Starting ChanSpy for ${EXTEN})
 same => n,Answer()
 same => n,ChanSpy(${EXTEN},${SPY_OPTIONS})
 same => n,Hangup()

[playback-context]
; Context for Playback
exten => _X.,1,NoOp(Playing recording for ${EXTEN})
 same => n,Answer()
 same => n,ControlPlayback(${PLAYBACK_FILE})
 same => n,Hangup()
```

### manager.conf

```ini
[moein_api]
secret = 123456
deny = 0.0.0.0/0.0.0.0
permit = 192.168.85.0/255.255.255.0
read = all
write = all
```

## مدیریت خطا

همه متدها ممکن است Exception پرتاب کنند:

```dart
try {
  await client.connect();
  await client.originateListen(
    targetChannel: 'SIP/202',
    listenerExtension: '201',
  );
} catch (e) {
  print('خطا: $e');
  // مدیریت خطا
}
```

## توصیه‌های بهینه‌سازی

### 1. استفاده از Connection Pool

برای برنامه‌های بزرگ، از یک client مشترک استفاده کنید:

```dart
class AmiService {
  static final AmiListenClient _client = AmiListenClient(
    host: AppConfig.defaultAmiHost,
    port: AppConfig.defaultAmiPort,
    username: AppConfig.defaultAmiUsername,
    secret: AppConfig.defaultAmiSecret,
  );
  
  static AmiListenClient get client => _client;
}
```

### 2. Timeout Management

برای جلوگیری از hang کردن، همیشه timeout تنظیم کنید:

```dart
try {
  await client.originateListen(...)
    .timeout(Duration(seconds: 10));
} on TimeoutException {
  print('عملیات timeout شد');
}
```

### 3. Event Filtering

برای بهبود performance، event های غیرضروری را فیلتر کنید:

```dart
client.eventsStream
  .where((event) => ['ChanSpyStart', 'ChanSpyStop', 'PlaybackStart', 'PlaybackFinish'].contains(event['Event']))
  .listen((event) {
    // فقط event های مهم
  });
```

## مثال کامل

```dart
import 'package:astrix_assist/core/ami_listen_client.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() async {
  // ایجاد client
  final client = AmiListenClient(
    host: AppConfig.defaultAmiHost,
    port: AppConfig.defaultAmiPort,
    username: AppConfig.defaultAmiUsername,
    secret: AppConfig.defaultAmiSecret,
  );

  // گوش دادن به event ها
  client.eventsStream.listen((event) {
    print('Event: ${event['Event']}');
  });

  try {
    // اتصال
    await client.connect();
    print('Connected!');

    // شروع listen
    final listenId = await client.originateListen(
      targetChannel: 'SIP/202',
      listenerExtension: '201',
    );
    print('Listen started: $listenId');

    // صبر 10 ثانیه
    await Future.delayed(Duration(seconds: 10));

    // قطع listen
    await client.hangup('Local/201@spy-context');
    print('Listen stopped');

    // شروع playback
    final playbackId = await client.originatePlayback(
      targetExtension: '201',
      recordingPath: '/var/spool/asterisk/monitor/test.wav',
    );
    print('Playback started: $playbackId');

    // مکث بعد از 3 ثانیه
    await Future.delayed(Duration(seconds: 3));
    await client.controlPlayback(
      channel: 'Local/201@playback-context',
      command: 'pause',
    );
    print('Paused');

    // از سر گیری بعد از 2 ثانیه
    await Future.delayed(Duration(seconds: 2));
    await client.controlPlayback(
      channel: 'Local/201@playback-context',
      command: 'restart',
    );
    print('Resumed');

    // صبر تا تمام شدن
    await Future.delayed(Duration(seconds: 10));

  } catch (e) {
    print('Error: $e');
  } finally {
    // قطع اتصال
    await client.disconnect();
    client.dispose();
  }
}
```

## Troubleshooting

### خطای "Connection refused"
- بررسی کنید که Asterisk در حال اجراست
- بررسی کنید که پورت 5038 باز است
- فایروال را بررسی کنید

### خطای "Authentication failed"
- username و password را بررسی کنید
- تنظیمات manager.conf را بررسی کنید
- مجوزهای permit/deny را بررسی کنید

### خطای "Originate failed"
- context ها را در extensions.conf بررسی کنید
- وضعیت کانال هدف را بررسی کنید
- لاگ های Asterisk را بررسی کنید: `asterisk -rvvv`

### Event ها دریافت نمی‌شوند
- بررسی کنید که به eventsStream subscribe کرده‌اید
- بررسی کنید که دستورات با موفقیت اجرا شده‌اند
- تنظیمات AMI را بررسی کنید (read = all)

## مستندات بیشتر

- [Asterisk AMI Documentation](docs/asterisk_ami_call_listening.md)
- [Deployment Guide](docs/deployment_guide.md)
- [Tools README](tools/README.md)

## لایسنس

This project is part of Astrix Assist application.
