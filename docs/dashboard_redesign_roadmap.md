# نقشه راه بازطراحی داشبورد پروژه Astrix Assist

## مقدمه
این سند نقشه راه دقیقی برای بازطراحی صفحه داشبورد پروژه Astrix Assist بر اساس ساختار داشبورد پروژه Mik Flutter ارائه می‌دهد. هدف اصلی حذف bottom app bar (در صورت وجود)، تبدیل منوها به کارت‌های گروه‌بندی شده، و انتقال قسمت system resources به داشبورد است.

## تحلیل فعلی
### داشبورد Mik Flutter
- **ساختار**: Scaffold با appBar و body (بدون bottom app bar).
- **محتوا**:
  - کارت اطلاعات سیستم (system resources) در بالا.
  - بخش‌های گروه‌بندی شده با کارت‌ها برای منوها (Network Management, Security & Access, etc.).
- **ویژگی‌ها**: کارت‌های مربعی برای هر آیتم منو با آیکون و رنگ‌بندی.

### داشبورد Astrix Assist (کنونی)
- **ساختار**: Scaffold با appBar و body (بدون bottom app bar در کد فعلی).
- **محتوا**:
  - کارت Quick Tip.
  - گرید آماری (Extensions, Active Calls, etc.).
  - بخش تماس‌های اخیر.
- **منوها**: در navigation bar یا drawer (نه در داشبورد).

## اهداف تغییرات
1. **حذف bottom app bar**: اگر در navigation اصلی app وجود دارد، حذف شود.
2. **تبدیل منوها به کارت‌ها**: منوهای موجود (Extensions, Queues, etc.) را از navigation به کارت‌های گروه‌بندی شده در داشبورد منتقل کنیم.
3. **اضافه کردن قسمت system resources**: کارت اطلاعات سیستم را در بالای داشبورد اضافه کنیم (اگر داده‌ها موجود باشد).
4. **نگه داشتن عناصر موجود**: Quick Tip، گرید آماری، و تماس‌های اخیر را حفظ و ادغام کنیم.

## پیش‌نیازها
- دسترسی به داده‌های سیستم (CPU، حافظه، ذخیره‌سازی) در DashboardState. اگر موجود نیست، باید به DashboardBloc و مدل‌ها اضافه شود.
- لیست منوهای موجود در navigation (Extensions, Queues, Settings, etc.) برای تبدیل به کارت‌ها.

## مراحل پیاده‌سازی

### مرحله 1: بررسی و آماده‌سازی داده‌ها
1. **بررسی DashboardState**: اطمینان حاصل کنید که فیلدهایی برای اطلاعات سیستم (مانند `systemResource` در Mik Flutter) وجود دارد.
   - اگر نه، کلاس `DashboardState` را در `lib/presentation/blocs/dashboard_state.dart` به‌روزرسانی کنید.
   - مدل `SystemResource` را اضافه کنید (اگر موجود نیست).
2. **به‌روزرسانی DashboardBloc**: event و logic برای بارگذاری اطلاعات سیستم اضافه کنید.
   - فایل `lib/presentation/blocs/dashboard_bloc.dart` را ویرایش کنید.
3. **لیست منوها**: منوهای موجود در navigation را شناسایی کنید (از `lib/core/router/app_router.dart` یا فایل‌های مرتبط).

### مرحله 2: ساختار جدید داشبورد
1. **ویرایش `lib/presentation/pages/dashboard_page.dart`**:
   - متد `build` را تغییر دهید تا ساختار مشابه Mik Flutter داشته باشد.
   - قسمت system resources را در بالای body اضافه کنید (اگر داده‌ها موجود باشد).
   - بخش‌های گروه‌بندی شده را اضافه کنید.

2. **اضافه کردن متدهای کمکی**:
   - `_buildDashboardSection`: برای ایجاد بخش‌های گروه‌بندی شده (عنوان با آیکون و رنگ).
   - `_buildSectionCard`: برای کارت‌های منو (آیکون، عنوان، رنگ پس‌زمینه، onTap).
   - `_buildInfoRow`, `_buildProgressRow`, `_buildMemoryRow`: برای نمایش اطلاعات سیستم.

### مرحله 3: انتقال منوها
1. **شناسایی منوها**: لیست منوهای موجود:
   - Extensions
   - Queues
   - Settings
   - Logs (اگر موجود)
   - سایر منوهای navigation.

2. **گروه‌بندی منوها**:
   - **مدیریت تماس‌ها**: Extensions, Queues.
   - **تنظیمات**: Settings.
   - **ابزارها**: Logs, etc.
   - رنگ‌بندی و آیکون‌ها را از Mik Flutter الهام بگیرید.

3. **پیاده‌سازی کارت‌ها**:
   - هر کارت با `ModernCard` یا `Card` بسازید.
   - onTap برای navigation به صفحه مربوطه (با `context.push`).

### مرحله 4: حذف bottom app bar
1. **بررسی navigation اصلی**: فایل `lib/main.dart` یا `lib/core/router/app_router.dart` را چک کنید.
   - اگر `BottomNavigationBar` یا `BottomAppBar` وجود دارد، حذف کنید.
2. **به‌روزرسانی Scaffold**: اطمینان حاصل کنید که فقط appBar و body داشته باشد.

### مرحله 5: ادغام عناصر موجود
1. **Quick Tip**: در بالای داشبورد نگه دارید.
2. **گرید آماری**: به عنوان یک بخش جداگانه نگه دارید یا ادغام کنید.
3. **تماس‌های اخیر**: به عنوان بخش پایانی نگه دارید.

### مرحله 6: تست و بهینه‌سازی
1. **تست UI**: اطمینان حاصل کنید که کارت‌ها responsive هستند (با `GridView` یا `Wrap`).
2. **تست navigation**: onTap هر کارت به صفحه درست برود.
3. **بهینه‌سازی**: رنگ‌ها، فونت‌ها، و spacing را مطابق theme پروژه تنظیم کنید.
4. **دسترسی‌پذیری**: اطمینان از RTL support (در Astrix Assist موجود است).

## نمونه کد (شبه‌کد)
```dart
// در build method
return Scaffold(
  appBar: AppBar(...),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // System Resources Card (if available)
        if (systemResource != null) _buildSystemResourcesCard(systemResource, l10n),
        
        // Quick Tip
        QuickTipCard(tip: l10n.dashboardQuickTip),
        
        // Stats Grid
        _buildStatsGrid(state, l10n),
        
        // Menu Sections
        _buildDashboardSection(
          context,
          'مدیریت تماس‌ها',
          Icons.phone,
          Colors.blue,
          [
            _buildSectionCard(context, l10n.extensions, Icons.phone, Colors.blue.shade100, () => context.push('/extensions')),
            _buildSectionCard(context, l10n.queues, Icons.queue, Colors.green.shade100, () => context.push('/queues')),
          ],
        ),
        
        // Recent Calls
        _buildRecentCallsSection(state, l10n),
      ],
    ),
  ),
);
```

## ریسک‌ها و ملاحظات
- **داده‌های سیستم**: اگر موجود نباشد، ممکن است نیاز به API جدید داشته باشد.
- **navigation**: اطمینان از اینکه همه مسیرها درست کار کنند.
- **عملکرد**: با کارت‌های زیاد، از `SingleChildScrollView` استفاده کنید.
- **سازگاری**: تست روی دستگاه‌های مختلف.

## نتیجه نهایی
پس از اعمال این تغییرات، داشبورد Astrix Assist شبیه Mik Flutter خواهد بود: بدون bottom app bar، با کارت‌های گروه‌بندی شده برای منوها، و قسمت system resources در بالا.