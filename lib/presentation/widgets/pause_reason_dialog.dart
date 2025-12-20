import 'package:flutter/material.dart';

class PauseReasonDialog extends StatefulWidget {
  const PauseReasonDialog({super.key});

  @override
  State<PauseReasonDialog> createState() => _PauseReasonDialogState();
}

class _PauseReasonDialogState extends State<PauseReasonDialog> {
  final _controller = TextEditingController();
  String? _selectedReason;

  final List<String> _commonReasons = [
    'استراحت',
    'نماز',
    'ناهار',
    'جلسه',
    'مشکل فنی',
    'آموزش',
    'سایر',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('دلیل توقف اپراتور'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('لطفا دلیل توقف را انتخاب یا وارد کنید:'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonReasons.map((reason) {
              return ChoiceChip(
                label: Text(reason),
                selected: _selectedReason == reason,
                onSelected: (selected) {
                  setState(() {
                    _selectedReason = selected ? reason : null;
                    if (selected && reason != 'سایر') {
                      _controller.text = reason;
                    } else if (reason == 'سایر') {
                      _controller.clear();
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'دلیل دیگر',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && !_commonReasons.contains(value)) {
                setState(() => _selectedReason = 'سایر');
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              Navigator.of(context).pop(_selectedReason ?? 'بدون دلیل');
            } else {
              Navigator.of(context).pop(reason);
            }
          },
          child: const Text('تایید'),
        ),
      ],
    );
  }
}
