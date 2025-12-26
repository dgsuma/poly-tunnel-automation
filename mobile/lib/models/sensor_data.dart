class SensorData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double phLevel;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.phLevel,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      soilMoisture: (json['soilMoisture'] as num?)?.toDouble() ?? 0.0,
      phLevel: (json['phLevel'] as num?)?.toDouble() ?? 7.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'phLevel': phLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  SensorData copyWith({
    double? temperature,
    double? humidity,
    double? soilMoisture,
    double? phLevel,
    DateTime? timestamp,
  }) {
    return SensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      phLevel: phLevel ?? this.phLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
