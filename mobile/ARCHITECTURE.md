# Mobile App Architecture

## Overview

The Polytunnel Monitor mobile app follows a clean architecture pattern with clear separation of concerns. It uses the Provider pattern for state management and implements both REST API and MQTT for communication.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│            Presentation Layer           │
│  (Screens, Widgets, UI Components)     │
└─────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│      (Providers, State Management)      │
└─────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────┐
│            Data Layer                   │
│    (Services, API, MQTT, Models)        │
└─────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────┐
│          External Services              │
│   (REST API Server, MQTT Broker)        │
└─────────────────────────────────────────┘
```

## Components

### 1. Models (`lib/models/`)

Data classes representing the domain entities:

- **SensorData**: Temperature, humidity, soil moisture, pH readings
- **ActuatorState**: State of pump and misters
- **PolytunnelState**: Combined state of sensors and actuators

All models include:
- JSON serialization/deserialization
- Immutable data structures
- `copyWith` methods for state updates

### 2. Services (`lib/services/`)

Communication layer with external systems:

#### ApiService
- REST API client using `http` package
- Handles all HTTP requests (GET/POST)
- Endpoints:
  - `GET /api/sensors/current`
  - `GET /api/actuators/state`
  - `POST /api/actuators/pump`
  - `POST /api/actuators/misters`
  - `GET /api/sensors/history`

#### MqttService
- Real-time updates using `mqtt_client` package
- TLS/SSL support for secure communication
- Auto-reconnection on disconnect
- Stream-based data delivery
- Topics:
  - `polytunnel/sensors` (subscribe)
  - `polytunnel/actuators` (subscribe)

#### ApiConfig
- Centralized configuration
- Endpoints, URLs, timeouts
- MQTT topics and connection settings

### 3. Providers (`lib/providers/`)

State management using Provider pattern:

#### PolytunnelProvider
- Extends `ChangeNotifier`
- Manages application state
- Coordinates between API and MQTT services
- Features:
  - Periodic data refresh (30s interval)
  - Real-time MQTT updates
  - Actuator control methods
  - Historical data loading
  - Error handling

State flow:
```
MQTT Update → Provider → notifyListeners() → UI Rebuild
API Call → Provider → State Update → notifyListeners() → UI Rebuild
```

### 4. Widgets (`lib/widgets/`)

Reusable UI components:

- **SensorCard**: Displays sensor readings with icon and unit
- **ControlButton**: Toggle button for actuators (pump/misters)
- **ConnectionStatus**: Visual indicator of connectivity

### 5. Screens (`lib/screens/`)

Main UI screens:

#### DashboardScreen
- Main screen showing current state
- 2x2 grid of sensor cards
- Control buttons for actuators
- Pull-to-refresh functionality
- Connection status indicator
- Navigation to history screen

#### HistoryScreen
- Historical data visualization
- Time period selector (24h, 7d, 30d)
- Metric selector (temp, humidity, soil)
- Interactive line charts using `fl_chart`
- Auto-loads data on mount

## Data Flow

### Initial Load
```
App Start
  ↓
Provider.initialize()
  ↓
MQTT.connect() + API.getPolytunnelState()
  ↓
State Update
  ↓
UI Render
```

### Real-time Updates (MQTT)
```
MQTT Message Received
  ↓
MqttService.onMessage()
  ↓
Stream.add(data)
  ↓
Provider listens to stream
  ↓
State Update + notifyListeners()
  ↓
Consumer widgets rebuild
```

### User Actions
```
User taps control button
  ↓
Screen calls Provider.controlPump/Misters()
  ↓
ApiService sends POST request
  ↓
Success: Local state update
  ↓
MQTT confirms change
  ↓
UI reflects new state
```

### Historical Data
```
User navigates to History
  ↓
HistoryScreen.initState()
  ↓
Provider.loadHistoricalData()
  ↓
ApiService.getHistoricalData()
  ↓
Charts render with data
```

## State Management Pattern

Using Provider with Consumer pattern:

```dart
// Provider setup in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => PolytunnelProvider(...)..initialize(),
    ),
  ],
  child: MaterialApp(...)
)

// Consuming in widgets
Consumer<PolytunnelProvider>(
  builder: (context, provider, _) {
    return Text(provider.state.temperature);
  },
)

// Direct access for actions
context.read<PolytunnelProvider>().controlPump(true);
```

## Error Handling

### Network Errors
- Timeout handling (10s default)
- Retry mechanism
- Graceful degradation (MQTT fails → API fallback)
- User-friendly error messages

### State Management
- Null safety for missing data
- Default values for sensors
- Loading states
- Error messages exposed to UI

## Security Considerations

### TLS/SSL
- MQTT over TLS (port 8883)
- HTTPS for REST API
- Certificate validation

### Future Enhancements
- JWT authentication
- Token refresh mechanism
- Secure credential storage
- Biometric authentication

## Performance Optimizations

1. **Stream-based updates**: Efficient real-time data delivery
2. **Periodic refresh**: Reduces server load (30s interval)
3. **Local state caching**: Immediate UI updates on actions
4. **Lazy loading**: Historical data loaded on demand
5. **Debouncing**: Prevents rapid successive API calls

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Provider state transitions
- Service method responses

### Widget Tests
- Individual widget rendering
- User interaction handling
- State-driven UI updates

### Integration Tests
- End-to-end user flows
- API communication
- MQTT connectivity

## Dependencies Rationale

- **provider**: Simple, performant state management
- **http**: Standard HTTP client for Flutter
- **mqtt_client**: Full-featured MQTT implementation
- **fl_chart**: Beautiful, customizable charts
- **intl**: Date/time formatting
- **logger**: Structured logging for debugging

## Future Architecture Improvements

1. **Repository Pattern**: Abstract data sources
2. **Dependency Injection**: Better testability
3. **Bloc Pattern**: Alternative to Provider for complex state
4. **Offline Support**: Local database (sqflite/hive)
5. **GraphQL**: More efficient data fetching
6. **WebSockets**: Alternative to MQTT for web platform
