import dht
from machine import Pin
import time

class DHT22Sensor:
    def __init__(self, pin):
        self.sensor = dht.DHT22(Pin(pin))
        self.last_reading = None
        self.last_read_time = 0
        
    def read(self):
        """Read temperature and humidity with error handling and caching"""
        current_time = time.time()
        
        # DHT22 can only be read every 2 seconds
        if current_time - self.last_read_time < 2:
            if self.last_reading:
                return self.last_reading
            time.sleep(2)
        
        try:
            self.sensor.measure()
            temperature = self.sensor.temperature()
            humidity = self.sensor.humidity()
            
            self.last_reading = (temperature, humidity)
            self.last_read_time = current_time
            
            return temperature, humidity
            
        except OSError as e:
            print(f"DHT22 read error: {e}")
            # Return last known good reading or defaults
            return self.last_reading or (25.0, 50.0)
    
    def get_temperature(self):
        """Get only temperature"""
        temp, _ = self.read()
        return temp
    
    def get_humidity(self):
        """Get only humidity"""
        _, hum = self.read()
        return hum
