import 'sensor_data.dart';
import 'actuator_state.dart';

class PolytunnelState {
  final SensorData? sensorData;
  final ActuatorState? actuatorState;
  final bool isConnected;
  final String? errorMessage;

  PolytunnelState({
    this.sensorData,
    this.actuatorState,
    this.isConnected = false,
    this.errorMessage,
  });

  factory PolytunnelState.fromJson(Map<String, dynamic> json) {
    return PolytunnelState(
      sensorData: json['sensorData'] != null
          ? SensorData.fromJson(json['sensorData'] as Map<String, dynamic>)
          : null,
      actuatorState: json['actuatorState'] != null
          ? ActuatorState.fromJson(
              json['actuatorState'] as Map<String, dynamic>,
            )
          : null,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorData': sensorData?.toJson(),
      'actuatorState': actuatorState?.toJson(),
      'isConnected': isConnected,
    };
  }

  PolytunnelState copyWith({
    SensorData? sensorData,
    ActuatorState? actuatorState,
    bool? isConnected,
    String? errorMessage,
  }) {
    return PolytunnelState(
      sensorData: sensorData ?? this.sensorData,
      actuatorState: actuatorState ?? this.actuatorState,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
