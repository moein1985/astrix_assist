# راهنمای Refactoring پروژه Astrix Assist

**تاریخ:** ۳۰ آذر ۱۴۰۴  
**هدف:** تبدیل پروژه به معماری مدرن با Sealed Classes و Mock Repository  
**مخاطب:** Grok AI / Developer

---

## فاز ۱: Mock Repository Implementation (اولویت: بالا ⚡)

### ۱.۱ ساختار فایل‌ها

ایجاد فایل‌های زیر:

```
lib/data/repositories/
├── mock/
│   ├── monitor_repository_mock.dart
│   ├── extension_repository_mock.dart
│   └── mock_data.dart
```

### ۱.۲ Mock Data طراحی شده بر اساس Asterisk AMI

#### الف) داده‌های نمونه Extension (SIP Peers)

بر اساس دستور `Action: SIPpeers` در Asterisk AMI:

**فیلدهای اصلی:**
- `ObjectName`: شماره داخلی (extension number) مثل "101", "102"
- `IPaddress`: آدرس IP دستگاه SIP
- `IPport`: پورت SIP (معمولاً 5060)
- `Status`: وضعیت اتصال
  - `OK (X ms)`: متصل و پینگ X میلی‌ثانیه
  - `UNREACHABLE`: قطع
  - `UNKNOWN`: نامشخص
- `Dynamic`: yes/no (آیا IP دینامیک است)
- `RealtimeDevice`: yes/no
- `Forcerport`: yes/no
- `VideoSupport`: yes/no
- `TextSupport`: yes/no

**داده نمونه در mock_data.dart:**
```dart
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
```

#### ب) داده‌های نمونه Active Call

بر اساس دستور `Action: CoreShowChannels`:

**فیلدهای کلیدی:**
- `Event`: "CoreShowChannel"
- `Channel`: نام کانال (مثل "SIP/101-00000abc")
- `ChannelState`: عدد وضعیت (0-7)
  - 0: Down
  - 4: Ring
  - 6: Up (در حال مکالمه)
- `ChannelStateDesc`: توضیح وضعیت ("Up", "Ring", "Down")
- `CallerIDNum`: شماره تماس‌گیرنده
- `ConnectedLineNum`: شماره طرف مقابل
- `Duration`: مدت تماس (ثانیه)
- `Context`: context dial plan
- `Exten`: extension مقصد
- `Application`: برنامه در حال اجرا (مثل "Dial", "Queue")

**کانال‌های سیستمی که باید فیلتر شوند:**
- `Local@` channels: کانال‌های داخلی routing
- کانال‌های حاوی `VoiceMail`, `Parked`, `ConfBridge`, `MeetMe`
- کانال‌هایی که `Application` آن‌ها `AppDial` نیست

**تماس واقعی:** کانالی که:
1. با `SIP/` یا `PJSIP/` شروع شود
2. `ChannelStateDesc` برابر `"Up"` باشد
3. `ConnectedLineNum` پر باشد (نشان‌دهنده اتصال به طرف مقابل)

**داده نمونه:**
```dart
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
```

#### ج) داده‌های نمونه Queue

بر اساس دستور `Action: QueueStatus`:

**فیلدهای اصلی:**
- `Event`: "QueueParams" (برای خود صف) یا "QueueMember" (برای اعضا)
- `Queue`: نام صف
- `Completed`: تعداد تماس‌های تکمیل شده
- `Abandoned`: تعداد تماس‌های رها شده
- `Calls`: تعداد تماس‌های در حال انتظار
- `Holdtime`: میانگین زمان انتظار (ثانیه)
- `TalkTime`: میانگین زمان مکالمه (ثانیه)

**اعضای صف (QueueMember):**
- `Name`: نام عضو (مثل "SIP/101")
- `Status`: وضعیت
  - 1: Not in use (آزاد)
  - 2: In use (مشغول)
  - 5: Unavailable (غیرفعال)
- `Paused`: 0 (فعال) یا 1 (متوقف)
- `CallsTaken`: تعداد تماس‌های پاسخ داده شده

