import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/polytunnel_provider.dart';
import '../widgets/sensor_card.dart';
import '../widgets/control_button.dart';
import '../widgets/connection_status.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _pumpLoading = false;
  bool _mistersLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polytunnel Monitor'),
        actions: [
          Consumer<PolytunnelProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ConnectionStatus(isConnected: provider.isConnected),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<PolytunnelProvider>().refreshData();
        },
        child: Consumer<PolytunnelProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.state.sensorData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null &&
                provider.state.sensorData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.refreshData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final sensorData = provider.state.sensorData;
            final actuatorState = provider.state.actuatorState;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sensor Data Section
                  Text(
                    'Sensor Readings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      SensorCard(
                        title: 'Temperature',
                        value: sensorData?.temperature.toStringAsFixed(1) ??
                            '--',
                        unit: '°C',
                        icon: Icons.thermostat,
                        color: Colors.orange,
                      ),
                      SensorCard(
                        title: 'Humidity',
                        value: sensorData?.humidity.toStringAsFixed(1) ?? '--',
                        unit: '%',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                      SensorCard(
                        title: 'Soil Moisture',
                        value:
                            sensorData?.soilMoisture.toStringAsFixed(1) ?? '--',
                        unit: '%',
                        icon: Icons.grass,
                        color: Colors.brown,
                      ),
                      SensorCard(
                        title: 'pH Level',
                        value: sensorData?.phLevel.toStringAsFixed(2) ?? '--',
                        unit: '',
                        icon: Icons.science,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Controls Section
                  Text(
                    'Controls',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ControlButton(
                          label: 'Water Pump',
                          icon: Icons.water,
                          isActive: actuatorState?.pumpActive ?? false,
                          isLoading: _pumpLoading,
                          onPressed: () => _togglePump(context, provider),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ControlButton(
                          label: 'Misters',
                          icon: Icons.cloud,
                          isActive: actuatorState?.mistersActive ?? false,
                          isLoading: _mistersLoading,
                          onPressed: () => _toggleMisters(context, provider),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Last Updated
                  if (sensorData?.timestamp != null)
                    Center(
                      child: Text(
                        'Last updated: ${_formatTimestamp(sensorData!.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _togglePump(
    BuildContext context,
    PolytunnelProvider provider,
  ) async {
    setState(() => _pumpLoading = true);
    final currentState = provider.state.actuatorState?.pumpActive ?? false;
    final success = await provider.controlPump(!currentState);
    setState(() => _pumpLoading = false);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to control pump')),
      );
    }
  }

  Future<void> _toggleMisters(
    BuildContext context,
    PolytunnelProvider provider,
  ) async {
    setState(() => _mistersLoading = true);
    final currentState = provider.state.actuatorState?.mistersActive ?? false;
    final success = await provider.controlMisters(!currentState);
    setState(() => _mistersLoading = false);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to control misters')),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
