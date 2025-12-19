# Astrix Assist - نقشه راه توسعه

این سند شامل پیشنهادات بهبود و ویژگی‌های جدید برای اپلیکیشن Astrix Assist است.

---

## 📌 اطلاعات پروژه

- **نوع پروژه:** Flutter Application
- **هدف:** مدیریت سرورهای Asterisk/Issabel از طریق AMI
- **معماری:** Clean Architecture با BLoC Pattern
- **مسیر اصلی:** `lib/`

### ساختار فعلی پروژه:
```
lib/
├── core/           # تنظیمات، router، theme، DI
├── data/           # datasources، models، repositories
├── domain/         # entities، usecases، services
└── presentation/   # blocs، pages، widgets
```

### صفحات موجود:
- `login_page.dart` - مدیریت سرورها
- `extensions_page.dart` - لیست داخلی‌ها
- `extension_detail_page.dart` - جزئیات داخلی
- `active_calls_page.dart` - تماس‌های فعال
- `queues_page.dart` - وضعیت صف‌ها
- `originate_page.dart` - برقراری تماس

---

## 🎯 فاز ۱: بهبود Navigation و UX (اولویت بالا)

### 1.1 افزودن BottomNavigationBar

**هدف:** دسترسی سریع‌تر به بخش‌های اصلی اپلیکیشن

**کارهای لازم:**
1. ایجاد یک `MainShell` widget که شامل `Scaffold` با `BottomNavigationBar` باشد
2. استفاده از `ShellRoute` در `go_router` برای wrap کردن صفحات اصلی
3. آیتم‌های navigation:
   - 🏠 Dashboard (جدید)
   - 📞 Extensions
   - 📊 Calls
   - 👥 Queues
   - ⚙️ Settings

**فایل‌های تغییر:**
- `lib/core/router.dart` - اضافه کردن ShellRoute
- ایجاد `lib/presentation/widgets/main_shell.dart`

**نکته مهم:** صفحه Login نباید در shell باشد. فقط بعد از اتصال به سرور، shell فعال شود.

---

### 1.2 ایجاد صفحه Dashboard

**هدف:** نمای کلی از وضعیت سیستم در یک نگاه

**محل فایل:** `lib/presentation/pages/dashboard_page.dart`

**اجزای داشبورد:**
1. **کارت‌های آماری:**
   - تعداد Extensions (Online/Offline)
   - تعداد تماس‌های فعال
   - تعداد تماس‌های در صف
   - میانگین زمان انتظار

2. **وضعیت سرور:**
   - نام سرور متصل
   - آیکون وضعیت اتصال (سبز/قرمز)
   - زمان آخرین به‌روزرسانی

3. **لیست تماس‌های فعال (خلاصه):**
   - حداکثر ۵ تماس اخیر
   - دکمه "مشاهده همه"

**BLoC جدید:** `DashboardBloc` در `lib/presentation/blocs/`

**UseCase جدید:** `GetDashboardStatsUseCase` که همزمان extensions، calls و queues را fetch کند

---

### 1.3 نمایش وضعیت اتصال در AppBar

**هدف:** کاربر همیشه بداند به کدام سرور متصل است و وضعیت اتصال چیست

**پیاده‌سازی:**
1. ایجاد `ConnectionStatusWidget` در `lib/presentation/widgets/`
2. این ویجت شامل:
   - نام سرور (کوتاه شده)
   - آیکون وضعیت (🟢 متصل / 🔴 قطع / 🟡 در حال اتصال)
   - tap برای نمایش جزئیات بیشتر

3. استفاده از `ValueNotifier` یا `StreamController` برای مدیریت وضعیت اتصال در `AmiDataSource`

**فایل‌های تغییر:**
- `lib/data/datasources/ami_datasource.dart` - اضافه کردن stream وضعیت
- ایجاد `lib/presentation/widgets/connection_status_widget.dart`

---

## 🎯 فاز ۲: ویژگی‌های جدید تماس (اولویت بالا)

### 2.1 Transfer تماس

**هدف:** انتقال تماس فعال به داخلی دیگر

**پیاده‌سازی:**
1. دکمه Transfer در لیست تماس‌های فعال (کنار دکمه Hangup)
2. باز شدن dialog برای انتخاب مقصد:
   - جستجو در لیست extensions
   - یا وارد کردن شماره دستی
