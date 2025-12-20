import 'dart:math';
import 'package:astrix_assist/domain/entities/extension.dart';
import 'package:astrix_assist/domain/repositories/iextension_repository.dart';
import 'package:astrix_assist/core/result.dart';
import 'package:astrix_assist/data/models/extension_model.dart';
import 'mock_data.dart';

class ExtensionRepositoryMock implements IExtensionRepository {
  @override
  Future<Result<List<Extension>>> getExtensions() async {
    // شبیه‌سازی تاخیر شبکه
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(200)));

    // شبیه‌سازی تغییرات dynamic: یکی از extensionها رندوم تغییر وضعیت دهد
    final random = Random();
    final modifiedPeers = List<Map<String, String>>.from(MockData.mockSipPeers);

    if (random.nextBool()) {
      final index = random.nextInt(modifiedPeers.length);
      final peer = modifiedPeers[index];
      final currentStatus = peer['Status']!;
      if (currentStatus.contains('OK')) {
        modifiedPeers[index] = {
          ...peer,
          'Status': 'UNREACHABLE',
        };
      } else if (currentStatus == 'UNREACHABLE') {
        modifiedPeers[index] = {
          ...peer,
          'Status': 'OK (${20 + random.nextInt(80)} ms)',
        };
      }
    }

    // تبدیل Map به رشته AMI و سپس به ExtensionModel
    final extensions = <Extension>[];
    for (final peer in modifiedPeers) {
      final amiString = _mapToAmiString(peer);
      try {
        extensions.add(ExtensionModel.fromAmi(amiString));
      } catch (e) {
        // در mock، خطا ندهیم
        continue;
      }
    }

    return Success(extensions);
  }

  String _mapToAmiString(Map<String, String> peer) {
    final lines = peer.entries.map((e) => '${e.key}: ${e.value}').join('\r\n');
    return '$lines\r\n\r\n';
  }
}