class ApiConfig {
  // TODO: Update these with your actual server details
  static const String baseUrl = 'https://your-server-ip:3000';
  static const String mqttBroker = 'your-mqtt-broker';
  static const int mqttPort = 8883;
  
  // API Endpoints
  static const String sensorDataEndpoint = '/api/sensors/current';
  static const String actuatorStateEndpoint = '/api/actuators/state';
  static const String controlPumpEndpoint = '/api/actuators/pump';
  static const String controlMistersEndpoint = '/api/actuators/misters';
  static const String historicalDataEndpoint = '/api/sensors/history';
  
  // MQTT Topics
  static const String sensorDataTopic = 'polytunnel/sensors';
  static const String actuatorStateTopic = 'polytunnel/actuators';
  static const String controlTopic = 'polytunnel/control';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration reconnectDelay = Duration(seconds: 5);
}
