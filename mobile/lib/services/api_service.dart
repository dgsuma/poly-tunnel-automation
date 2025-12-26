import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/sensor_data.dart';
import '../models/actuator_state.dart';
import '../models/polytunnel_state.dart';
import 'api_config.dart';

class ApiService {
  final Logger _logger = Logger();
  final http.Client _client = http.Client();

  // Get current sensor data
  Future<SensorData?> getCurrentSensorData() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sensorDataEndpoint}'),
          )
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return SensorData.fromJson(data);
      } else {
        _logger.e('Failed to fetch sensor data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching sensor data: $e');
      return null;
    }
  }

  // Get current actuator state
  Future<ActuatorState?> getActuatorState() async {
    try {
      final response = await _client
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConfig.actuatorStateEndpoint}',
            ),
          )
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ActuatorState.fromJson(data);
      } else {
        _logger.e('Failed to fetch actuator state: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching actuator state: $e');
      return null;
    }
  }

  // Get complete polytunnel state
  Future<PolytunnelState?> getPolytunnelState() async {
    try {
      final sensorData = await getCurrentSensorData();
      final actuatorState = await getActuatorState();

      return PolytunnelState(
        sensorData: sensorData,
        actuatorState: actuatorState,
        isConnected: sensorData != null || actuatorState != null,
      );
    } catch (e) {
      _logger.e('Error fetching polytunnel state: $e');
      return null;
    }
  }

  // Control water pump
  Future<bool> controlPump(bool turnOn) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.controlPumpEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'state': turnOn}),
          )
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        _logger.i('Pump ${turnOn ? "activated" : "deactivated"}');
        return true;
      } else {
        _logger.e('Failed to control pump: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Error controlling pump: $e');
      return false;
    }
  }

  // Control misters
  Future<bool> controlMisters(bool turnOn) async {
    try {
      final response = await _client
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConfig.controlMistersEndpoint}',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'state': turnOn}),
          )
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        _logger.i('Misters ${turnOn ? "activated" : "deactivated"}');
        return true;
      } else {
        _logger.e('Failed to control misters: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Error controlling misters: $e');
      return false;
    }
  }

  // Get historical sensor data
  Future<List<SensorData>> getHistoricalData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startTime != null) {
        queryParams['start'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        queryParams['end'] = endTime.toIso8601String();
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.historicalDataEndpoint}',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(uri).timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data
            .map((item) => SensorData.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _logger.e('Failed to fetch historical data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching historical data: $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}
