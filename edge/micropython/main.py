from sensors.dht22 import DHT22Sensor
from display.oled import OLEDDisplay
from actuators.pump import WaterPump

sensor = DHT22Sensor(pin=4)
display = OLEDDisplay()
pump = WaterPump(pin=14)

while True:
    temp, hum = sensor.read()
    display.update(temp, hum)
    
    if hum < 40:
        pump.on()
    else:
        pump.off()
    time.sleep(5)