3. دو نوع Transfer:
   - Blind Transfer (مستقیم)
   - Attended Transfer (با معرفی)

**AMI Action:**
```
Action: Redirect
Channel: <channel>
Exten: <destination>
Context: from-internal
Priority: 1
```

**فایل‌های جدید:**
- `lib/domain/usecases/transfer_call_usecase.dart`
- `lib/presentation/widgets/transfer_dialog.dart`

**تغییر در:**
- `lib/data/datasources/ami_datasource.dart` - متد `transfer()`
- `lib/presentation/blocs/active_call_bloc.dart` - event جدید `TransferCall`

---

### 2.2 نمایش زمان Real-time تماس

**هدف:** نمایش مدت تماس به صورت live

**پیاده‌سازی:**
1. ایجاد `CallDurationWidget` که یک `Timer` داخلی دارد
2. دریافت زمان شروع تماس از `ActiveCall` entity
3. فرمت نمایش: `00:00:00` (ساعت:دقیقه:ثانیه)
4. رنگ‌بندی بر اساس مدت:
   - سبز: کمتر از ۵ دقیقه
   - نارنجی: ۵ تا ۱۵ دقیقه
   - قرمز: بیشتر از ۱۵ دقیقه

**فایل جدید:** `lib/presentation/widgets/call_duration_widget.dart`

---

## 🎯 فاز ۳: مدیریت اپراتورها (اولویت متوسط)

### 3.1 Pause/Unpause اپراتور

**هدف:** مدیر بتواند اپراتور را از صف خارج یا وارد کند

**پیاده‌سازی:**
1. در صفحه Queues، روی هر agent دکمه Pause/Unpause
2. نمایش وضعیت فعلی (Paused/Available)
3. امکان وارد کردن دلیل Pause

**AMI Actions:**
```
Action: QueuePause
Queue: <queue-name>
Interface: <agent-interface>
Paused: true/false
Reason: <optional-reason>
```

**فایل‌های جدید:**
- `lib/domain/usecases/pause_agent_usecase.dart`
- `lib/domain/usecases/unpause_agent_usecase.dart`

**تغییر در:**
- `lib/presentation/blocs/queue_bloc.dart` - events جدید
- `lib/presentation/pages/queues_page.dart` - UI دکمه‌ها

---

### 3.2 صفحه جزئیات اپراتور

**هدف:** نمایش آمار و وضعیت کامل یک اپراتور

**محل فایل:** `lib/presentation/pages/agent_detail_page.dart`

**اطلاعات نمایشی:**
- نام/شماره اپراتور
- وضعیت (Available/Paused/Busy)
- تعداد تماس‌های پاسخ داده شده امروز
- میانگین زمان مکالمه
- زمان آخرین تماس
- صف‌هایی که عضو است

**Route جدید:** `/agent/:id` در router

---

## 🎯 فاز ۴: گزارشات (اولویت متوسط)

### 4.1 صفحه CDR (Call Detail Records)

**هدف:** مشاهده تاریخچه تماس‌ها

**نکته مهم:** CDR معمولاً از دیتابیس MySQL خوانده می‌شود، نه از AMI. بررسی کن که آیا سرور API دارد یا باید مستقیم به MySQL وصل شد.

**محل فایل:** `lib/presentation/pages/cdr_page.dart`

**ویژگی‌ها:**
1. فیلتر بر اساس:
   - تاریخ (از/تا)
   - شماره مبدا
   - شماره مقصد
   - وضعیت (Answered/NoAnswer/Busy/Failed)

2. لیست تماس‌ها با اطلاعات:
   - تاریخ و ساعت
   - مبدا → مقصد
   - مدت تماس
   - وضعیت

3. امکان Export به CSV

**فایل‌های جدید:**
- `lib/domain/entities/cdr_record.dart`
- `lib/data/models/cdr_model.dart`
- `lib/domain/usecases/get_cdr_usecase.dart`
- `lib/presentation/blocs/cdr_bloc.dart`

---

## 🎯 فاز ۵: مانیتورینگ پیشرفته (اولویت پایین)

### 5.1 مانیتورینگ Trunk ها

