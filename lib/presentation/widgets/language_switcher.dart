import 'package:flutter/material.dart';
import '../../core/app_localizations.dart';
import '../../core/locale_manager.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool isIconButton;
  
  const LanguageSwitcher({
    super.key,
    this.isIconButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isIconButton) {
      return IconButton(
        icon: const Icon(Icons.language),
        onPressed: () => _showLanguageDialog(context),
        tooltip: LocaleManager.isFarsi() ? 'تغییر زبان' : 'Change Language',
      );
    }
    
    return TextButton.icon(
      onPressed: () => _showLanguageDialog(context),
      icon: const Icon(Icons.language),
      label: Text(LocaleManager.isFarsi() ? 'تغییر زبان' : 'Change Language'),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRTL = LocaleManager.isFarsi();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.t('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                subtitle: const Text('English'),
                value: 'en',
                groupValue: LocaleManager.locale.value.languageCode,
                onChanged: (value) {
                  LocaleManager.setLocale(const Locale('en', ''));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('فارسی'),
                subtitle: const Text('Persian'),
                value: 'fa',
                groupValue: LocaleManager.locale.value.languageCode,
                onChanged: (value) {
                  LocaleManager.setLocale(const Locale('fa', ''));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.t('cancel')),
            ),
          ],
        ),
      ),
    );
  }
}
