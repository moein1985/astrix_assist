enum LogLevel { debug, info, warning, error }

class AppLogger {
  static void log(String message, {LogLevel level = LogLevel.info}) {
    // ignore: avoid_print
  }

  static void d(String message) => log(message, level: LogLevel.debug);
  static void i(String message) => log(message, level: LogLevel.info);
  static void w(String message) => log(message, level: LogLevel.warning);
  static void e(String message) => log(message, level: LogLevel.error);
}