**AMI Action:**
```
Action: SIPshowregistry
```

**صفحه جدید:** `lib/presentation/pages/trunks_page.dart`

**اطلاعات نمایشی:**
- نام Trunk
- Host
- وضعیت ثبت‌نام (Registered/Unregistered)
- تعداد کانال‌های فعال

---

### 5.2 Parking Lot

**AMI Action:**
```
Action: ParkedCalls
```

**صفحه جدید:** `lib/presentation/pages/parking_page.dart`

**ویژگی‌ها:**
- لیست تماس‌های Park شده
- شماره Parking Slot
- زمان Park
- دکمه برداشتن (Pickup)

---

### 5.3 Spy/Whisper (اختیاری)

**توجه:** این ویژگی حساس است و باید با احتیاط پیاده‌سازی شود.

**AMI Action:**
```
Action: Originate
Channel: SIP/<spy-extension>
Application: ChanSpy
Data: SIP/<target-extension>,qw
```

---

## 🎨 فاز ۶: بهبود UI/UX

### 6.1 تم و رنگ‌بندی

**کارها:**
1. تعریف `ColorScheme` سفارشی در `theme_manager.dart`
2. استفاده از `Material 3` design
3. رنگ‌های پیشنهادی:
   - Primary: آبی (#1976D2)
   - Online/Success: سبز (#4CAF50)
   - Offline/Error: قرمز (#F44336)
   - Warning: نارنجی (#FF9800)

### 6.2 انیمیشن‌ها

**پیشنهادات:**
1. `AnimatedList` برای لیست تماس‌ها (وقتی تماس اضافه/حذف می‌شود)
2. `Hero` animation برای رفتن به صفحه جزئیات
3. `Shimmer` effect برای loading state

### 6.3 فونت فارسی

**پیشنهاد:** استفاده از فونت Vazirmatn

```yaml
# pubspec.yaml
fonts:
  - family: Vazirmatn
    fonts:
      - asset: assets/fonts/Vazirmatn-Regular.ttf
      - asset: assets/fonts/Vazirmatn-Bold.ttf
        weight: 700
```

### 6.4 Responsive Design

**کارها:**
1. استفاده از `LayoutBuilder` برای تشخیص سایز صفحه
2. در تبلت: نمایش `NavigationRail` به جای `BottomNavigationBar`
3. در desktop: نمایش `NavigationDrawer` ثابت

---

## 🔔 فاز ۷: اطلاع‌رسانی (Notifications)

### 7.1 Local Notifications

**پکیج پیشنهادی:** `flutter_local_notifications`

**موارد اطلاع‌رسانی:**
- قطع اتصال به سرور
- صف شلوغ (بیش از X تماس در انتظار)
- Extension آفلاین شد

### 7.2 Background Service (اختیاری)

**پکیج:** `workmanager` یا `flutter_background_service`

برای چک کردن وضعیت سرور در پس‌زمینه

---

## 📋 چک‌لیست پیاده‌سازی

### فاز ۱ (ضروری)
- [ ] BottomNavigationBar با ShellRoute
- [ ] صفحه Dashboard
- [ ] Connection Status Widget

### فاز ۲ (مهم)
- [ ] Transfer تماس
- [ ] زمان real-time تماس
- [ ] بهبود لیست تماس‌ها

### فاز ۳
- [ ] Pause/Unpause اپراتور
- [ ] صفحه جزئیات اپراتور

### فاز ۴
- [ ] صفحه CDR
- [ ] فیلتر و جستجو
- [ ] Export

### فاز ۵
- [ ] مانیتورینگ Trunk
- [ ] Parking Lot

### فاز ۶
- [ ] تم جدید
- [ ] انیمیشن‌ها
- [ ] Responsive

### فاز ۷
- [ ] Notifications
- [ ] Background service

---

## 🚀 شروع کار

**پیشنهاد:** با فاز ۱ شروع کن. ابتدا BottomNavigationBar را پیاده‌سازی کن، سپس Dashboard و در نهایت Connection Status.

برای هر بخش:
1. ابتدا entity/model را ایجاد کن (در صورت نیاز)
2. سپس usecase را بنویس
3. bloc را ایجاد کن
4. در نهایت UI را بساز

**موفق باشی! 🎉**
