import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/injection_container.dart';
import '../../core/ami_listen_client.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/connection_status_widget.dart';

class SpyPhonePage extends StatefulWidget {
  const SpyPhonePage({super.key});

  @override
  State<SpyPhonePage> createState() => _SpyPhonePageState();
}

class _SpyPhonePageState extends State<SpyPhonePage> {
  String _displayNumber = '';
  String _listenerExtension = '9999'; // Default supervisor extension
  bool _isListening = false;

  void _onDigitPressed(String digit) {
    if (_displayNumber.length < 10) {
      setState(() {
        _displayNumber += digit;
      });
    }
  }

  void _onBackspace() {
    if (_displayNumber.isNotEmpty) {
      setState(() {
        _displayNumber = _displayNumber.substring(0, _displayNumber.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _displayNumber = '';
    });
  }

  Future<void> _onListen() async {
    if (_displayNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterExtension),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isListening = true);

    try {
      final amiClient = sl<AmiListenClient>();
      
      // Search for active channel with this extension
      // For now, we'll use a simple format: SIP/{extension}
      final targetChannel = 'SIP/$_displayNumber';
      
      await amiClient.originateListen(
        targetChannel: targetChannel,
        listenerExtension: _listenerExtension,
        whisperMode: false, // ChanSpy mode
        bargeMode: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.listeningStarted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spyPhone),
        actions: const [
          ConnectionStatusWidget(),
          ThemeToggleButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.targetExtension,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _displayNumber.isEmpty ? '—' : _displayNumber,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Listener Extension Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(l10n.listenerExtension),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _listenerExtension),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          _listenerExtension = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Dialpad
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildDialButton('1'),
                  _buildDialButton('2'),
                  _buildDialButton('3'),
                  _buildDialButton('4'),
                  _buildDialButton('5'),
                  _buildDialButton('6'),
                  _buildDialButton('7'),
                  _buildDialButton('8'),
                  _buildDialButton('9'),
                  _buildActionButton(Icons.clear, l10n.clear, _onClear),
                  _buildDialButton('0'),
                  _buildActionButton(Icons.backspace, l10n.backspace, _onBackspace),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Listen Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isListening ? null : _onListen,
                icon: _isListening
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.hearing),
                label: Text(
                  _isListening ? l10n.connecting : l10n.startListening,
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialButton(String digit) {
    return ElevatedButton(
      onPressed: () => _onDigitPressed(digit),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, size: 24),
      ),
    );
  }
}
