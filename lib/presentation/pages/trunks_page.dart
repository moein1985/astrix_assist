import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/injection_container.dart';
import '../../presentation/blocs/trunk_bloc.dart';
import '../../presentation/widgets/connection_status_widget.dart';
import '../../presentation/widgets/theme_toggle_button.dart';

class TrunksPage extends StatefulWidget {
  const TrunksPage({super.key});

  @override
  State<TrunksPage> createState() => _TrunksPageState();
}

class _TrunksPageState extends State<TrunksPage> {
  @override
  void initState() {
    super.initState();
    context.read<TrunkBloc>().add(LoadTrunks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrunkBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مانیتورینگ Trunk ها'),
          actions: [
            const ConnectionStatusWidget(),
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<TrunkBloc>().add(RefreshTrunks()),
            ),
          ],
        ),
        body: BlocBuilder<TrunkBloc, TrunkState>(
          builder: (context, state) => switch (state) {
            TrunkInitial() => const SizedBox.shrink(),
            TrunkLoading() => const Center(child: CircularProgressIndicator()),
            TrunkLoaded() => () {
              if (state.trunks.isEmpty) {
                return const Center(child: Text('هیچ Trunk یافت نشد'));
              }
              return ListView.builder(
                itemCount: state.trunks.length,
                itemBuilder: (context, index) {
                  final trunk = state.trunks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: trunk.isRegistered ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(trunk.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Host: ${trunk.host}'),
                          Text(
                            'وضعیت: ${trunk.isRegistered ? "ثبت شده" : "ثبت نشده"}',
                          ),
                          Text('کانال‌های فعال: ${trunk.activeChannels}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(trunk.status),
                        backgroundColor: trunk.isRegistered
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                      ),
                    ),
                  );
                },
              );
            }(),
            TrunkError() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TrunkBloc>().add(RefreshTrunks()),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}