**داده نمونه:**
```dart
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
```

### ۱.۳ پیاده‌سازی Mock Repositories

#### MonitorRepositoryMock

**مسیر:** `lib/data/repositories/mock/monitor_repository_mock.dart`

**وظایف:**
1. `getActiveCalls()`: بازگشت لیست تماس‌های فعال از `MockData.mockActiveChannels`
   - اضافه کردن تاخیر 300-500ms برای شبیه‌سازی network
   - پردازش رشته AMI دقیقاً مثل `MonitorRepositoryImpl`
   - فیلتر کردن کانال‌های سیستمی
   
2. `getQueueStatuses()`: بازگشت وضعیت صف‌ها
   - پردازش `MockData.mockQueueStatus`
   - محاسبه اعضای available/busy

**نکات مهم:**
- از همان parser استفاده کنید که در `ActiveCallModel.fromAmi()` هست
- زمان‌های Duration را به صورت dynamic تولید کنید (مثلاً با `DateTime.now()`)
- برای هر بار فراخوانی، مقادیر کمی تغییر کنند (برای واقعی‌تر بودن)

#### ExtensionRepositoryMock

**مسیر:** `lib/data/repositories/mock/extension_repository_mock.dart`

**وظایف:**
1. `getExtensions()`: بازگشت لیست داخلی‌ها
   - استفاده از `MockData.mockSipPeers`
   - تبدیل به `ExtensionModel` با همان فرمت AMI

**شبیه‌سازی تغییرات dynamic:**
```dart
// مثال: هر بار که فراخوانی می‌شود، یکی از extension‌ها رندوم offline/online شود
final random = Random();
if (random.nextBool()) {
  // تغییر Status یکی از peer‌ها
}
```

### ۱.۴ تنظیم Dependency Injection

**فایل:** `lib/core/injection_container.dart`

**تغییرات مورد نیاز:**

```dart
// اضافه کردن import
import 'package:astrix_assist/data/repositories/mock/monitor_repository_mock.dart';
import 'package:astrix_assist/data/repositories/mock/extension_repository_mock.dart';

void init() {
  // تشخیص محیط
  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);
  
  // Repositories با شرط
  if (useMock) {
    sl.registerLazySingleton<MonitorRepository>(
      () => MonitorRepositoryMock(),
    );
    sl.registerLazySingleton<ExtensionRepository>(
      () => ExtensionRepositoryMock(),
    );
  } else {
    // کد فعلی...
    sl.registerLazySingleton<MonitorRepository>(
      () => MonitorRepositoryImpl(dataSource: sl()),
    );
    sl.registerLazySingleton<ExtensionRepository>(
      () => ExtensionRepositoryImpl(dataSource: sl()),
    );
  }
  
  // بقیه کد بدون تغییر...
}
```

### ۱.۵ نحوه اجرا

**با Mock (بدون نیاز به Asterisk):**
```bash
flutter run --dart-define=USE_MOCK=true
```

**بدون Mock (با Asterisk واقعی):**
```bash
flutter run
```

یا:
```bash
flutter run --dart-define=USE_MOCK=false
```

### ۱.۶ تست Mock Repository

**فایل تست:** `test/data/repositories/mock/monitor_repository_mock_test.dart`

**موارد تست:**
1. `getActiveCalls()` باید لیستی با حداقل ۱ تماس فعال برگرداند
2. تماس‌های سیستمی (Local@) نباید در نتیجه باشند
3. Duration باید مقدار معقولی داشته باشد
4. تاخیر شبیه‌سازی شده باید بین 300-500ms باشد

---

## فاز ۲: Sealed Classes Refactor (اولویت: متوسط 🟡)

### ۲.۱ ساختار Sealed Classes

**Dart 3.0+** از sealed classes پشتیبانی می‌کند که type-safety کامل فراهم می‌کند.

### ۲.۲ Result Type (جایگزین Either)

