# راهنمای راه‌اندازی و استقرار (Deployment Guide)

این سند شامل دستورالعمل‌های راه‌اندازی و استقرار قابلیت‌های Listen Live و Playback در محیط production است.

## پیش‌نیازها

### سمت سرور (Backend)

1. **Asterisk PBX** با ماژول‌های زیر:
   - `app_chanspy` — برای شنود زنده
   - `app_playback` — برای پخش ضبط
   - `app_mixmonitor` — برای ضبط مکالمات

2. **AMI دسترسی** — کاربر محدود در `manager.conf`:
```ini
[astrix_proxy]
secret = your-secure-password
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.255
read = system,call,log,verbose,agent,command
write = system,call,originate
```

3. **Dialplan Contexts** — اضافه کردن به `extensions.conf`:
```ini
[spy-context]
exten => _X.,1,NoOp(Start ChanSpy on ${SPYTARGET})
 same => n,ChanSpy(${SPYTARGET},bq)
 same => n,Hangup()

[playback-context]
exten => _X.,1,NoOp(Playback ${RECFILE})
 same => n,Playback(${RECFILE})
 same => n,Hangup()
```

4. **فضای ذخیره‌سازی** — تنظیم مسیر ضبط‌ها:
```ini
; در extensions.conf یا globals
MONITOR_DIR=/var/spool/asterisk/monitor
```

### Backend Proxy

#### نصب وابستگی‌ها

Backend proxy نیاز به Dart SDK دارد:

```bash
# نصب Dart SDK (لینوکس/Mac)
curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get update
sudo apt-get install dart

# نصب وابستگی‌های پروژه
cd /path/to/astrix_assist
dart pub get
```

#### تنظیمات Environment Variables

```bash
# آدرس و پورت سرور proxy
export AMI_BACKEND_PORT=8081

# حالت forward (اختیاری - برای proxy به AMI adapter واقعی)
export AMI_PROXY_FORWARD=http://real-ami-server:8080

# اگر ست نشود، در حالت simulate اجرا می‌شود
```

#### اجرای Backend Proxy

```bash
# حالت development (simulate)
dart run tools/ami_backend_proxy.dart

# حالت production با systemd
sudo systemctl enable astrix-ami-proxy
sudo systemctl start astrix-ami-proxy
```

#### فایل Systemd Service

ایجاد `/etc/systemd/system/astrix-ami-proxy.service`:

```ini
[Unit]
Description=Astrix AMI Backend Proxy
After=network.target

[Service]
Type=simple
User=asterisk
WorkingDirectory=/opt/astrix_assist
Environment="AMI_BACKEND_PORT=8081"
ExecStart=/usr/bin/dart run tools/ami_backend_proxy.dart
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### Frontend (اپ Flutter)

#### تنظیمات

1. **آدرس Backend Proxy** — در `lib/core/ami_api.dart`:
```dart
// برای production باید آدرس واقعی را وارد کنید
static final String _defaultBase = 'https://your-server.com:8081';
```

یا با environment variable:
```bash
flutter build apk --dart-define=AMI_PROXY_URL=https://your-server.com:8081
```

2. **احراز هویت JWT** — تنظیم token در AmiApi:
```dart
// در production باید token واقعی از authentication system بگیرید
..options.headers['Authorization'] = 'Bearer $realJwtToken';
```

#### ساخت و استقرار

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release

# نصب مستقیم برای تست
flutter install
```

## احراز هویت و امنیت

### JWT Token Structure

Backend proxy انتظار یک JWT token با ساختار زیر دارد:

```json
{
  "sub": "user-id-123",          // شناسه کاربر
  "role": "supervisor",           // نقش: user, supervisor, qa, admin
  "exp": 1735689600,             // زمان انقضا
  "iss": "astrix-auth"           // صادرکننده
}

```

### تولید JWT Token (مثال)

```dart
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final jwt = JWT({
  'sub': 'user-123',
  'role': 'supervisor',
  'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
  'exp': DateTime.now().add(Duration(hours: 8)).millisecondsSinceEpoch ~/ 1000,
});

final token = jwt.sign(SecretKey('your-secret-key'));
```

### Role-Based Access Control

Backend proxy از نقش‌های زیر پشتیبانی می‌کند:

