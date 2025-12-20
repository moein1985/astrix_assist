import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/injection_container.dart';
import '../../presentation/blocs/parking_bloc.dart';
import '../../presentation/widgets/connection_status_widget.dart';
import '../../presentation/widgets/theme_toggle_button.dart';

class ParkingPage extends StatefulWidget {
  const ParkingPage({super.key});

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  @override
  void initState() {
    super.initState();
    context.read<ParkingBloc>().add(const LoadParkedCalls());
  }

  String _formatParkedTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ParkingBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تماس‌های Parked'),
          actions: [
            const ConnectionStatusWidget(),
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<ParkingBloc>().add(const RefreshParkedCalls()),
            ),
          ],
        ),
        body: BlocBuilder<ParkingBloc, ParkingState>(
          builder: (context, state) {
            if (state is ParkingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParkingLoaded) {
              if (state.parkedCalls.isEmpty) {
                return const Center(child: Text('هیچ تماس Parked نیست'));
              }
              return ListView.builder(
                itemCount: state.parkedCalls.length,
                itemBuilder: (context, index) {
                  final call = state.parkedCalls[index];
                  final timeRemaining = call.secondsRemaining;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade100,
                        ),
                        child: Center(
                          child: Text(
                            call.exten,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      title: Text('${call.callerIdName} (${call.callerIdNum})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Channel: ${call.channel}'),
                          Text(
                            'زمان باقی: ${_formatParkedTime(timeRemaining)}',
                          ),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          context.read<ParkingBloc>().add(
                            PickupCall(
                              exten: call.exten,
                              extension: 'YOUR_EXTENSION',
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('برداشتن'),
                      ),
                    ),
                  );
                },
              );
            } else if (state is ParkingError) {
              return Center(
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
                      onPressed: () => context.read<ParkingBloc>().add(
                        const RefreshParkedCalls(),
                      ),
                      child: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