**فایل جدید:** `lib/core/result.dart`

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
```

**استفاده در Repository:**
```dart
// قبل (با Either):
Future<Either<Failure, List<ActiveCall>>> getActiveCalls();

// بعد (با Result):
Future<Result<List<ActiveCall>>> getActiveCalls();
```

**مزایا:**
- ساده‌تر از dartz/Either
- Pattern matching قدرتمند
- No external dependency

### ۲.۳ BLoC States با Sealed Class

#### DashboardBloc

**فایل:** `lib/presentation/blocs/dashboard_state.dart`

**ساختار:**
```dart
sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ActiveCall> activeCalls;
  
  const DashboardLoaded({
    required this.stats,
    required this.activeCalls,
  });
}

final class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}
```

**مزایا:**
- Compiler مطمئن می‌شود همه حالت‌ها handle شده‌اند
- IDE autocomplete بهتر
- Refactoring آسان‌تر

#### DashboardEvent

```dart
sealed class DashboardEvent {
  const DashboardEvent();
}

final class FetchDashboardData extends DashboardEvent {
  const FetchDashboardData();
}

final class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}
```

### ۲.۴ Pattern Matching در BLoC

**قبل:**
```dart
if (state is DashboardLoading) {
  // ...
} else if (state is DashboardLoaded) {
  // ...
}
```

**بعد (با switch expression):**
```dart
return switch (state) {
  DashboardInitial() => Center(child: Text('خوش آمدید')),
  DashboardLoading() => Center(child: CircularProgressIndicator()),
  DashboardLoaded(:final stats, :final activeCalls) => _buildDashboard(stats, activeCalls),
  DashboardError(:final message) => _buildError(message),
};
```

**مزایا:**
- اگر state جدیدی اضافه کنید و در switch فراموش کنید، compile error می‌گیرید
- کد خواناتر و کوتاه‌تر

### ۲.۵ لیست BLoC‌هایی که باید تبدیل شوند

1. ✅ **DashboardBloc** (اولویت بالا)
   - States: Initial, Loading, Loaded, Error
   - Events: FetchDashboardData, RefreshDashboard

2. ✅ **ExtensionBloc**
   - States: Initial, Loading, Loaded, Error
   - Events: LoadExtensions, CallExtension

3. ✅ **ActiveCallBloc**
   - States: Initial, Loading, Loaded, Empty, Error
   - Events: LoadActiveCalls, RefreshCalls

4. ✅ **QueueBloc**
   - States: Initial, Loading, Loaded, Error
   - Events: LoadQueues, RefreshQueues

5. ⚠️ **CdrBloc** (نیاز به بررسی MySQL connection)
   - States: Initial, Loading, Loaded, Error
   - Events: LoadCdr, FilterCdr

### ۲.۶ UseCase Return Type

**تغییر در همه UseCase‌ها:**

```dart
// قبل:
class GetDashboardStatsUseCase {
  Future<Either<Failure, DashboardStats>> call();
}

// بعد:
class GetDashboardStatsUseCase {
  Future<Result<DashboardStats>> call();
}
```

**لیست UseCase‌های موجود:**
- `GetDashboardStatsUseCase`
- `GetExtensionsUseCase`
- `GetActiveCallsUseCase`
- `GetQueueStatusesUseCase`
- `GetCdrUseCase`

### ۲.۷ Error Handling

**ساختار Failure به صورت sealed:**

```dart
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(String message) : super(message);
}

