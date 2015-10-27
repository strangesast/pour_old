import time
import serial

port = '/dev/ttyACM0'

def serial_read(port, how_much):
    ser = serial.Serial(port)

    string = str(how_much) + '\n'
    ser.write(string.encode('ascii'))

    while True:
        read = ser.readline()
        if read:
            yield read


a = serial_read(port, 1000)

for x in a:
    try:
        b = int(x)
        if b > 1000:
            print(1000 / b)
    except:
        pass

