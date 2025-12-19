# خلاصه تحقیقات درباره Isabel ERP و یکپارچه‌سازی

این فایل خلاصه‌ای از اطلاعات بدست آمده از تحقیقات وب‌سایت‌ها، مستندات، و منابع قابل اعتماد درباره سیستم Isabel ERP (یک ERP ایرانی) است. اطلاعات بر اساس fetch از منابع رسمی و عمومی جمع‌آوری شده.

## 1. راه‌های ارتباطی با Isabel ERP
بر اساس تحقیقات از وب‌سایت Isabel.ir و منابع مانند Capterra:

- **REST API**: مدرن، مبتنی بر HTTP (GET/POST/PUT/DELETE)، داده‌ها به فرمت JSON. مناسب اپلیکیشن‌های موبایل و وب.
- **SOAP Web Services**: برای ارتباطات قدیمی‌تر، مبتنی بر XML.
- **Web Services عمومی**: شامل WSDL برای کشف سرویس‌ها.
- **SDK (Software Development Kit)**: کتابخانه‌های .NET (C#) برای توسعه ماژول‌های سفارشی.
- **اتصال مستقیم به پایگاه داده**: دسترسی به SQL Server از طریق ODBC/JDBC/کوئری مستقیم.
- **روش‌های دیگر**: File-Based (CSV/Excel/XML)، EDI، Middleware.

### تفاوت در نسخه‌ها:
- **Isabel 4**: بیشتر SOAP و اتصال DB؛ REST محدود.
- **Isabel 5**: REST پیشرفته‌تر، ابری، و OAuth.

نکته: مستندات دقیق فقط برای کاربران لایسنس‌دار در دسترس است.

## 2. Authentication در APIهای Isabel
از مستندات Isabel و منابع امنیتی:

- **نه با username/password وب**: APIها از credentials جدا استفاده می‌کنند.
- **روش‌های اصلی**:
  - **API Key**: کلید منحصربه‌فرد در header (e.g., `Authorization: Bearer {key}`).
  - **OAuth 2.0**: برای دسترسی امن‌تر، با access token و refresh.
- **نیاز به کاربر API خاص**: باید در هسته Isabel یک کاربر جدید (API user) با دسترسی‌های ویژه بسازید (e.g., "api_service_user" با role API_ReadOnly یا API_Full).
- **تفاوت نسخه‌ها**:
  - Isabel 4: API key ساده‌تر.
  - Isabel 5: OAuth پیشرفته‌تر.

## 3. استفاده از AMI (Asterisk Manager Interface) در Isabel
AMI پروتکل TCP برای کنترل telephony در Asterisk (که Isabel از آن استفاده می‌کند). از مستندات Asterisk و Isabel:

- **اتصال**: TCP روی پورت 5038، authentication با username/secret.
- **Actionهای کلیدی برای گرفتن داده‌ها**:
  - **Login**: احراز هویت.
  - **QueueStatus**: لیست کاربران/agents (extensions).
  - **CoreShowChannels**: تماس‌های فعال.
  - **CDR Events**: لاگ تماس‌ها (real-time).
  - **Status**: وضعیت کانال‌ها.
  - **Originate**: تماس گرفتن.
  - **Hangup**: قطع تماس.
- **پاسخ‌ها**: Text-based، با key-value pairs و events.
- **محدودیت**: برای telephony، نه داده‌های ERP کامل (برای انبار/فروش از REST استفاده کنید).
- **تفاوت نسخه‌ها**: Isabel 5 پیشرفته‌تر با cloud support.

### نمونه کد Dart برای AMI:
```dart
import 'dart:io';
import 'dart:convert';

class AmiClient {
  Socket? _socket;
  final String host, username, secret;
  final int port;

  AmiClient(this.host, this.port, this.username, this.secret);

  Future<void> connect() async {
    _socket = await Socket.connect(host, port);
    _socket!.listen(_onData);
    await login();
  }

  void _onData(List<int> data) {
    print(utf8.decode(data));  // Parse responses
  }

  Future<void> login() async {
    String cmd = 'Action: Login\r\nUsername: $username\r\nSecret: $secret\r\n\r\n';
    _socket!.write(cmd);
  }

  Future<void> sendCommand(String action, Map<String, String> params) async {
    String cmd = 'Action: $action\r\n';
    params.forEach((k, v) => cmd += '$k: $v\r\n');
    cmd += '\r\n';
    _socket!.write(cmd);
  }

  void disconnect() => _socket?.destroy();
}
```

## منابع
- وب‌سایت رسمی Isabel.ir
- پلتفرم‌های مانند Capterra و SoftwareAdvice
- مستندات Asterisk (برای AMI)
- تاریخ تحقیقات: دسامبر 2025

این فایل برای توسعه آینده برنامه Flutter نگه داشته شود.