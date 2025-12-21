# Astrix Assist Backend Tools

این پوشه شامل ابزارهای backend برای تست و توسعه است.

## ابزارهای موجود

### 1. AMI Backend Proxy (`ami_backend_proxy.dart`)

سرور proxy که بین Flutter app و AMI adapter قرار می‌گیرد.

**امکانات:**
- احراز هویت JWT و شناسایی کاربر
- کنترل دسترسی بر اساس نقش (user, supervisor, qa, admin)
- Audit logging در SQLite database
- حالت Simulate برای تست محلی
- حالت Forward برای production

**استفاده:**

```bash
# حالت simulate (تست محلی با داده mock)
dart tools/ami_backend_proxy.dart

# حالت forward (proxy به AMI adapter واقعی)
AMI_PROXY_FORWARD=http://real-adapter:8080 dart tools/ami_backend_proxy.dart

# تغییر پورت
AMI_PROXY_PORT=9090 dart tools/ami_backend_proxy.dart
```

**API Endpoints:**
- `GET /recordings`: لیست ضبط‌ها
- `POST /ami/originate/listen`: شروع Listen session
- `POST /ami/originate/playback`: پخش ضبط
- `POST /ami/control/playback`: کنترل پخش
- `GET /ami/jobs/:id`: وضعیت job
- `GET /ami/events`: SSE event stream

---

### 2. Mock Recording Server (`mock_recording_server.dart`)

سرور mock برای تست پخش ضبط‌ها.

**استفاده:**

```bash
dart tools/mock_recording_server.dart
# سرور روی http://localhost:8081 اجرا می‌شود
```

**Endpoints:**
- `GET /recordings`: لیست ضبط‌ها
- `GET /recordings/:id/stream`: Stream فایل صوتی
- `GET /recordings/:id/metadata`: Metadata ضبط

---

### 3. Mock AMI Server (`mock_ami_server.dart`) 🆕

شبیه‌ساز Asterisk AMI برای تست بدون سرور واقعی.

**امکانات:**
- شبیه‌سازی کامل پروتکل AMI
- پشتیبانی Login/Logoff
- پشتیبانی Originate (ChanSpy, Playback)
- Event streaming (ChanSpyStart, PlaybackStart و غیره)
- شبیه‌سازی ControlPlayback
- پشتیبانی Hangup

**استفاده:**

```bash
dart tools/mock_ami_server.dart
# سرور Mock AMI روی پورت 5038 اجرا می‌شود
```

**Action های پشتیبانی شده:**
- `Login`: احراز هویت به AMI
- `Logoff`: قطع اتصال از AMI
- `Originate`: شروع تماس (ChanSpy یا Playback)
- `Hangup`: قطع کانال
- `ControlPlayback`: کنترل پخش (pause, restart و غیره)
- `CoreShowChannels`: لیست کانال‌های فعال

---

### 4. Test AMI Client (`test_ami_client.dart`) 🆕

برنامه تست command-line برای AMI Listen Client.

**استفاده:**

```bash
# تست با mock server (پیش‌فرض)
dart run tools/test_ami_client.dart

# تست با سرور واقعی Isabel
dart run tools/test_ami_client.dart --real
```

**تست‌ها:**
1. اتصال و Login
2. دریافت کانال‌های فعال
3. Originate تماس Listen (ChanSpy)
4. Originate تماس Playback
5. کنترل پخش (Pause/Resume)
6. Hangup کانال
7. قطع اتصال

---

## AMI TCP Client

کلاس `AmiListenClient` (در `lib/core/ami_listen_client.dart`) اتصال مستقیم TCP به Asterisk AMI را فراهم می‌کند.

**امکانات کلیدی:**
- اتصال مستقیم TCP socket به Asterisk AMI (پورت 5038)
- پیاده‌سازی کامل پروتکل AMI
- Event streaming در زمان واقعی
- پشتیبانی ChanSpy برای گوش دادن زنده
- پشتیبانی Playback برای ضبط‌ها
- کنترل پخش (pause, resume, forward, reverse, stop)

**مثال سریع:**

```dart
import 'package:astrix_assist/core/ami_listen_client.dart';

final client = AmiListenClient(
  host: '192.168.85.88',
  port: 5038,
  username: 'moein_api',
  secret: '123456',
);

await client.connect();

// گوش دادن به event ها
client.eventsStream.listen((event) {
  print('Event: ${event['Event']}');
});

// شروع گوش دادن به تماس
await client.originateListen(
  targetChannel: 'SIP/202',
  listenerExtension: '201',
);

// پخش یک ضبط
await client.originatePlayback(
  targetExtension: '201',
  recordingPath: '/var/spool/asterisk/monitor/recording.wav',
);

await client.disconnect();
```

راهنمای کامل: [AMI Listen Client Documentation](../docs/ami_listen_client_usage.md)

