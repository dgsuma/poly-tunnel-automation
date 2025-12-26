import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../models/actuator_state.dart';
import '../models/polytunnel_state.dart';
import '../services/api_service.dart';
import '../services/mqtt_service.dart';

class PolytunnelProvider extends ChangeNotifier {
  final ApiService apiService;
  final MqttService _mqttService = MqttService();

  PolytunnelState _state = PolytunnelState();
  bool _isLoading = false;
  String? _errorMessage;
  List<SensorData> _historicalData = [];

  StreamSubscription<SensorData>? _sensorDataSubscription;
  StreamSubscription<ActuatorState>? _actuatorStateSubscription;
  StreamSubscription<bool>? _connectionStatusSubscription;

  Timer? _refreshTimer;

  PolytunnelProvider({required this.apiService});

  // Getters
  PolytunnelState get state => _state;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SensorData> get historicalData => _historicalData;
  bool get isConnected => _state.isConnected;

  // Initialize
  Future<void> initialize() async {
    await _connectMqtt();
    await refreshData();
    _startPeriodicRefresh();
  }

  // Connect to MQTT
  Future<void> _connectMqtt() async {
    try {
      final connected = await _mqttService.connect();
      
      if (connected) {
        // Listen to sensor data stream
        _sensorDataSubscription = _mqttService.sensorDataStream.listen(
          (sensorData) {
            _state = _state.copyWith(sensorData: sensorData);
            notifyListeners();
          },
        );

        // Listen to actuator state stream
        _actuatorStateSubscription = _mqttService.actuatorStateStream.listen(
          (actuatorState) {
            _state = _state.copyWith(actuatorState: actuatorState);
            notifyListeners();
          },
        );

        // Listen to connection status
        _connectionStatusSubscription =
            _mqttService.connectionStatusStream.listen(
          (connected) {
            _state = _state.copyWith(isConnected: connected);
            notifyListeners();
          },
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to connect to MQTT: $e';
      notifyListeners();
    }
  }

  // Refresh data from API
  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newState = await apiService.getPolytunnelState();
      if (newState != null) {
        _state = newState;
      } else {
        _errorMessage = 'Failed to fetch data';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start periodic refresh
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshData();
    });
  }

  // Control pump
  Future<bool> controlPump(bool turnOn) async {
    try {
      final success = await apiService.controlPump(turnOn);
      if (success) {
        // Update local state immediately
        _state = _state.copyWith(
          actuatorState: _state.actuatorState?.copyWith(
            pumpActive: turnOn,
            lastUpdated: DateTime.now(),
          ),
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to control pump: $e';
      notifyListeners();
      return false;
    }
  }

  // Control misters
  Future<bool> controlMisters(bool turnOn) async {
    try {
      final success = await apiService.controlMisters(turnOn);
      if (success) {
        // Update local state immediately
        _state = _state.copyWith(
          actuatorState: _state.actuatorState?.copyWith(
            mistersActive: turnOn,
            lastUpdated: DateTime.now(),
          ),
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to control misters: $e';
      notifyListeners();
      return false;
    }
  }

  // Load historical data
  Future<void> loadHistoricalData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      _historicalData = await apiService.getHistoricalData(
        startTime: startTime,
        endTime: endTime,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load historical data: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sensorDataSubscription?.cancel();
    _actuatorStateSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _refreshTimer?.cancel();
    _mqttService.dispose();
    apiService.dispose();
    super.dispose();
  }
}
