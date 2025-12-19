import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/ami_datasource.dart';
import '../../data/repositories/monitor_repository_impl.dart';
import '../../domain/usecases/originate_call_usecase.dart';
import '../widgets/theme_toggle_button.dart';

class OriginatePage extends StatefulWidget {
  const OriginatePage({super.key});

  @override
  State<OriginatePage> createState() => _OriginatePageState();
}

class _OriginatePageState extends State<OriginatePage> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _contextController = TextEditingController(text: 'from-internal');
  bool _submitting = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final host = prefs.getString('ip') ?? '192.168.85.88';
      final port = int.tryParse(prefs.getString('port') ?? '5038') ?? 5038;
      final user = prefs.getString('username') ?? 'moein_api';
      final secret = prefs.getString('password') ?? '123456';

      final dataSource = AmiDataSource(host: host, port: port, username: user, secret: secret);
      final repo = MonitorRepositoryImpl(dataSource);
      final useCase = OriginateCallUseCase(repo);
      await useCase.call(
        from: 'SIP/${_fromController.text}',
        to: _toController.text,
        context: _contextController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Originate sent')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برقراری تماس'),
        actions: const [ThemeToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fromController,
                decoration: const InputDecoration(labelText: 'From (extension)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter source extension' : null,
              ),
              TextFormField(
                controller: _toController,
                decoration: const InputDecoration(labelText: 'To (destination extension)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter destination' : null,
              ),
              TextFormField(
                controller: _contextController,
                decoration: const InputDecoration(labelText: 'Context'),
                validator: (v) => v == null || v.isEmpty ? 'Enter context' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Start Call'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
