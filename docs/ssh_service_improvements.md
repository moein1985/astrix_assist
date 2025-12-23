# بهبودهای SshService

## تغییرات اعمال شده

### 1. مدیریت اتصال پیشرفته (Connection Management)

#### Keep-Alive Timer
- **Timer خودکار**: هر 30 ثانیه یک `echo "keepalive"` به سرور ارسال می‌شود
- **جلوگیری از Timeout**: اتصال زنده نگه‌داشته می‌شود و session timeout رخ نمی‌دهد
- **فعال‌سازی خودکار**: به محض اتصال موفق، keep-alive شروع می‌شود
- **توقف خودکار**: هنگام قطع اتصال، Timer متوقف می‌شود

```dart
static const Duration _keepAliveInterval = Duration(seconds: 30);
Timer? _keepAliveTimer;

void _startKeepAlive() {
  _keepAliveTimer?.cancel();
  _keepAliveTimer = Timer.periodic(_keepAliveInterval, (timer) async {
    if (_isConnected && _client != null) {
      try {
        await _client!.run('echo "keepalive"');
        _logger.d('Keep-alive ping sent');
      } catch (e) {
        _logger.w('Keep-alive failed, connection may be dead: $e');
      }
    }
  });
}
```

#### Connection Health Check
- **بررسی سلامت**: قبل از هر عملیات، سلامت اتصال چک می‌شود
- **Idle Timeout**: اگر اتصال بیش از 5 دقیقه idle باشد، قطع می‌شود
- **تست سریع**: با دستور `echo "test"` سلامت اتصال تست می‌شود

```dart
static const Duration _idleTimeout = Duration(minutes: 5);
DateTime? _lastActivity;

Future<bool> isConnectionHealthy() async {
  if (!_isConnected || _client == null) return false;
  
  try {
    // اگر idle بیش از حد باشد، اتصال رو بست کن
    if (_lastActivity != null && 
        DateTime.now().difference(_lastActivity!) > _idleTimeout) {
      _logger.w('Connection idle timeout, disconnecting');
      await disconnect();
      return false;
    }
    
    // تست سریع با دستور echo
    final result = await _client!.run('echo "test"');
    return result.isNotEmpty;
  } catch (e) {
    _logger.w('Connection health check failed: $e');
    return false;
  }
}
```

### 2. Retry Logic با Exponential Backoff

#### اتصال با سه تلاش
- **تعداد تلاش**: حداکثر 3 بار تلاش برای اتصال
- **Exponential Backoff**: تاخیر بین تلاش‌ها: 500ms، 1s، 2s
- **لاگ دقیق**: هر تلاش لاگ می‌شود و در صورت شکست، آخرین خطا throw می‌شود

```dart
static const int _maxRetries = 3;

Future<void> connect() async {
  int attempt = 0;
  Exception? lastError;

  while (attempt < _maxRetries) {
    attempt++;
    
    try {
      _logger.i('Connecting to SSH (attempt $attempt/$_maxRetries): ...');
      
      // اتصال...
      
      _logger.i('SSH connection established successfully on attempt $attempt');
      return;
      
    } catch (e) {
      lastError = e is Exception ? e : Exception(e.toString());
      _logger.w('SSH connection attempt $attempt failed: $e');
      
      // اگر آخرین تلاش نبود، کمی صبر کن
      if (attempt < _maxRetries) {
        final delay = Duration(milliseconds: 500 * (1 << (attempt - 1)));
        _logger.d('Waiting ${delay.inMilliseconds}ms before retry');
        await Future.delayed(delay);
      }
    }
  }

  throw lastError ?? Exception('SSH connection failed after $_maxRetries attempts');
}
```

### 3. Automatic Session Recovery

