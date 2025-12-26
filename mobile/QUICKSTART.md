# Quick Start Guide

Get the Polytunnel Monitor app running in minutes!

## Prerequisites Check

Before you begin, make sure you have:

- [ ] Flutter SDK installed (3.0.0+)
- [ ] A code editor (VS Code, Android Studio, or IntelliJ)
- [ ] Android SDK or Xcode installed
- [ ] A device or emulator to run the app

## Installation Steps

### 1. Verify Flutter Installation

```bash
flutter --version
flutter doctor
```

If Flutter is not installed, visit: https://flutter.dev/docs/get-started/install

### 2. Navigate to Mobile Directory

```bash
cd poly-tunnel-automation/mobile
```

### 3. Get Dependencies

```bash
flutter pub get
```

This will download all required packages.

### 4. Configure API Endpoints

Open `lib/services/api_config.dart` and update:

```dart
// Replace with your server's IP address
static const String baseUrl = 'https://192.168.1.100:3000';

// Replace with your MQTT broker address
static const String mqttBroker = '192.168.1.100';
```

**Important**: 
- Use your local network IP (not localhost)
- Ensure your device is on the same network
- For physical devices, use the computer's IP address

### 5. Run the App

```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Or specify a device
flutter run -d <device-id>
```

## Development Tips

### Hot Reload
While the app is running, press:
- `r` for hot reload (preserves state)
- `R` for hot restart (resets state)
- `q` to quit

### Debug Mode
The app runs in debug mode by default. You'll see:
- Debug banner in the corner
- Slower performance (normal for debug)
- Detailed error messages

### Common First-Run Issues

#### 1. Cannot Connect to Server
**Symptom**: "Disconnected" status, no data loading

**Solution**:
- Verify server URL in `api_config.dart`
- Ensure API server is running
- Check firewall settings
- Ping server from your device's network

#### 2. Build Errors
**Symptom**: Compilation fails

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

#### 3. Android License Issues
**Symptom**: Android SDK license errors

**Solution**:
```bash
flutter doctor --android-licenses
```

#### 4. iOS Simulator Not Starting
**Symptom**: Can't find iOS device

**Solution**:
```bash
open -a Simulator
flutter run
```

## Testing Without Backend

If you don't have the backend running yet, you can:

1. **Mock the API**: Modify `api_service.dart` to return dummy data
2. **Use a mock server**: Set up json-server or similar
3. **Development mode**: Comment out MQTT connection in provider

Example mock data in `api_service.dart`:

```dart
Future<SensorData?> getCurrentSensorData() async {
  // Temporary mock data for testing
  return SensorData(
    temperature: 22.5,
    humidity: 65.0,
    soilMoisture: 45.0,
    phLevel: 6.8,
    timestamp: DateTime.now(),
  );
}
```

## Next Steps

Once the app is running:

1. **Dashboard**: View sensor readings and control actuators
2. **History**: Tap the history icon to view charts
3. **Pull to Refresh**: Swipe down on dashboard to refresh data
4. **Controls**: Tap pump or misters buttons to toggle

## Building for Release

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Find the APK at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Then open in Xcode: `open ios/Runner.xcworkspace`

## Useful Commands

```bash
# Check for issues
flutter doctor -v

# Update dependencies
flutter pub upgrade

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build artifacts
flutter clean
```

## Getting Help

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- Project README: `mobile/README.md`
- Architecture: `mobile/ARCHITECTURE.md`

### Debugging
- Use `print()` or `debugPrint()` for console output
- Check logs with: `flutter logs`
- Use Flutter DevTools: `flutter pub global activate devtools && devtools`

### Common Resources
- [Provider Documentation](https://pub.dev/packages/provider)
- [FL Chart Examples](https://github.com/imaNNeo/fl_chart/tree/main/example)
- [MQTT Client Guide](https://pub.dev/packages/mqtt_client)

## Troubleshooting Checklist

If something doesn't work:

- [ ] Run `flutter doctor` and fix any issues
- [ ] Verify API URL in `api_config.dart`
- [ ] Ensure backend server is accessible
- [ ] Check device/emulator network connectivity
- [ ] Try `flutter clean` and rebuild
- [ ] Check console output for errors
- [ ] Verify all dependencies installed: `flutter pub get`

## What's Next?

After you have the app running:

1. Set up the backend API server (see main README)
2. Configure MQTT broker
3. Deploy to cloud infrastructure
4. Set up the Raspberry Pi edge device
5. Integrate all components

Happy coding! 🚀
