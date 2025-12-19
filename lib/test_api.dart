import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';

void main() async {
  // تنظیمات اتصال (طبق کانفیگی که انجام دادیم)
  const serverIp = '192.168.85.88';
  const serverPort = 5038;
  const amiUser = 'moein_api';     // یوزری که ساختیم
  const amiSecret = '123456';      // پسوردی که ست کردیم

  if (kDebugMode) {
    print('🚀 Connecting to AMI at $serverIp:$serverPort ...');
  }

  try {
    // 1. ایجاد اتصال سوکت
    Socket socket = await Socket.connect(serverIp, serverPort, timeout: Duration(seconds: 5));
    if (kDebugMode) {
      print('✅ Connected!');
    }

    // 2. گوش دادن به پیام‌های سرور (Listening)
    // سرور هر لحظه ممکنه پیامی بفرسته (مثل زنگ خوردن تلفن)
    socket.listen(
      (List<int> data) {
        final message = utf8.decode(data);
        if (kDebugMode) {
          print('\n📩 SERVER SAYS:');
        }
        if (kDebugMode) {
          print(message);
        }
        
        // تشخیص اینکه آیا لاگین موفق بوده یا نه
        if (message.contains('Authentication accepted')) {
            if (kDebugMode) {
              print('🎉 LOGIN SUCCESSFUL! Ready for commands.');
            }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ Socket Error: $error');
        }
        socket.destroy();
      },
      onDone: () {
        if (kDebugMode) {
          print('🔌 Disconnected from server.');
        }
        socket.destroy();
      },
    );

    // 3. ارسال دستور لاگین (طبق پروتکل AMI)
    // نکته: هر خط باید با \r\n تمام شود و پایان دستور باید دو بار \r\n داشته باشد
    final loginAction = 
        'Action: Login\r\n'
        'Username: $amiUser\r\n'
        'Secret: $amiSecret\r\n'
        '\r\n'; // پایان پکت

    if (kDebugMode) {
      print('📤 Sending Login Action...');
    }
    socket.write(loginAction);

    // برنامه را باز نگه می‌داریم تا پاسخ‌ها را ببینیم
    // در برنامه واقعی فلاتر نیازی به این نیست چون UI باز میمونه
    await Future.delayed(Duration(seconds: 10)); 
    
    // خروج تمیز (اختیاری برای تست)
    // socket.write('Action: Logoff\r\n\r\n');
    // await socket.close();

  } catch (e) {
    if (kDebugMode) {
      print('❌ Connection Failed: $e');
    }
  }
}