# 🗺️ نقشه راه جامع توسعه Astrix Assist

## 📋 خلاصه اجرایی

این سند نقشه راه جامعی برای بازسازی معماری برنامه Astrix Assist است. هدف اصلی:

1. **حذف Backend Proxy** - استفاده مستقیم از AMI
2. **دانلود ضبط‌ها با SSH/SCP** - بجای وب‌سرور
3. **اضافه کردن SIP Phone** - برای تماس و شنود
4. **بهبود داشبورد** - منوهای کاربرپسند

---

## 🏗️ معماری فعلی vs معماری جدید

### معماری فعلی (❌ قدیمی)
```
┌─────────────┐     HTTP      ┌────────────────┐     TCP      ┌─────────────┐
│  Flutter    │──────────────▶│ Backend Proxy  │─────────────▶│  Asterisk   │
│    App      │◀──────────────│   (Dart)       │◀─────────────│    AMI      │
└─────────────┘               └────────────────┘              └─────────────┘
      │                              │
      │         HTTP                 │  HTTP
      ▼                              ▼
┌─────────────┐               ┌────────────────┐
│   MySQL     │               │  Recording     │
│    CDR      │               │   Server       │
└─────────────┘               └────────────────┘
```

### معماری جدید (✅ ساده‌شده)
```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │AmiListenClient│  │  SSH/SCP    │  │   SIP Phone  │  │
│  │  (Direct AMI)│  │  (dartssh2) │  │   (sip_ua)   │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
└─────────┼─────────────────┼─────────────────┼──────────┘
          │ TCP:5038        │ SSH:22          │ SIP:5060
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────┐
│                   Asterisk Server                        │
│  ┌─────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │   AMI   │  │ Recordings  │  │     SIP Server       │ │
│  │ :5038   │  │ /var/spool/ │  │       :5060          │ │
│  └─────────┘  └─────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────────┘
          │
          ▼ MySQL:3306
┌─────────────────────────────────────────────────────────┐
│                    MySQL Database                        │
│                   (asteriskcdrdb)                        │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 فایل‌های مربوط به Backend Proxy

### فایل‌هایی که باید حذف/deprecated شوند:

| فایل | توضیحات | اقدام |
|------|---------|-------|
| `lib/core/ami_api.dart` | کلاینت REST برای Backend Proxy | 🗑️ حذف |
| `tools/ami_backend_proxy.dart` | سرور پروکسی اصلی | 📦 Archive |
| `tools/ami_proxy_server.dart` | سرور پروکسی دیگر | 📦 Archive |
| `tools/mock_ami_server.dart` | سرور mock | 📦 Archive |
| `tools/mock_recording_server.dart` | سرور ضبط mock | 📦 Archive |
| `test/core/ami_api_test.dart` | تست‌های AmiApi | 🗑️ حذف |

### فایل‌هایی که باید refactor شوند:

| فایل | خطوط | تغییرات |
|------|------|---------|
| `lib/presentation/pages/active_calls_page.dart` | 270 | `AmiApi.originateListen` → `AmiListenClient` |
| `lib/presentation/pages/cdr_page.dart` | 43, 52, 249 | `AmiApi.*` → SSH/SCP + `AmiListenClient` |
| `lib/presentation/pages/extensions_page.dart` | 397 | `AmiApi.originateListen` → `AmiListenClient` |
| `lib/presentation/widgets/listen_session_dialog.dart` | 27, 47 | `AmiApi.pollJob` → Event-based |
| `lib/presentation/widgets/playback_session_dialog.dart` | 27, 46 | `AmiApi.pollJob` → Event-based |

---

## 🎯 فازهای پیاده‌سازی

### فاز ۱: پاکسازی و آماده‌سازی (۲-۳ روز)

#### 1.1 ایجاد سرویس SSH/SCP
```dart
// lib/core/ssh_service.dart
class SshService {
  final String host;
  final int port;
  final String username;
  final String password; // یا privateKey

  Future<void> connect();
  Future<List<String>> listRecordings(String date);
  Future<File> downloadRecording(String remotePath, String localPath);
  Future<bool> fileExists(String remotePath);
  void disconnect();
}
```

**Dependencies:**
```yaml
dependencies:
  dartssh2: ^2.9.0  # SSH/SCP client
```

#### 1.2 به‌روزرسانی تنظیمات
```dart
// lib/core/app_config.dart - اضافه کردن
class SshConfig {
  final String host;
  final int port;
  final String username;
  final String authMethod; // 'password' or 'key'
  final String? password;
  final String? privateKey;
  final String recordingsPath; // /var/spool/asterisk/monitor/
}
```

#### 1.3 صفحه تنظیمات SSH
```
Settings Page
├── AMI Settings (موجود)
├── MySQL Settings (موجود)
└── SSH Settings (جدید)
    ├── Host
    ├── Port (default: 22)
    ├── Username
    ├── Password / Private Key
    └── Recordings Path
```

---

### فاز ۲: حذف Backend Proxy (۳-۴ روز)

#### 2.1 Refactor کردن فایل‌ها

**active_calls_page.dart:**
```dart
// قبل
await AmiApi.originateListen(payload);

