import time
import sys
from sensors.dht22 import DHT22Sensor
from display.oled import OLEDDisplay
from actuators.pump import WaterPump
from utils.logger import Logger

# Initialize components
try:
    sensor = DHT22Sensor(pin=4)
    display = OLEDDisplay()
    pump = WaterPump(pin=14)
    logger = Logger()
    logger.info("System initialized successfully")
except Exception as e:
    print(f"Initialization failed: {e}")
    sys.exit(1)

# Main control loop
while True:
    try:
        temp, hum = sensor.read()
        logger.debug(f"Sensor readings - Temp: {temp}°C, Humidity: {hum}%")
        
        display.update(temp, hum)
        
        # Simple humidity-based control
        if hum < 40:
            pump.on()
            logger.info("Pump activated - humidity below threshold")
        else:
            pump.off()
            
        time.sleep(5)
        
    except Exception as e:
        logger.error(f"Error in main loop: {e}")
        time.sleep(10)  # Wait longer on error
