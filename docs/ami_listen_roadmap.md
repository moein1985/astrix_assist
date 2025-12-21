<!--
Roadmap for implementing Live Listen (ChanSpy) and Recorded Playback
for Astrix Assist. Written in Persian, compatible with current UI/UX.
-->
# نقشه‌راه پیاده‌سازی قابلیت‌های شنود زنده و پخش ضبط‌ها

تاریخ: 2025-12-21

هدف این سند: ارائه یک نقشه‌راه فنی و گام‌به‌گام برای اضافه کردن دو قابلیت به اپلیکیشن Astrix Assist:

- شنود زنده مکالمه بین دو نفر (Live Listen / Eavesdrop)
- پخش پیام‌های ضبط‌شده (Recorded Playback)

طراحی طوری انتخاب شده که با UI/UX فعلی برنامه سازگار باشد و کمترین تغییرات در ساختار کلی را نیاز داشته باشد.

---

## خلاصه پیشنهادی (مقدماتی)

- برای پخش ضبط‌ها: از رویکرد ساده و سریع استفاده می‌کنیم — فایل‌های ضبط را از سرور Asterisk/فایل‌سیستم از طریق یک endpoint امن HTTP استریم کرده و در اپ با یک پلیر داخلی (مثلاً `just_audio`) پخش می‌کنیم. این روش نیاز به تغییرات کم در PBX دارد و سریع‌ترین ارزش را می‌دهد.
- برای شنود زنده (MVP): از AMI `Originate` برای برقراری یک تماس به یک endpoint ناظر (supervisor SIP یا Local channel) و اجرای `ChanSpy` استفاده می‌کنیم. این راهکار سریع و کم‌ریسک است. در فاز بعدی می‌توانیم WebRTC Gateway برای شنیدن درون‌اپی اضافه کنیم.

---

## اهداف عملیاتی

1. پیاده‌سازی قابلیت پخش ضبط‌ها در `Call History` (فایل‌های WAV/GSM)
2. پیاده‌سازی MVP شنود زنده: دکمهٔ `Listen Live` در `Extensions` و `Active Calls` که به صورت امن یک Originate به supervisor می‌زند و ChanSpy اجرا می‌شود
3. اضافه کردن کنترل‌های پایه (stop, pause) برای پخش ضبط و وضعیت شنود
4. تعریف مجوزها، لاگ‌ها و مکانیزم consent و audit

---

## وابستگی‌ها و پیش‌نیازها

- ماژول‌های Asterisk: `app_chanspy`, `app_playback`, `app_mixmonitor` (برای ضبطها)
- دسترسی AMI (manager.conf) با یک کاربر محدود (فقط دسترسی‌های مورد نیاز: originate, playback, events خواندن)
- فضای ذخیره‌سازی برای فایل‌های ضبط (مسیرهای عادی Asterisk: `/var/spool/asterisk/monitor/` یا تنظیم دلخواه)
- در صورت نیاز به WebRTC: یک Gateway مثل Janus/RTPEngine و گواهی‌نامه‌ها و TURN

---

## Dialplan — مثال‌ها

1) کانتکست Playback ساده (برای Originate به آن):

```ini
[playback-context]
exten => _X.,1,NoOp(Playback ${ARG1})
 same => n,Playback(${ARG1})
 same => n,Hangup()
```

2) کانتکست ChanSpy با استفاده از Local channel (اختیاری برای routing بهتر):

```ini
[spy-context]
exten => _X.,1,NoOp(Start ChanSpy on ${ARG1})
 same => n,ChanSpy(${ARG1},b)
 same => n,Hangup()
```

نکته: آرگومان‌ها بر حسب نیاز می‌توانند شامل گزینه‌‌های `w`, `B`, `b` و غیره باشند.

---

## مثال‌های AMI

1) Originate برای شنود زنده (می‌سازیم کانال Local که ChanSpy اجرا کند یا Originate مستقیم به SIP supervisor):

```
Action: Originate
Channel: SIP/1000
Context: spy-context
Exten: 200
Priority: 1
Async: true
Timeout: 30000
Variable: SPYTARGET=SIP/101
```

یا به‌صورت مستقیم اجرای اپلیکیشن:

```
Action: Originate
Channel: SIP/1000
Application: ChanSpy
Data: SIP/101,b
Timeout: 30000
Async: true
```

2) Originate برای پخش ضبط (برای فرستادن پخش به supervisor):

```
Action: Originate
Channel: SIP/1000
Application: Playback
Data: monitor/20251220-1234.wav
Async: true
```

3) کنترل پخش (ControlPlayback):