// بعد
final client = sl<AmiListenClient>();
await client.originateListen(
  targetChannel: channel,
  spyExtension: myExtension,
);
```

**cdr_page.dart:**
```dart
// قبل
final response = await AmiApi.getRecordings();
final meta = await AmiApi.getRecordingMeta(id);

// بعد
final sshService = sl<SshService>();
final recordings = await sshService.listRecordings(date);
// برای هر رکورد، فقط نمایش دکمه Play
// اگر فایل نبود، پیام خطا نشان بده
```

#### 2.2 جایگزینی Polling با Event-based

```dart
// قبل - Polling
AmiApi.pollJob(jobId).listen((status) {
  // update UI
});

// بعد - Event-based (از AmiListenClient)
client.eventStream.listen((event) {
  if (event.containsKey('Event')) {
    switch (event['Event']) {
      case 'Newchannel':
        // شنود شروع شد
      case 'Hangup':
        // شنود تمام شد
    }
  }
});
```

---

### فاز ۳: اضافه کردن SIP Phone (۵-۷ روز)

#### 3.1 Dependencies
```yaml
dependencies:
  sip_ua: ^1.1.0
  flutter_webrtc: ^1.2.1
  permission_handler: ^11.3.1
```

#### 3.2 ساختار فایل‌ها
```
lib/
├── core/
│   ├── sip_service.dart          # سرویس SIP
│   └── sip_config.dart           # تنظیمات SIP
├── presentation/
│   ├── pages/
│   │   └── sip_phone_page.dart   # صفحه SIP Phone
│   └── widgets/
│       ├── dialpad.dart          # صفحه شماره‌گیر
│       ├── call_controls.dart    # کنترل‌های تماس
│       └── incoming_call_dialog.dart
```

#### 3.3 SIP Service
```dart
// lib/core/sip_service.dart
class SipService extends SipUaHelperListener {
  late SIPUAHelper _helper;
  
  // تنظیمات
  Future<void> initialize(SipConfig config);
  
  // ثبت‌نام
  Future<void> register();
  void unregister();
  
  // تماس
  Future<void> makeCall(String destination);
  void answer();
  void hangup();
  void hold();
  void unhold();
  void mute();
  void unmute();
  void sendDTMF(String digit);
  
  // شنود (ChanSpy)
  Future<void> listenToChannel(String channel);
  
  // Streams
  Stream<RegistrationState> get registrationState;
  Stream<CallState> get callState;
}
```

#### 3.4 کاربردهای SIP Phone

1. **تماس عادی:**
   - کاربر می‌تواند با داخلی‌ها تماس بگیرد
   - تماس‌های ورودی دریافت کند

2. **شنود (ChanSpy):**
   - بجای زنگ زدن به گوشی فیزیکی، از SIP Phone استفاده شود
   - `ChanSpy(SIP/1001,qEB)` → صدا مستقیم در اپ

3. **پخش ضبط:**
   - فایل ضبط شده با SSH دانلود شود
   - با SIP Phone یا audio player پخش شود

---

### فاز ۴: بازطراحی داشبورد (۳-۴ روز)

#### 4.1 ساختار منوی جدید

```
┌─────────────────────────────────────────────────────────┐
│                      Dashboard                           │
├─────────────────────────────────────────────────────────┤
│  📊 System Resources (if available)                      │
│  ├── CPU Load                                           │
│  ├── Memory Usage                                       │
│  └── Storage                                            │
├─────────────────────────────────────────────────────────┤
│  📈 Quick Stats                                          │
│  ├── Online Extensions: 15/20                           │
│  ├── Active Calls: 5                                    │
│  ├── Queue Waiting: 3                                   │
│  └── Avg Wait Time: 45s                                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  📱 SIP     │  │  📞 Calls    │  │  📋 History  │  │
│  │   Phone     │  │   Monitor    │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  👥 Exten-  │  │  📊 Queues   │  │  ⚙️ Settings │  │
│  │   sions     │  │              │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  🕐 Recent Activity                                      │
│  ├── Call from 1001 to 1002 (2 min ago)                │
│  ├── Missed call from 09121234567 (5 min ago)          │
│  └── Recording available for call #12345               │
└─────────────────────────────────────────────────────────┘
```

#### 4.2 منوهای پیشنهادی

| بخش | آیکون | زیرمنوها | توضیحات |
|-----|-------|----------|---------|
| **SIP Phone** | 📱 | Dialpad, Contacts, Call Log | تلفن نرم‌افزاری |
| **Calls Monitor** | 📞 | Active Calls, Listen Live | مانیتورینگ تماس‌ها |
| **Call History** | 📋 | CDR, Recordings | تاریخچه و ضبط‌ها |
| **Extensions** | 👥 | List, Status | مدیریت داخلی‌ها |
| **Queues** | 📊 | Queue Status, Agents | صف‌های تماس |
| **Settings** | ⚙️ | AMI, SSH, SIP, General | تنظیمات |

#### 4.3 Navigation Structure

```dart
// lib/core/router.dart - Routes جدید
GoRoute(path: '/sip-phone', builder: (_,_) => const SipPhonePage()),
GoRoute(path: '/sip-phone/dialpad', builder: (_,_) => const DialpadPage()),
GoRoute(path: '/sip-phone/contacts', builder: (_,_) => const ContactsPage()),
GoRoute(path: '/calls-monitor', builder: (_,_) => const CallsMonitorPage()),
GoRoute(path: '/listen/:channel', builder: (_, state) => ListenPage(channel: state.pathParameters['channel']!)),
```

---

## 📦 Dependencies جدید

```yaml
# pubspec.yaml - اضافات
dependencies:
  # SIP Phone
  sip_ua: ^1.1.0
  flutter_webrtc: ^1.2.1
  
  # SSH/SCP
  dartssh2: ^2.9.0
  
  # Permissions (for microphone)
  permission_handler: ^11.3.1
  
  # Audio (existing, keep)
  just_audio: ^0.9.36
