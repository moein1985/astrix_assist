import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/adapters/ami_adapter.dart';
import 'package:astrix_assist/core/app_config.dart';
import 'package:astrix_assist/core/generation/generation_1_config.dart';
import 'package:astrix_assist/core/generation/generation_2_config.dart';

void main() {
  group('AMIAdapter', () {
    late AMIAdapter adapter;

    setUp(() {
      adapter = AMIAdapter();
    });

    test('adaptCommand adapts command for current generation', () {
      final command = 'Action: Login';
      final adapted = adapter.adaptCommand(command);

      expect(adapted, isNotNull);
      expect(adapted, contains('Action: Login'));
    });

    test('parseResponse parses response correctly', () {
      const response = 'Response: Success\r\nMessage: Authentication accepted\r\n';
      final parsed = adapter.parseResponse(response);

      expect(parsed, isNotNull);
      expect(parsed['Response'], 'Success');
      expect(parsed['Message'], 'Authentication accepted');
    });

    test('getLoginCommand returns correct login command', () {
      final loginCmd = adapter.getLoginCommand('user', 'pass');

      expect(loginCmd, contains('Action: Login'));
      expect(loginCmd, contains('Username: user'));
      expect(loginCmd, contains('Secret: pass'));
    });

    test('getLogoutCommand returns correct logout command', () {
      final logoutCmd = adapter.getLogoutCommand();

      expect(logoutCmd, contains('Action: Logoff'));
    });

    test('isSuccessResponse detects success responses', () {
      const successResponse = 'Response: Success\r\n';
      const errorResponse = 'Response: Error\r\n';

      expect(adapter.isSuccessResponse(successResponse), true);
      expect(adapter.isSuccessResponse(errorResponse), false);
    });

    test('adaptResponse adapts response based on command', () {
      const command = 'Action: CoreShowChannels';
      const response = 'Response: Success\r\nEvent: CoreShowChannel\r\nChannel: SIP/123\r\n';
      final adapted = adapter.adaptResponse(command, response);

      expect(adapted, isNotNull);
      expect(adapted['Response'], 'Success');
    });
  });
}