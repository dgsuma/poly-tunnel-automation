# Polytunnel Monitor Mobile App

A Flutter-based mobile application for monitoring and controlling the polytunnel automation system.

## Features

- **Real-time Monitoring**: View live sensor data (temperature, humidity, soil moisture, pH)
- **Remote Control**: Control water pump and misters from anywhere
- **Historical Data**: View charts showing sensor data over time (24h, 7d, 30d)
- **MQTT Integration**: Real-time updates via MQTT broker
- **REST API**: Fallback communication via HTTP API
- **Connection Status**: Visual indicator of system connectivity
- **Material Design 3**: Modern, responsive UI with light/dark theme support

## Screenshots

### Dashboard
- Real-time sensor readings displayed in cards
- Control buttons for pump and misters
- Connection status indicator

### Historical Data
- Interactive charts for temperature, humidity, and soil moisture
- Selectable time periods (24h, 7d, 30d)
- Color-coded metrics

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android SDK (for Android) or Xcode (for iOS)
- Access to the polytunnel API server and MQTT broker

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/poly-tunnel-automation.git
   cd poly-tunnel-automation/mobile
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**:
   Edit `lib/services/api_config.dart` and update the following:
   - `baseUrl`: Your API server URL (e.g., `https://192.168.1.100:3000`)
   - `mqttBroker`: Your MQTT broker address
   - `mqttPort`: MQTT broker port (default: 8883 for TLS)

   ```dart
   static const String baseUrl = 'https://your-server-ip:3000';
   static const String mqttBroker = 'your-mqtt-broker';
   static const int mqttPort = 8883;
   ```

4. **Run the app**:
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For web (testing only)
   flutter run -d chrome
   ```

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

## Configuration

### API Endpoints
The app expects the following API endpoints:
- `GET /api/sensors/current` - Current sensor readings
- `GET /api/actuators/state` - Current actuator states
- `POST /api/actuators/pump` - Control water pump
- `POST /api/actuators/misters` - Control misters
- `GET /api/sensors/history` - Historical sensor data

### MQTT Topics
The app subscribes to:
- `polytunnel/sensors` - Real-time sensor updates
- `polytunnel/actuators` - Actuator state updates

### TLS/SSL Configuration
For production, ensure your API server has a valid SSL certificate. For development with self-signed certificates, you may need to modify the certificate validation in the API service.

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   │   ├── sensor_data.dart
│   │   ├── actuator_state.dart
│   │   └── polytunnel_state.dart
│   ├── services/                    # API and MQTT services
│   │   ├── api_config.dart
│   │   ├── api_service.dart
│   │   └── mqtt_service.dart
│   ├── providers/                   # State management
│   │   └── polytunnel_provider.dart
│   ├── screens/                     # UI screens
│   │   ├── dashboard_screen.dart
│   │   └── history_screen.dart
│   └── widgets/                     # Reusable widgets
│       ├── sensor_card.dart
│       ├── control_button.dart
│       └── connection_status.dart
├── pubspec.yaml                     # Dependencies
└── README.md
```

## Dependencies

- **provider**: State management
- **http**: REST API communication
- **mqtt_client**: MQTT protocol support
- **fl_chart**: Interactive charts
- **intl**: Internationalization and date formatting
- **shared_preferences**: Local storage
- **logger**: Logging utility

## Troubleshooting

### Connection Issues
- Verify the API server URL in `api_config.dart`
- Ensure your device/emulator can reach the server (same network or port forwarding)
- Check that the MQTT broker is accessible and credentials are correct

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Check minimum SDK versions in `pubspec.yaml`

### MQTT Connection Failures
- Verify MQTT broker is running and accessible
- Check TLS certificate configuration
- Ensure firewall allows MQTT port (8883 for TLS)

## Development

### Running Tests
```bash
flutter test
```

### Code Formatting
```bash
flutter format lib/
```

### Code Analysis
```bash
flutter analyze
```

## Future Enhancements

- [ ] Push notifications for alerts (high temp, low moisture, etc.)
- [ ] User authentication and authorization
- [ ] Multiple polytunnel support
- [ ] Automation rules configuration
- [ ] Export historical data to CSV
- [ ] Offline mode with local caching
- [ ] Widget for iOS/Android home screen

## License

MIT License

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
