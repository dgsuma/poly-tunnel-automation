import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/polytunnel_provider.dart';
import '../models/sensor_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = '24h';
  String _selectedMetric = 'temperature';

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    final provider = context.read<PolytunnelProvider>();
    final endTime = DateTime.now();
    final startTime = _getStartTime(endTime);
    await provider.loadHistoricalData(startTime: startTime, endTime: endTime);
  }

  DateTime _getStartTime(DateTime endTime) {
    switch (_selectedPeriod) {
      case '24h':
        return endTime.subtract(const Duration(hours: 24));
      case '7d':
        return endTime.subtract(const Duration(days: 7));
      case '30d':
        return endTime.subtract(const Duration(days: 30));
      default:
        return endTime.subtract(const Duration(hours: 24));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Data'),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '24h', label: Text('24h')),
                      ButtonSegment(value: '7d', label: Text('7d')),
                      ButtonSegment(value: '30d', label: Text('30d')),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedPeriod = newSelection.first;
                      });
                      _loadHistoricalData();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Metric selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'temperature',
                  label: Text('Temp'),
                  icon: Icon(Icons.thermostat),
                ),
                ButtonSegment(
                  value: 'humidity',
                  label: Text('Humidity'),
                  icon: Icon(Icons.water_drop),
                ),
                ButtonSegment(
                  value: 'soilMoisture',
                  label: Text('Soil'),
                  icon: Icon(Icons.grass),
                ),
              ],
              selected: {_selectedMetric},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedMetric = newSelection.first;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: Consumer<PolytunnelProvider>(
              builder: (context, provider, _) {
                if (provider.historicalData.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading historical data...'),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildChart(provider.historicalData),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<SensorData> data) {
    final spots = _getChartSpots(data);

    if (spots.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const Text('');
                final timestamp = data[index].timestamp;
                return Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _getMetricColor(),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _getMetricColor().withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartSpots(List<SensorData> data) {
    final spots = <FlSpot>[];

    for (var i = 0; i < data.length; i++) {
      final sensorData = data[i];
      double value;

      switch (_selectedMetric) {
        case 'temperature':
          value = sensorData.temperature;
          break;
        case 'humidity':
          value = sensorData.humidity;
          break;
        case 'soilMoisture':
          value = sensorData.soilMoisture;
          break;
        default:
          value = 0;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  Color _getMetricColor() {
    switch (_selectedMetric) {
      case 'temperature':
        return Colors.orange;
      case 'humidity':
        return Colors.blue;
      case 'soilMoisture':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