```
Action: ControlPlayback
Channel: <channel-of-playback>
Command: pause
```

توجه: برای شنود زنده، رویدادهای `ChanSpyStart` و `ChanSpyStop` و برای پخش رویدادهای `PlaybackStarted`/`PlaybackFinished` را گوش دهید تا وضعیت را در UI منعکس کنید.

---

## Backend — API & behavior

طراحی پیشنهادی برای backend (مستقل از زبان): یک سرویس ساده HTTP که نقش proxy/manager برای AMI و سرور فایل‌ها را دارد.

End points پیشنهادی:

- `GET /recordings` — لیست فایل‌های ضبط (با متادیتا: id, filename, start_time, duration, cdr_id)
- `GET /recordings/:id/stream` — stream امن فایل ضبط (با احراز هویت و اختیاری signed URL)
- `POST /ami/originate/listen` — درخواست شنود زنده (payload: targetChannel/extension, supervisorEndpoint)
- `POST /ami/originate/playback` — اجرای پخش روی supervisor یا Local channel (payload: recordingId, supervisorEndpoint)
- `POST /ami/control/playback` — کنترل پخش (pause/stop/forward/reverse)
- `GET /ami/events` — websocket / SSE برای forward کردن eventهای AMI به اپ (ChanSpyStart/Stop, PlaybackStarted/Finished)

Auth & Security:

- همهٔ endpointها باید با JWT/session احراز هویت شوند
- قبل از اجازهٔ `listen` یا `playback`, بررسی نقش کاربر (role) و قابلیت `can_listen` انجام شود
- لاگ هر درخواست: user_id, target, timestamp, reason (اگر نیاز باشد)

Implementation detail:

- Backend یک client به AMI باز می‌کند و روی رویدادها گوش می‌دهد
- برای درخواستهای `originate`, backend یک Originate می‌سازد و نتیجه را به کلاینت برمی‌گرداند (async flow). برای بروزرسانی وضعیت، از رویدادهای AMI استفاده کنید
- برای فایل‌های ضبط، مسیر فایل را مستقیم از سیستم فایلی Asterisk بخوانید یا از storage ای که ضبط‌ها را منتقل می‌کنید

---

## Frontend (اپ Flutter) — UI/UX و نقشهٔ تغییرات

هدف: کمترین اصطکاک با UI فعلی، استفاده از اجزای موجود و نگهداری تجربهٔ کاربری یکنواخت.

مکان‌های UI برای اضافه کردن کلیدها:

- `Extensions` (`lib/presentation/pages/extensions_page.dart`):
  - هر کارت داخلی: اضافه کردن آیکن `Listen` (شبیه آیکونی که برای تماس یا actions استفاده می‌کنیم)
  - منوی سه‌نقطه هر داخلی: گزینه `Listen Live` و `View Recordings` (اگر رکوردینگ دارد)

- `Active Calls` (`lib/presentation/pages/active_calls_page.dart`):
  - برای هر تماس فعال: دکمهٔ `Listen Live` در row اکشن‌ها
  - در زمان کلیک: نمایش دیالوگ انتخاب supervisor endpoint یا استفاده از پیش‌فرض از `Settings`

- `Call History` / `CDR` (`lib/presentation/pages/call_history_page.dart` یا صفحه‌ی مربوطه):
  - هر ردیف رکورد: دکمهٔ `Play` (آیکون پخش), `Download` و نشانگر وجود فایل ضبط
  - هنگام زدن `Play`: از `/recordings/:id/stream` فایل را مصرف و در پلیر داخلی پخش کنید

UX flow نمونه — Listen Live (MVP):

1. کاربر روی `Listen Live` کلیک می‌کند.
2. دیالوگ کوچک باز می‌شود: انتخاب supervisor (از settings یا وارد دستی)، دکمهٔ Confirm.
3. اپ یک درخواست به backend `POST /ami/originate/listen` می‌زند.
4. backend یک `Originate` می‌سازد؛ وضعیت async به اپ برگردانده می‌شود.
5. اپ از طریق SSE/WebSocket یا polling وضعیت را دریافت می‌کند و نمایش می‌دهد: Connecting → Listening → Failed/Stopped.
6. وقتی شنود آغاز شد، کاربر در supervisor (یا softphone) صدای طرف‌ها را می‌شنود. در اپ فقط وضعیت نمایش داده می‌شود مگر در فاز WebRTC.

UX flow نمونه — Play Recording:

1. کاربر `Play` را فشار می‌دهد.
2. اپ یک request به `/recordings/:id/stream` می‌زند و پلیر داخلی استریم را باز می‌کند.
3. کاربر کنترل‌های پخش را می‌بیند (pause/seek/stop).
4. اگر backend از `ControlPlayback` استفاده کند (remote playback برای supervisor) دکمه‌های کنترل پیام AMI ارسال می‌کنند.

Design notes (چند نکته برای حفظ همخوانی با UI فعلی):

- از همان کارت‌ها و رنگ‌بندی کنونی برای دکمه‌ها استفاده کنید (آیکون گوش دادن نزدیک آیکون تماس)
- وضعیت‌های اتصال را با همان component وضعیت (`ConnectionStatusWidget`) و Snackbar کوتاه اطلاع‌رسانی کنید
- دیالوگ‌ها و صفحات جدید را سبک ساده نگه دارید — همان `AlertDialog` یا bottom sheetهای موجود

---

## مجوزها، لاگینگ و مسائل قانونی

- AMI user: ایجاد یک کاربر با حداقل مجوزهای لازم و نگهداری `manager.conf` امن
- Backend role check: فقط کاربران دارای نقش مناسب (مثلاً `supervisor`, `qa`) مجاز به شنود باشند
- Consent: اگر مقررات محلی نیازمند اطلاع یا consent است، در UI علامت تائیدیه‌ای دریافت و ذخیره کنید
- لاگ‌های شنود/پخش: جدول audit شامل user, action (listen/play), target, recordingId, timestamp, duration

---

## تست و اعتبارسنجی

- تست واحد برای backend AMI client (Originate + event handling)
- تست دستی با یک softphone supervisor در staging
- تست پخش فایل‌ها در mobile (Android/iOS) روی فایل‌های WAV/GSM با نرخ‌های مختلف
- تست load: همزمانی N شنونده روی یک کانال (در صورت نیاز)

---

## تحویل‌ها و PRها (Deliverables)

1. Dialplan snippets for `extensions.conf` (به عنوان patch یا doc)
2. Backend endpoints implementation + AMI client + event forwarder
3. Frontend: UI changes — `Extensions`, `Active Calls`, `Call History` و یک shared `Listen` component
4. Migrations/Config: manager.conf user example, settings برای supervisor default
5. تست‌ها و مستندات اجرایی

---

## برآورد زمانی (تقریبی)

- طراحی و مستندسازی: 1 روز
- پیاده‌سازی Playback (Backend + Frontend): 2–4 روز
- پیاده‌سازی Live-MVP (Originate→ChanSpy): 2–3 روز
- تست، hardening، logging و مستندسازی: 2 روز

جمع کل تقریبی برای MVP هر دو قابلیت: 1–2 هفته کاری (با فرض یک توسعه‌دهنده و دسترسی به سرور تست Asterisk)

---

## پیشنهاد اجرایی مرحله‌ای (Recommended order)

1. Playback via HTTP stream — سریع‌ترین و کم‌ریسک
2. Live-MVP via Originate→ChanSpy — برای نظارت سریع
3. (آینده) In-app WebRTC gateway — اگر بخواهیم تجربهٔ شنیدن درون‌اپی داشته باشیم

---

## گام بعدی پیشنهادی برای من

اگر شما موافقید، من می‌توانم بلافاصله گام اول را شروع کنم:

- یک branch جدید بسازم و فایل‌های dialplan نمونه + مجموعهٔ endpointهای backend را scaffold کنم.
- یک PR نمونه برای بخش frontend بسازم که در `Call History` دکمهٔ `Play` اضافه شده و از یک route تستی استریم می‌گیرد.

لطفاً بگویید می‌خواهید من ابتدا روی `Playback` کار کنم یا روی `Live-MVP`.

---

## راه‌اندازی سریع mock server برای تست

جهت تست سریعِ پخش ضبط بدون نیاز به Asterisk/AMI، یک mock server ساده در `tools/mock_recording_server.dart` قرار داده شده است.

برای اجرا (نیاز به Dart SDK):

```bash
dart run tools/mock_recording_server.dart
```

نقاط انتهایی:

- `GET http://127.0.0.1:8080/recordings` → لیست نمونه ضبط‌ها
- `GET http://127.0.0.1:8080/recordings/rec1` → متادیتای ضبط
- `GET http://127.0.0.1:8080/recordings/rec1/stream` → redirect به یک فایل mp3 نمونه

نکته برای اجرای روی اندروید امولاتور: از آدرس `http://10.0.2.2:8080` استفاده کنید.

بعد از راه‌اندازی mock server، در فانکشن Play روی `Call History` کلیک کنید — اپ به `http://10.0.2.2:8080` متصل می‌شود و پخش نمونه را باز می‌کند.
