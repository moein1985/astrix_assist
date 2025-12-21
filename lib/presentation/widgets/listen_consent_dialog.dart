import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dialog for obtaining user consent before initiating a listen/spy session.
/// Shows a warning message and stores consent preference.
class ListenConsentDialog extends StatefulWidget {
  final String targetExtension;
  final VoidCallback onConsent;

  const ListenConsentDialog({
    super.key,
    required this.targetExtension,
    required this.onConsent,
  });

  @override
  State<ListenConsentDialog> createState() => _ListenConsentDialogState();

  /// Check if user has previously given consent
  static Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('listen_consent_given') ?? false;
  }

  /// Show consent dialog and return true if user consents
  static Future<bool> showConsentDialog(
    BuildContext context,
    String targetExtension,
  ) async {
    final hasGivenConsent = await hasConsent();
    if (hasGivenConsent) return true;

    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ListenConsentDialog(
        targetExtension: targetExtension,
        onConsent: () => Navigator.of(context).pop(true),
      ),
    );

    return result ?? false;
  }
}

class _ListenConsentDialogState extends State<ListenConsentDialog> {
  bool _rememberChoice = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('تأیید شنود'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'شما در حال درخواست شنود داخلی ${widget.targetExtension} هستید.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'این عملیات برای اهداف نظارت کیفیت و آموزشی است. '
            'با ادامه، تأیید می‌کنید که از سیاست‌های حریم خصوصی و قوانین مربوطه آگاه هستید.',
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _rememberChoice,
            onChanged: (value) => setState(() => _rememberChoice = value ?? false),
            title: const Text('دیگر این پیام را نشان نده'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_rememberChoice) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('listen_consent_given', true);
            }
            widget.onConsent();
          },
          child: const Text('تأیید و ادامه'),
        ),
      ],
    );
  }
}