- **user** — دسترسی فقط به لیست ضبط‌ها
- **supervisor** — دسترسی به Listen Live و Playback
- **qa** — دسترسی به Listen Live و Playback
- **admin** — دسترسی کامل

## Audit و لاگ‌ها

### Database Schema

Backend proxy یک جدول SQLite برای audit ایجاد می‌کند:

```sql
CREATE TABLE ami_audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  action TEXT NOT NULL,
  target TEXT,
  recording_id TEXT,
  job_id TEXT,
  reason TEXT,
  timestamp TEXT NOT NULL,
  duration INTEGER,
  meta TEXT
);
```

مسیر پایگاه داده: `tools/ami_audit.db`

### بررسی لاگ‌ها

```bash
# مشاهده audit log
sqlite3 tools/ami_audit.db "SELECT * FROM ami_audit ORDER BY timestamp DESC LIMIT 20;"

# فیلتر بر اساس کاربر
sqlite3 tools/ami_audit.db "SELECT * FROM ami_audit WHERE user_id='user-123';"

# لاگ‌های فایلی (fallback)
tail -f tools/ami_backend_audit.log
```

## Consent و مقررات

کاربر قبل از شنود زنده باید consent بدهد. این تنظیمات در `SharedPreferences` اپ ذخیره می‌شود:

```dart
// بررسی consent
final hasConsent = await ListenConsentDialog.hasConsent();

// ریست کردن consent (برای تست)
final prefs = await SharedPreferences.getInstance();
await prefs.remove('listen_consent_given');
```

## تست و عیب‌یابی

### تست Backend Proxy

```bash
# تست endpoint recordings
curl -H "Authorization: Bearer test-token" \
     -H "x-user-role: supervisor" \
     http://127.0.0.1:8081/recordings

# تست originate listen
curl -X POST \
     -H "Authorization: Bearer test-token" \
     -H "x-user-role: supervisor" \
     -H "Content-Type: application/json" \
     -d '{"target":"SIP/101"}' \
     http://127.0.0.1:8081/ami/originate/listen
```

### تست Integration

```bash
# اجرای تست‌های integration
export AMI_PROXY_URL="http://127.0.0.1:8081"
dart test test/core/ami_api_test.dart
```

### عیب‌یابی رایج

1. **خطای 403 Forbidden** — نقش کاربر صحیح نیست یا token معتبر نیست
   - بررسی کنید که header `x-user-role` برابر `supervisor` یا `qa` باشد
   - token JWT را validate کنید

2. **SSE events دریافت نمی‌شود** — اتصال به `/ami/events` برقرار نیست
   - فایروال یا proxy ممکن است SSE را مسدود کند
   - از polling به عنوان fallback استفاده کنید

3. **فایل ضبط پیدا نمی‌شود** — مسیر storage اشتباه است
   - مسیر ضبط‌ها در Asterisk را بررسی کنید
   - دسترسی read برای کاربر backend را چک کنید

## امنیت و Best Practices

1. **HTTPS** — در production حتماً از HTTPS استفاده کنید
2. **JWT Secret** — از یک secret key قوی و تصادفی استفاده کنید
3. **Rate Limiting** — محدودیت تعداد درخواست برای جلوگیری از abuse
4. **Audit Log Retention** — برنامه‌ریزی برای پاکسازی لاگ‌های قدیمی
5. **Firewall** — محدود کردن دسترسی به Backend Proxy فقط از شبکه داخلی

## نظارت و مانیتورینگ

### Metrics پیشنهادی

- تعداد session‌های Listen Live فعال
- تعداد درخواست‌های ضبط در روز
- میانگین زمان listen session
- تعداد خطاهای authentication

### ابزارهای پیشنهادی

- **Prometheus** — برای metrics
- **Grafana** — برای visualization
- **Sentry** — برای error tracking

## مراجع

- [Asterisk AMI Documentation](https://wiki.asterisk.org/wiki/display/AST/Asterisk+Manager+Interface+%28AMI%29)
- [ChanSpy Application](https://wiki.asterisk.org/wiki/display/AST/Application_ChanSpy)
- [JWT.io](https://jwt.io/) — ابزار debug برای JWT tokens

---

آخرین بروزرسانی: 2025-12-21
