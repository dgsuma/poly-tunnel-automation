import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logger/logger.dart';
import '../models/sensor_data.dart';
import '../models/actuator_state.dart';
import 'api_config.dart';

class MqttService {
  final Logger _logger = Logger();
  MqttServerClient? _client;
  
  final _sensorDataController = StreamController<SensorData>.broadcast();
  final _actuatorStateController = StreamController<ActuatorState>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;
  Stream<ActuatorState> get actuatorStateStream =>
      _actuatorStateController.stream;
  Stream<bool> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<bool> connect() async {
    try {
      _client = MqttServerClient.withPort(
        ApiConfig.mqttBroker,
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        ApiConfig.mqttPort,
      );

      _client!.logging(on: false);
      _client!.keepAlivePeriod = 60;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.autoReconnect = true;
      _client!.secure = true;
      
      // Set up TLS
      final context = SecurityContext.defaultContext;
      _client!.securityContext = context;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(
            'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
          )
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.connectionMessage = connMessage;

      await _client!.connect();

      if (isConnected) {
        _subscribeToTopics();
        _client!.updates!.listen(_onMessage);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('MQTT connection error: $e');
      return false;
    }
  }

  void _subscribeToTopics() {
    _client!.subscribe(ApiConfig.sensorDataTopic, MqttQos.atLeastOnce);
    _client!.subscribe(ApiConfig.actuatorStateTopic, MqttQos.atLeastOnce);
    _logger.i('Subscribed to MQTT topics');
  }

  void _onConnected() {
    _logger.i('MQTT connected');
    _connectionStatusController.add(true);
  }

  void _onDisconnected() {
    _logger.w('MQTT disconnected');
    _connectionStatusController.add(false);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message,
      );

      try {
        final data = json.decode(payload) as Map<String, dynamic>;

        if (topic == ApiConfig.sensorDataTopic) {
          final sensorData = SensorData.fromJson(data);
          _sensorDataController.add(sensorData);
        } else if (topic == ApiConfig.actuatorStateTopic) {
          final actuatorState = ActuatorState.fromJson(data);
          _actuatorStateController.add(actuatorState);
        }
      } catch (e) {
        _logger.e('Error parsing MQTT message: $e');
      }
    }
  }

  void disconnect() {
    _client?.disconnect();
  }

  void dispose() {
    _sensorDataController.close();
    _actuatorStateController.close();
    _connectionStatusController.close();
    disconnect();
  }
}
