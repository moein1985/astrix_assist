import 'package:flutter/material.dart';

class TransferDialog extends StatefulWidget {
  final String currentChannel;

  const TransferDialog({
    super.key,
    required this.currentChannel,
  });

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final TextEditingController _extensionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedContext = 'from-internal';

  @override
  void dispose() {
    _extensionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.phone_forwarded, color: Colors.blue),
          SizedBox(width: 12),
          Text('انتقال تماس'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'انتقال تماس از: ${widget.currentChannel}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _extensionController,
                decoration: const InputDecoration(
                  labelText: 'شماره مقصد',
                  hintText: '301',
                  prefixIcon: Icon(Icons.dialpad),
                  border: OutlineInputBorder(),
                  helperText: 'شماره داخلی مقصد را وارد کنید',
                ),
                keyboardType: TextInputType.phone,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'شماره مقصد الزامی است';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'فقط اعداد مجاز است';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedContext,
                decoration: const InputDecoration(
                  labelText: 'Context',
                  prefixIcon: Icon(Icons.settings),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'from-internal',
                    child: Text('from-internal'),
                  ),
                  DropdownMenuItem(
                    value: 'from-pstn',
                    child: Text('from-pstn'),
                  ),
                  DropdownMenuItem(
                    value: 'default',
                    child: Text('default'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedContext = value!);
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'انتقال Blind: تماس بلافاصله منتقل می‌شود',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        FilledButton.icon(
          onPressed: _handleTransfer,
          icon: const Icon(Icons.send),
          label: const Text('انتقال'),
        ),
      ],
    );
  }

  void _handleTransfer() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'destination': _extensionController.text,
        'context': _selectedContext,
      });
    }
  }
}