---

## Database Schema

### AMI Audit Database (`ami_audit.db`)

ردیابی تمام عملیات AMI برای compliance و نظارت.

**جدول: ami_audit**

```sql
CREATE TABLE ami_audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  action TEXT NOT NULL,
  target TEXT,
  job_id TEXT,
  timestamp INTEGER NOT NULL
);
```

---

## جریان کار توسعه

### تست محلی با Mock Server

#### گزینه 1: Full Mock Stack

1. اجرای mock recording server:
   ```bash
   dart tools/mock_recording_server.dart
   ```

2. اجرای AMI backend proxy در حالت simulate:
   ```bash
   dart tools/ami_backend_proxy.dart
   ```

3. اجرای Flutter app:
   ```bash
   flutter run
   ```

#### گزینه 2: تست مستقیم AMI (TCP Client)

1. اجرای mock AMI server:
   ```bash
   dart tools/mock_ami_server.dart
   ```

2. اجرای تست AMI client:
   ```bash
   dart run tools/test_ami_client.dart
   ```

3. یا استفاده در Flutter app با `AmiListenClient`

### تست با Isabel واقعی

1. اطمینان از دسترسی به Isabel در `192.168.85.88:5038`

2. تست اتصال AMI:
   ```bash
   dart run tools/test_ami_client.dart --real
   ```

3. پیکربندی app برای استفاده از سرور واقعی:
   ```dart
   // lib/core/app_config.dart
   static const bool useMockRepositories = false;
   ```

4. اجرای Flutter app:
   ```bash
   flutter run
   ```

---

## احراز هویت

### Backend Proxy

تمام endpoint های proxy نیاز به احراز هویت JWT از طریق header `Authorization: Bearer <token>` دارند.

**JWT Claims مورد نیاز:**
- `sub` یا `user_id`: شناسه کاربر
- `role`: نقش کاربر (user, supervisor, qa, admin)

**Test Token (برای توسعه):**
```
test-token-for-local-dev
```

### AMI Authentication

اتصالات مستقیم AMI از احراز هویت username/password استفاده می‌کنند:

```dart
AmiListenClient(
  host: '192.168.85.88',
  port: 5038,
  username: 'moein_api',
  secret: '123456',
);
```

---

## عیب‌یابی

### خطای Database Locked

```bash
# بستن تمام اتصالات به database
rm tools/ami_audit.db
sqlite3 tools/ami_audit.db < tools/migrations/001_create_audit_table.sql
```

### خطای Port Already in Use

```bash
# پیدا کردن process استفاده‌کننده از پورت 8080
netstat -ano | findstr :8080

# پیدا کردن process استفاده‌کننده از پورت 5038
netstat -ano | findstr :5038

# خاتمه process
taskkill /F /PID <process_id>
```

### مشکلات اتصال AMI

**مشکل:** "Connection refused" هنگام اتصال به AMI

**راه‌حل:**
1. بررسی اجرای Asterisk: `asterisk -rx "core show version"`
2. بررسی فعال بودن AMI: `asterisk -rx "manager show settings"`
3. بررسی firewall
4. بررسی credentials در `manager.conf`

**مشکل:** "Authentication failed"

**راه‌حل:**
1. بررسی username/password در `manager.conf`
2. بررسی IP مجاز: بررسی خطوط `permit`
3. Reload AMI: `asterisk -rx "manager reload"`

---

## معماری

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    │    ┌────▼────────────┐
    │    │ AMI Backend     │ ◄── حالت Simulate (داده Mock)
    │    │ Proxy           │ ◄── حالت Forward (AMI Adapter واقعی)
    │    └─────────────────┘
    │
    │    ┌────▼────────────┐
    └────► AmiListenClient │ ◄── TCP مستقیم به Asterisk AMI
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │  Asterisk AMI   │ ◄── سرور واقعی Isabel
         │  (پورت 5038)    │
         └─────────────────┘
```

**دو روش یکپارچه‌سازی:**

1. **Backend Proxy** (توصیه شده برای production)
   - احراز هویت و audit logging متمرکز
   - مقیاس‌پذیری و نظارت آسان
   - امنیت بهتر (عدم قرارگیری مستقیم AMI)

2. **Direct AMI** (مناسب برای ویژگی‌های خاص)
   - تاخیر کمتر
   - Event streaming در زمان واقعی
   - مفید برای ویژگی‌های Listen/Playback

---

## مستندات بیشتر

- [Deployment Guide](../docs/deployment_guide.md) — راهنمای استقرار production
- [AMI Listen Client Usage](../docs/ami_listen_client_usage.md) — راهنمای کامل AMI Client
- [Asterisk AMI Documentation](../docs/asterisk_ami_call_listening.md) — مستندات فنی AMI