```

---

## 🔧 تنظیمات مورد نیاز

### تنظیمات Asterisk (sip.conf یا pjsip.conf)

```ini
; داخلی برای SIP Phone اپ
[mobile_app]
type=friend
secret=MobileApp@123
host=dynamic
context=internal
callerid="Mobile App" <9999>
canreinvite=no
nat=yes
qualify=yes
```

### تنظیمات ChanSpy (extensions.conf)

```ini
; شنود زنده
exten => _*1XXXX,1,ChanSpy(SIP/${EXTEN:2},qEB)
```

---

## ✅ چک‌لیست پیاده‌سازی

### فاز ۱: پاکسازی
- [ ] ایجاد `lib/core/ssh_service.dart`
- [ ] ایجاد `lib/core/ssh_config.dart`
- [ ] به‌روزرسانی `lib/core/app_config.dart`
- [ ] اضافه کردن UI تنظیمات SSH در Settings
- [ ] اضافه کردن `dartssh2` به dependencies
- [ ] تست اتصال SSH

### فاز ۲: حذف Backend Proxy
- [ ] Refactor `active_calls_page.dart`
- [ ] Refactor `cdr_page.dart`
- [ ] Refactor `extensions_page.dart`
- [ ] Refactor `listen_session_dialog.dart`
- [ ] Refactor `playback_session_dialog.dart`
- [ ] حذف `lib/core/ami_api.dart`
- [ ] Archive فایل‌های tools/
- [ ] به‌روزرسانی تست‌ها

### فاز ۳: SIP Phone
- [ ] اضافه کردن `sip_ua` و `flutter_webrtc` به dependencies
- [ ] ایجاد `lib/core/sip_service.dart`
- [ ] ایجاد `lib/core/sip_config.dart`
- [ ] ایجاد `lib/presentation/pages/sip_phone_page.dart`
- [ ] ایجاد widgets: dialpad, call_controls, incoming_call_dialog
- [ ] اضافه کردن تنظیمات SIP به Settings
- [ ] تست register/call با Asterisk
- [ ] پیاده‌سازی شنود با ChanSpy

### فاز ۴: بازطراحی داشبورد
- [ ] به‌روزرسانی `dashboard_page.dart`
- [ ] اضافه کردن کارت SIP Phone
- [ ] بازآرایی منوها
- [ ] به‌روزرسانی router.dart
- [ ] اضافه کردن کلیدهای localization جدید
- [ ] تست UI در حالت‌های مختلف

---

## 📊 جدول زمانی پیشنهادی

| فاز | مدت زمان | وابستگی |
|-----|----------|---------|
| فاز ۱: پاکسازی | ۲-۳ روز | - |
| فاز ۲: حذف Proxy | ۳-۴ روز | فاز ۱ |
| فاز ۳: SIP Phone | ۵-۷ روز | فاز ۱, ۲ |
| فاز ۴: داشبورد | ۳-۴ روز | فاز ۳ |
| **مجموع** | **۱۳-۱۸ روز** | |

---

## 🔐 ملاحظات امنیتی

1. **SSH Credentials:**
   - رمز عبور را با `flutter_secure_storage` ذخیره کنید
   - از Private Key authentication پشتیبانی کنید

2. **SIP Credentials:**
   - رمز عبور SIP را امن ذخیره کنید
   - از TLS/SRTP برای تماس‌ها استفاده کنید

3. **AMI Credentials:**
   - دسترسی AMI را محدود کنید
   - از IP whitelist استفاده کنید

---

## 📝 یادداشت‌ها

- **sip_ua** یک کتابخانه pure Dart است و با Asterisk سازگار است
- **dartssh2** از SFTP و SCP پشتیبانی می‌کند
- برای شنود با SIP Phone باید یک داخلی مجازی در Asterisk ثبت شود
- فایل‌های ضبط معمولاً در `/var/spool/asterisk/monitor/` هستند

---

*آخرین به‌روزرسانی: $(date)*
*نویسنده: GitHub Copilot*
