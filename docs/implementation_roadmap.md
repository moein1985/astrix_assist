# 🎯 Astrix Assist - نقشه راه پیاده‌سازی جامع

> **تاریخ ایجاد:** 2025-12-23  
> **نسخه سند:** 1.0  
> **هدف:** پیاده‌سازی دسترسی به Asterisk از طریق SSH + AMI با اسکریپت Python سمت سرور

---

## 📋 فهرست مطالب

1. [معماری کلی](#معماری-کلی)
2. [تقسیم‌بندی ویژگی‌ها](#تقسیم‌بندی-ویژگی‌ها)
3. [فاز 0: آماده‌سازی زیرساخت](#فاز-0-آماده‌سازی-زیرساخت)
4. [فاز 1: اسکریپت Python سمت سرور](#فاز-1-اسکریپت-python-سمت-سرور)
5. [فاز 2: یکپارچه‌سازی SSH](#فاز-2-یکپارچه‌سازی-ssh)
6. [فاز 3: تنظیم خودکار AMI](#فاز-3-تنظیم-خودکار-ami)
7. [فاز 4: بازنویسی DataSources](#فاز-4-بازنویسی-datasources)
8. [فاز 5: بهبود UI/UX](#فاز-5-بهبود-uiux)
9. [فاز 6: تست و اعتبارسنجی](#فاز-6-تست-و-اعتبارسنجی)
10. [ملاحظات فنی](#ملاحظات-فنی)

---

## معماری کلی

### ساختار فعلی (قبل از تغییرات):

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ MySQL/CDR   │    │ SSH/SFTP    │    │    AMI      │     │
│  │ (port 3306) │    │ (port 22)   │    │ (port 5038) │     │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   Asterisk Server                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   MariaDB    │  │  CSV Files   │  │   AMI        │      │
│  │   (CDR)      │  │ (Recordings) │  │  (disabled?) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### ساختار هدف (بعد از تغییرات):

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────┐    ┌─────────────────────┐ │
│  │      SSH Connection        │    │   AMI Connection    │ │
│  │      (port 22)             │    │   (port 5038)       │ │
│  │                            │    │                     │ │
│  │  - Python Script Execute   │    │  - Active Calls     │ │
│  │  - Auto AMI Setup          │    │  - ChanSpy          │ │
│  │  - Recording Download      │    │  - Originate        │ │
│  │                            │    │  - Events           │ │
│  └────────────┬───────────────┘    └──────────┬──────────┘ │
└───────────────┼────────────────────────────────┼────────────┘
                │                                │
                ▼                                ▼
┌─────────────────────────────────────────────────────────────┐
│                   Asterisk Server                           │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Python Script (astrix_collector.py)        │  │
│  │                                                       │  │
│  │  Input: Command + Arguments                          │  │
│  │  Output: JSON                                        │  │
│  │                                                       │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐ │  │
│  │  │   CDR   │  │  CEL    │  │ Config  │  │  Info   │ │  │
│  │  │   CSV   │  │  CSV    │  │  Files  │  │ System  │ │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                      AMI                              │  │
│  │              (Auto-configured by script)              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## تقسیم‌بندی ویژگی‌ها

### ویژگی‌های SSH + Python Script (داده‌های تاریخی و استاتیک):

| ویژگی | توضیحات | فایل فعلی | وضعیت |
|-------|---------|-----------|-------|
| **CDR (تاریخچه تماس‌ها)** | خواندن از CSV یا Database | `cdr_datasource.dart` | ⚠️ نیاز به بازنویسی |
| **Recordings List** | لیست فایل‌های ضبط شده | `ssh_service.dart` | ✅ موجود |
| **Recordings Download** | دانلود فایل‌های صوتی | `ssh_service.dart` | ✅ موجود |
| **System Info** | اطلاعات نسخه Asterisk و تنظیمات | - | ❌ جدید |
| **Extensions Config** | لیست داخلی‌های تعریف شده | - | ❌ جدید |
| **Queues Config** | تنظیمات صف‌ها | - | ❌ جدید |
| **Trunks Config** | تنظیمات ترانک‌ها | - | ❌ جدید |
| **Auto AMI Setup** | فعال‌سازی و تنظیم AMI | - | ❌ جدید |

### ویژگی‌های AMI (داده‌های Real-time):

| ویژگی | توضیحات | فایل فعلی | وضعیت |
|-------|---------|-----------|-------|
| **Active Calls** | تماس‌های فعال لحظه‌ای | `ami_listen_client.dart` | ✅ موجود |
| **Extensions Status** | وضعیت آنلاین/آفلاین داخلی‌ها | `ami_listen_client.dart` | ✅ موجود |
| **ChanSpy** | گوش دادن به تماس‌ها | `ami_listen_client.dart` | ✅ موجود |
| **Originate** | برقراری تماس | `ami_listen_client.dart` | ✅ موجود |
| **Hangup** | قطع تماس | `ami_listen_client.dart` | ✅ موجود |
| **Playback** | پخش فایل صوتی | `ami_listen_client.dart` | ✅ موجود |
| **Queue Status** | وضعیت لحظه‌ای صف‌ها | `ami_datasource.dart` | ✅ موجود |
| **Events Stream** | جریان رویدادها | `ami_listen_client.dart` | ✅ موجود |

---

## فاز 0: آماده‌سازی زیرساخت

### هدف:
آماده‌سازی ساختار پوشه‌ها و حذف وابستگی‌های غیرضروری

### تسک‌ها:

#### 0.1 حذف وابستگی MySQL
- **فایل:** `pubspec.yaml`
- **عملیات:** حذف `mysql1: ^0.20.0` از dependencies
- **دلیل:** دیگر نیازی به اتصال مستقیم MySQL نداریم

#### 0.2 ایجاد ساختار پوشه برای اسکریپت‌ها
```
lib/
├── core/
│   ├── scripts/
│   │   └── asterisk_collector.py    # اسکریپت Python
│   └── services/
│       └── python_executor.dart      # اجراکننده اسکریپت
assets/
└── scripts/
    └── asterisk_collector.py         # کپی برای bundle
```

#### 0.3 به‌روزرسانی assets در pubspec.yaml
- **فایل:** `pubspec.yaml`
- **عملیات:** اضافه کردن `- assets/scripts/` به بخش assets

---

## فاز 1: اسکریپت Python سمت سرور

### هدف:
ایجاد یک اسکریپت Python جامع که روی سرور Asterisk اجرا شود و داده‌ها را به فرمت JSON برگرداند

### 1.1 ویژگی‌های اسکریپت:

#### سازگاری نسخه Python:
- **Python 2.6+** (برای سیستم‌های قدیمی مثل CentOS 6)
- **Python 3.4+** (برای سیستم‌های جدید)
- استفاده از تشخیص خودکار نسخه و syntax مناسب

#### سازگاری نسخه Asterisk:
- **Asterisk 1.8+** (2010 به بعد)
- **Asterisk 11-22** (نسخه‌های LTS و جدید)
- تشخیص خودکار مسیرها و فرمت‌ها

### 1.2 دستورات اسکریپت:

| دستور | ورودی | خروجی JSON |
|-------|-------|------------|
| `info` | - | نسخه Asterisk، نسخه Python، مسیرها |
| `cdr` | `--days N`, `--limit N` | لیست تماس‌ها |
| `recordings` | `--days N`, `--date YYYY-MM-DD` | لیست فایل‌های ضبط شده |
| `extensions` | - | لیست داخلی‌های تعریف شده |
| `queues` | - | تنظیمات صف‌ها |
| `trunks` | - | تنظیمات ترانک‌ها |
| `setup-ami` | `--user X`, `--pass Y` | نتیجه تنظیم AMI |
| `check-ami` | - | وضعیت AMI |

### 1.3 ساختار خروجی JSON:

#### خروجی موفق:
```json
{
  "success": true,
  "timestamp": "2025-12-23T10:30:00",
  "data": { ... }
}
```

#### خروجی خطا:
```json
{
  "success": false,
  "error": "Error message",
  "error_code": "ERROR_CODE"
}
```

### 1.4 تشخیص خودکار مسیرها:

اسکریپت باید این مسیرها را به ترتیب بررسی کند:

**مسیرهای CDR:**
1. `/var/log/asterisk/cdr-csv/Master.csv`
2. `/var/log/asterisk/cdr/Master.csv`
3. `/var/log/asterisk/cdr.csv`

**مسیرهای Recordings:**
1. `/var/spool/asterisk/monitor/`
2. `/var/spool/asterisk/recording/`
3. `/var/spool/asterisk/voicemail/`

**مسیرهای Config:**
1. `/etc/asterisk/` (استاندارد)
2. `/usr/local/etc/asterisk/` (FreeBSD)

### 1.5 تست سازگاری:

اسکریپت باید با این سیستم‌ها سازگار باشد:

| سیستم عامل | Python | Asterisk |
|------------|--------|----------|
| CentOS 6 | 2.6, 2.7 | 1.8, 11 |
| CentOS 7 | 2.7 | 13, 16 |
| CentOS 8/Rocky 8 | 3.6, 3.8 | 16, 18 |
| Debian 9 | 2.7, 3.5 | 13 |
| Debian 10 | 3.7 | 16 |
| Debian 11 | 3.9 | 18 |
| Ubuntu 18.04 | 3.6 | 15 |
| Ubuntu 20.04 | 3.8 | 18 |
| Ubuntu 22.04 | 3.10 | 20 |

---

## فاز 2: یکپارچه‌سازی SSH

### هدف:
ایجاد سرویس جدید برای مدیریت SSH و اجرای اسکریپت Python

### 2.1 ایجاد AsteriskSshManager

- **فایل جدید:** `lib/core/services/asterisk_ssh_manager.dart`
- **وابستگی:** از `SshService` موجود ارث‌بری کند یا آن را wrap کند

#### مسئولیت‌ها:
1. اتصال به سرور با SSH
2. آپلود اسکریپت Python (اگر وجود نداشته باشد یا نسخه جدیدتر باشد)
3. اجرای دستورات اسکریپت و دریافت JSON
4. Parse کردن JSON و تبدیل به Model های Dart
5. مدیریت خطاها و retry logic

### 2.2 مدیریت نسخه اسکریپت

- ذخیره نسخه اسکریپت در خود اسکریپت (مثلاً `VERSION = "1.0.0"`)
- هنگام اتصال، نسخه روی سرور را با نسخه محلی مقایسه کن
- اگر نسخه محلی جدیدتر بود، اسکریپت جدید را آپلود کن

### 2.3 مسیر ذخیره اسکریپت روی سرور

```
/usr/local/bin/astrix_collector.py
```

یا اگر دسترسی نوشتن نداشتیم:

```
/tmp/astrix_collector.py
```

### 2.4 اجرای امن اسکریپت

- اسکریپت با Python سیستم اجرا شود
- تشخیص خودکار `python` یا `python3`
- Timeout مناسب برای هر دستور

---

## فاز 3: تنظیم خودکار AMI

### هدف:
فعال‌سازی خودکار AMI و ایجاد کاربر برای برنامه

### 3.1 بررسی وضعیت AMI

اسکریپت Python باید:
1. فایل `/etc/asterisk/manager.conf` را بخواند
2. بررسی کند AMI فعال است یا نه (`enabled = yes/no`)
3. بررسی کند کاربر `astrix_assist` وجود دارد یا نه

### 3.2 فعال‌سازی AMI

اگر AMI غیرفعال باشد:
1. در فایل `manager.conf` مقدار `enabled = no` را به `enabled = yes` تغییر بده
2. یا خط جدید اضافه کن

### 3.3 ایجاد کاربر AMI

یک کاربر جدید با این مشخصات:
- **نام کاربری:** `astrix_assist` (ثابت) یا `astrix_{random}`
- **رمز عبور:** تولید رندوم (حداقل 16 کاراکتر)
- **دسترسی‌ها:** read و write برای: `system, call, log, command, agent, user, dtmf, reporting, cdr, originate`

### 3.4 ذخیره credentials در برنامه

پس از ایجاد کاربر AMI:
1. Credentials را در Flutter Secure Storage ذخیره کن
2. AmiListenClient را با این credentials مقداردهی کن

### 3.5 Reload کردن AMI

پس از تغییرات:
```bash
asterisk -rx "manager reload"
```

### 3.6 تست اتصال AMI

- تلاش برای login با credentials جدید
- اگر موفق نبود، لاگ خطا و پیشنهاد manual setup

---

## فاز 4: بازنویسی DataSources

### هدف:
جایگزینی MySQL DataSource با SSH + Python DataSource

### 4.1 حذف CdrDataSource فعلی

- **فایل:** `lib/data/datasources/cdr_datasource.dart`
- **عملیات:** حذف یا deprecated کردن
- **دلیل:** دیگر از MySQL استفاده نمی‌کنیم

### 4.2 ایجاد SshCdrDataSource جدید

- **فایل جدید:** `lib/data/datasources/ssh_cdr_datasource.dart`
- **وابستگی:** `AsteriskSshManager`

#### متدها:
- `getCdrRecords({days, limit, src, dst, disposition})` → `List<CdrModel>`
- `getCdrByUniqueId(uniqueId)` → `CdrModel?`
- `exportCdrToCsv({records, filePath})` → `File`

### 4.3 ایجاد SshSystemDataSource

- **فایل جدید:** `lib/data/datasources/ssh_system_datasource.dart`

#### متدها:
- `getSystemInfo()` → `SystemInfo`
- `getExtensionsConfig()` → `List<ExtensionConfig>`
- `getQueuesConfig()` → `List<QueueConfig>`
- `getTrunksConfig()` → `List<TrunkConfig>`

### 4.4 به‌روزرسانی Repositories

فایل‌هایی که باید تغییر کنند:
- `lib/data/repositories/cdr_repository_impl.dart`
- (ایجاد جدید) `lib/data/repositories/system_repository_impl.dart`

### 4.5 به‌روزرسانی Dependency Injection

- **فایل:** `lib/core/injection_container.dart`
- **عملیات:** 
  - حذف ثبت `CdrDataSource` قدیمی
  - ثبت `SshCdrDataSource` جدید
  - ثبت `AsteriskSshManager`
  - ثبت `SshSystemDataSource`

---

## فاز 5: بهبود UI/UX

### هدف:
ساده‌سازی تنظیمات و بهبود تجربه کاربری

### 5.1 ساده‌سازی صفحه تنظیمات

- **فایل:** `lib/presentation/pages/settings_page.dart`

#### تغییرات:
- حذف بخش تنظیمات MySQL
- ادغام تنظیمات SSH و AMI در یک فرم ساده
- نمایش: Host, Port, Username, Password (فقط SSH)
- AMI به صورت خودکار تنظیم می‌شود

### 5.2 فرآیند Setup اولیه

#### صفحه جدید: `lib/presentation/pages/server_setup_page.dart`

مراحل:
1. **ورود اطلاعات SSH**
   - Host
   - Port (پیش‌فرض: 22)
   - Username (پیش‌فرض: root)
   - Password

2. **تست اتصال SSH**
   - دکمه "تست اتصال"
   - نمایش نتیجه (موفق/ناموفق)

3. **تنظیم خودکار**
   - آپلود اسکریپت Python
   - دریافت اطلاعات سیستم
   - فعال‌سازی AMI
   - ایجاد کاربر AMI

4. **تأیید و ذخیره**
   - نمایش خلاصه تنظیمات
   - ذخیره و ورود به Dashboard

### 5.3 نمایش وضعیت اتصال

- **Widget:** `connection_status_widget.dart` (موجود)
- **تغییرات:** 
  - نمایش وضعیت SSH جداگانه از AMI
  - آیکون‌های متفاوت برای هر کدام

### 5.4 صفحه CDR

- **فایل:** `lib/presentation/pages/cdr_page.dart`
- **تغییرات:**
  - حذف پیغام‌های مرتبط با MySQL
  - اضافه کردن loading state بهتر
  - نمایش تعداد رکوردها

### 5.5 صفحه System Info (جدید)

- **فایل جدید:** `lib/presentation/pages/system_info_page.dart`
- **محتوا:**
  - نسخه Asterisk
  - نسخه سیستم عامل
  - وضعیت AMI
  - مسیر CDR
  - مسیر Recordings
  - تعداد داخلی‌ها، صف‌ها، ترانک‌ها

---

## فاز 6: تست و اعتبارسنجی

### 6.1 تست واحد (Unit Tests)

#### فایل‌های تست:
- `test/data/datasources/ssh_cdr_datasource_test.dart`
- `test/core/services/asterisk_ssh_manager_test.dart`
- `test/core/services/python_executor_test.dart`

#### موارد تست:
- Parse کردن خروجی JSON
- Handle کردن خطاهای مختلف
- مدیریت timeout

### 6.2 تست یکپارچه‌سازی (Integration Tests)

#### سناریوهای تست:
1. اتصال SSH به سرور Issabel
2. آپلود و اجرای اسکریپت Python
3. دریافت لیست CDR
4. دانلود recording
5. تنظیم خودکار AMI
6. اتصال AMI و دریافت active calls

### 6.3 تست سازگاری

#### سیستم‌هایی که باید تست شوند:
- [ ] Issabel 4.x (CentOS 7 + Asterisk 13)
- [ ] Issabel 5.x (Rocky 8 + Asterisk 18)
- [ ] FreePBX 15
- [ ] FreePBX 16
- [ ] Elastix 5
- [ ] Vanilla Asterisk 18

### 6.4 تست عملکرد

- زمان دریافت 1000 رکورد CDR
- زمان دانلود recording 10MB
- مصرف حافظه
- مصرف باتری

---

## ملاحظات فنی

### امنیت

#### ذخیره اطلاعات حساس:
- رمز SSH در `flutter_secure_storage`
- رمز AMI در `flutter_secure_storage`
- هیچ credential در لاگ‌ها

#### اسکریپت Python:
- دسترسی فقط با root
- بدون ذخیره اطلاعات حساس در فایل

### مدیریت خطا

#### خطاهای SSH:
- `CONNECTION_REFUSED`: سرور در دسترس نیست
- `AUTH_FAILED`: نام کاربری/رمز اشتباه
- `TIMEOUT`: timeout اتصال
- `HOST_KEY_VERIFICATION`: مشکل کلید سرور

#### خطاهای Script:
- `SCRIPT_NOT_FOUND`: اسکریپت پیدا نشد
- `PARSE_ERROR`: خروجی قابل parse نیست
- `PERMISSION_DENIED`: دسترسی نداریم
- `FILE_NOT_FOUND`: فایل CDR پیدا نشد

#### خطاهای AMI:
- `AMI_DISABLED`: AMI فعال نیست
- `AUTH_FAILED`: رمز AMI اشتباه
- `CONNECTION_REFUSED`: پورت 5038 بسته است

### بهینه‌سازی

#### Caching:
- Cache کردن System Info (هر 1 ساعت)
- Cache کردن Extensions Config (هر 5 دقیقه)
- Cache کردن CDR های اخیر (هر 1 دقیقه)

#### Pagination:
- CDR: حداکثر 100 رکورد در هر صفحه
- Recordings: حداکثر 50 فایل در هر صفحه

#### Compression:
- اگر CDR بیش از 1000 رکورد باشد، JSON را gzip کن

---

## چک‌لیست پیاده‌سازی

### فاز 0:
- [ ] حذف mysql1 از pubspec.yaml
- [ ] ایجاد پوشه assets/scripts/
- [ ] به‌روزرسانی pubspec.yaml برای assets

### فاز 1:
- [ ] نوشتن اسکریپت Python
- [ ] تست با Python 2.7
- [ ] تست با Python 3.6+
- [ ] تست با Issabel
- [ ] تست با FreePBX

### فاز 2:
- [ ] ایجاد AsteriskSshManager
- [ ] پیاده‌سازی آپلود اسکریپت
- [ ] پیاده‌سازی اجرای دستورات
- [ ] پیاده‌سازی version check

### فاز 3:
- [ ] پیاده‌سازی check-ami در اسکریپت
- [ ] پیاده‌سازی setup-ami در اسکریپت
- [ ] تست فعال‌سازی AMI
- [ ] تست ایجاد کاربر AMI

### فاز 4:
- [ ] ایجاد SshCdrDataSource
- [ ] ایجاد SshSystemDataSource
- [ ] به‌روزرسانی repositories
- [ ] به‌روزرسانی injection_container

### فاز 5:
- [ ] ساده‌سازی settings_page
- [ ] ایجاد server_setup_page
- [ ] به‌روزرسانی connection_status_widget
- [ ] ایجاد system_info_page

### فاز 6:
- [ ] نوشتن unit tests
- [ ] تست روی Issabel
- [ ] تست روی FreePBX
- [ ] تست عملکرد

---

## زمان‌بندی پیشنهادی

| فاز | مدت زمان | اولویت |
|-----|----------|--------|
| فاز 0 | 2 ساعت | 🔴 بالا |
| فاز 1 | 8 ساعت | 🔴 بالا |
| فاز 2 | 6 ساعت | 🔴 بالا |
| فاز 3 | 4 ساعت | 🟡 متوسط |
| فاز 4 | 6 ساعت | 🔴 بالا |
| فاز 5 | 4 ساعت | 🟡 متوسط |
| فاز 6 | 6 ساعت | 🟢 پایین |
| **مجموع** | **36 ساعت** | |

---

## نتیجه‌گیری

با پیاده‌سازی این معماری:

1. ✅ **حذف وابستگی MySQL** - سازگاری با همه توزیع‌ها
2. ✅ **یک پسورد** - فقط SSH credentials از کاربر گرفته می‌شود
3. ✅ **تنظیم خودکار AMI** - بدون نیاز به دانش فنی کاربر
4. ✅ **خروجی JSON** - بدون regex و parsing پیچیده
5. ✅ **سازگاری بالا** - Python 2.6+ و Asterisk 1.8+
6. ✅ **رویکرد Ansible-like** - industry standard

---

> **نکته:** این سند زنده است و با پیشرفت پروژه به‌روزرسانی می‌شود.