final class ServerFailure extends AppFailure {
  const ServerFailure(String message) : super(message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(String message) : super(message);
}

final class CacheFailure extends AppFailure {
  const CacheFailure(String message) : super(message);
}
```

**استفاده:**
```dart
return switch (result) {
  Success(:final data) => DashboardLoaded(stats: data),
  Failure(:final message) => DashboardError(message),
};
```

---

## فاز ۳: بهینه‌سازی‌های اضافی

### ۳.۱ Logging بهتر

**فایل:** `lib/core/logger.dart`

```dart
enum LogLevel { debug, info, warning, error }

class AppLogger {
  static void log(String message, {LogLevel level = LogLevel.info}) {
    final emoji = switch (level) {
      LogLevel.debug => '🐛',
      LogLevel.info => '💡',
      LogLevel.warning => '⚠️',
      LogLevel.error => '❌',
    };
    
    print('$emoji [${level.name.toUpperCase()}] $message');
  }
}
```

### ۳.۲ Mock Data Generator

برای تست‌های واقعی‌تر، می‌توانید داده‌های رندوم تولید کنید:

**فایل:** `lib/data/repositories/mock/mock_data_generator.dart`

```dart
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
```

---

## چک‌لیست پیاده‌سازی

### Mock Repository
- [ ] ساخت `MockData` با داده‌های نمونه کامل
- [ ] پیاده‌سازی `MonitorRepositoryMock`
- [ ] پیاده‌سازی `ExtensionRepositoryMock`
- [ ] تنظیم DI با environment variable
- [ ] تست با `flutter run --dart-define=USE_MOCK=true`
- [ ] نوشتن unit tests

### Sealed Classes
- [ ] ایجاد `Result<T>` type
- [ ] تبدیل `DashboardBloc` states/events
- [ ] تبدیل `ExtensionBloc` states/events
- [ ] تبدیل `ActiveCallBloc` states/events
- [ ] تبدیل `QueueBloc` states/events
- [ ] تبدیل `CdrBloc` states/events
- [ ] Update کردن همه UseCase‌ها
- [ ] Update کردن UI widgets با pattern matching
- [ ] حذف dependency به dartz

---

## نکات مهم

### ۱. Asterisk AMI Event Format
- همه رویدادها با `\r\n\r\n` به هم متصل می‌شوند
- هر فیلد: `Key: Value\r\n`
- رویداد تمام شده: یک خط خالی اضافی

### ۲. SIP Status Codes
بر اساس مستندات Asterisk:
- `OK (X ms)`: RTT (Round Trip Time) در حال پینگ
- مقادیر نرمال: 10-100ms
- بالای 200ms: مشکل شبکه
- `UNREACHABLE`: بیش از 3 ping timeout

### ۳. Channel State Numbers
```
0 = Down
1 = Rsrvd
2 = OffHook
3 = Dialing
4 = Ring
5 = Ringing
6 = Up
7 = Busy
```

### ۴. Queue Member Status
```
0 = Unknown
1 = Not in use (available)
2 = In use (busy)
3 = Busy
4 = Invalid
5 = Unavailable
6 = Ringing
7 = On Hold
```

---

## مراجع

- [Asterisk AMI Documentation](https://wiki.asterisk.org/wiki/display/AST/Asterisk+Manager+Interface)
- [Dart 3 Sealed Classes](https://dart.dev/language/class-modifiers#sealed)
- [Flutter BLoC Pattern](https://bloclibrary.dev)

---

## سوالات متداول

**Q: آیا باید همه repository‌ها mock شوند؟**  
A: بله، حداقل `MonitorRepository`, `ExtensionRepository` و `QueueRepository`. CDR می‌تواند بعداً.

**Q: آیا mock data باید ثابت باشد؟**  
A: خیر، بهتر است کمی dynamic باشد (مثلاً زمان‌ها، وضعیت‌ها) تا واقعی‌تر به نظر برسد.

**Q: آیا sealed classes با Dart 2.x کار می‌کند؟**  
A: خیر، نیاز به Dart 3.0+ دارید. در `pubspec.yaml` بررسی کنید که `sdk: '>=3.0.0'` باشد.

**Q: چطور بین mock و real switch کنیم بدون rebuild؟**  
A: می‌توانید یک صفحه Settings اضافه کنید که در runtime تغییر دهد، اما نیاز به restart دارد.

---

**پایان راهنما**

برای شروع پیاده‌سازی، توصیه می‌شود ابتدا **فاز ۱** (Mock Repository) را کامل کنید، سپس **فاز ۲** (Sealed Classes) را شروع کنید.

موفق باشید! 🚀
