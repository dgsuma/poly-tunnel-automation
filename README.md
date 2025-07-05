# Poly Tunnel Automation System

## Overview

This project implements an edge computing solution for automating a poly tunnel, controlling temperature, humidity, watering, misters, and soil pH using a Raspberry Pi 5 (8GB) running MicroPython. The system features a local touchscreen display, a Flutter-based mobile app for remote control, and integration with a private Kubernetes cluster on Proxmox VE with Synology NAS storage.

## Features

- **Edge Node (Raspberry Pi 5)**:
  - Collects data from DHT22 (temperature/humidity), soil moisture, and pH sensors.
  - Controls water pump and misters via relays.
  - Displays real-time data on a 7" touchscreen using a Flask web server.
  - Communicates with the cloud via MQTT over TLS.
  - Implements local control logic for offline operation.

- **Private Cloud (Proxmox VE, Kubernetes)**:
  - Runs a k3s Kubernetes cluster on a Bosgame Mini PC (24GB RAM, 1TB drive).
  - Hosts Mosquitto MQTT broker, InfluxDB for time-series data, Node.js API server, and Grafana for visualization.
  - Uses Synology NAS for persistent storage via NFS.

- **Mobile App (Flutter)**:
  - Displays real-time sensor data and historical charts.
  - Enables remote control of actuators (pump, misters).
  - Communicates with the cloud via a secure REST API.

## Repository Structure

```
poly-tunnel-automation/
├── edge/                    # MicroPython code for Raspberry Pi
├── cloud/                   # Kubernetes deployments and API server
├── mobile/                  # Flutter app for iOS/Android
├── docs/                    # Architecture and setup documentation
├── .gitignore
└── README.md
```

## Hardware Requirements

- Raspberry Pi 5 (8GB)
- Sensors: DHT22, capacitive soil moisture, pH sensor, MCP3008 ADC
- Actuators: 12V water pump, misters, 4-channel relay
- 7" Raspberry Pi Touchscreen Display
- Bosgame Mini PC (24GB RAM, 1TB drive) with Proxmox VE
- Synology NAS for storage

## Software Requirements

- **Edge**: MicroPython, Flask, `umqtt.simple`, `adafruit-circuitpython-dht`
- **Cloud**: Proxmox VE, k3s, Docker (Mosquitto, InfluxDB, Grafana, Node.js)
- **Mobile**: Flutter SDK, `http` and `mqtt_client` packages

## Setup Instructions

1. **Edge Node**:
   - Install MicroPython on Raspberry Pi 5.
   - Connect sensors/actuators to GPIO pins.
   - Flash MicroPython scripts and run Flask in a CPython environment.
   - Configure MQTT to connect to the cloud broker.

2. **Cloud**:
   - Set up Proxmox VE and k3s on the Bosgame Mini PC.
   - Configure Synology NAS as NFS storage.
   - Deploy Kubernetes services (Mosquitto, InfluxDB, API server, Grafana).

3. **Mobile App**:
   - Build and deploy the Flutter app.
   - Configure API endpoints for cloud communication.

## Security

- MQTT over TLS and HTTPS for API communication.
- JWT authentication for mobile app access.
- Network restrictions for edge and cloud services.

## Getting Started

1. Clone the repository: `git clone https://github.com/your-repo/poly-tunnel-automation.git`
2. Follow the setup guide in `docs/setup-guide.md`.
3. Deploy edge, cloud, and mobile components as per instructions.

## License

MIT License