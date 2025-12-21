# Deprecated Files

این پوشه شامل فایل‌هایی است که دیگر استفاده نمی‌شوند اما برای مرجع نگهداری شده‌اند.

## Backend Proxy (Deprecated)

این فایل‌ها مربوط به معماری قدیمی Backend Proxy هستند که حذف شدند:

- `ami_backend_proxy.dart` - سرور پروکسی اصلی
- `ami_proxy_server.dart` - سرور پروکسی جایگزین  
- `mock_ami_server.dart` - سرور mock برای AMI
- `mock_recording_server.dart` - سرور mock برای ضبط‌ها

## دلیل حذف

با تغییر معماری به استفاده مستقیم از AMI (بدون پروکسی)، این فایل‌ها دیگر مورد نیاز نیستند:

- **قبل:** Flutter App → Backend Proxy → Asterisk AMI
- **الان:** Flutter App → Asterisk AMI (مستقیم با `AmiListenClient`)

برای دانلود ضبط‌ها از SSH/SCP استفاده می‌شود بجای وب‌سرور.

---
*تاریخ: دسامبر 2025*