#### Execute with Recovery Wrapper
- **Wrapper برای همه عملیات**: تمام توابع SSH از `_executeWithRecovery` استفاده می‌کنند
- **بررسی خودکار**: قبل از اجرا، سلامت اتصال چک می‌شود
- **Reconnect خودکار**: در صورت نیاز، اتصال مجدد برقرار می‌شود
- **Error Detection**: خطاهای مربوط به اتصال تشخیص داده شده و یک بار retry می‌شوند

```dart
Future<T> _executeWithRecovery<T>(Future<T> Function() operation) async {
  _lastActivity = DateTime.now();
  
  // اگر اتصال سالم نیست، reconnect کن
  if (!await isConnectionHealthy()) {
    _logger.i('Connection unhealthy, attempting reconnect');
    await disconnect();
    await connect();
  }
  
  try {
    return await operation();
  } catch (e) {
    // اگر خطای اتصال بود، یک بار reconnect و retry کن
    if (_isConnectionError(e)) {
      _logger.w('Connection error detected, attempting recovery: $e');
      await disconnect();
      await connect();
      return await operation(); // یک بار دیگه امتحان کن
    }
    rethrow;
  }
}

bool _isConnectionError(dynamic error) {
  final errorStr = error.toString().toLowerCase();
  return errorStr.contains('socket') ||
         errorStr.contains('connection') ||
         errorStr.contains('timeout') ||
         errorStr.contains('closed');
}
```

### 4. بهبود خطاها در CDR Page

#### پیغام‌های کاربرپسندتر
- **تشخیص نوع خطا**: خطاها دسته‌بندی می‌شوند:
  - خطای اتصال (Connection Error)
  - خطای احراز هویت (Authentication Failed)
  - فایل پیدا نشد (Recording Not Found)
  - خطای غیرمنتظره (Unexpected Error)
- **پیغام فارسی/انگلیسی**: از Localization استفاده می‌شود
- **رنگ متمایز**: خطاها با پس‌زمینه قرمز نمایش داده می‌شوند

```dart
try {
  filePath = await _downloadRecording(record.uniqueid, record.callDate);
} catch (e) {
  // Detect error type and provide user-friendly message
  final errStr = e.toString().toLowerCase();
  if (errStr.contains('connection') || errStr.contains('socket') || errStr.contains('timeout')) {
    errorMessage = l10nLocal.connectionError;
  } else if (errStr.contains('auth') || errStr.contains('permission')) {
    errorMessage = l10nLocal.authenticationError;
  } else if (errStr.contains('not found') || errStr.contains('no such file')) {
    errorMessage = l10nLocal.recordingNotFound;
  } else {
    errorMessage = '${l10nLocal.unexpectedError}: ${e.toString().split('\n').first}';
  }
}
```

## نتایج بهبودها

### قبل از بهبودها:
- ❌ Session timeout بین عملیات (CDR fetch → Recording download)
- ❌ هیچ retry نداشت
- ❌ پیغام خطای نامفهوم برای کاربر
- ❌ Crash در صورت خطا

### بعد از بهبودها:
- ✅ Keep-alive جلوی timeout رو می‌گیره
- ✅ 3 بار تلاش برای اتصال با backoff
- ✅ Automatic reconnect در صورت قطع اتصال
- ✅ پیغام‌های واضح و کاربرپسند
- ✅ هیچ crash نمی‌کنه - همیشه پیغام می‌ده

## استراتژی Recording Check

### همیشه نمایش دکمه Play:
- Play button برای همه تماس‌ها نمایش داده می‌شود
- بدون پیش‌بررسی وجود فایل (تا سریع‌تر باشد)
- موقع کلیک:
  1. نمایش loading indicator
  2. تلاش برای دانلود فایل
  3. در صورت موفقیت: باز کردن player
  4. در صورت خطا: نمایش پیغام مناسب (با تشخیص نوع خطا)

### مزایا:
- سرعت بیشتر در نمایش CDR
- بدون overhead برای بررسی هزاران فایل
- تجربه کاربری بهتر (معلوم می‌شه که recording نداره، نه اینکه باگ داره!)
