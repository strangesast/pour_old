#! /usr/bin/python
import select
import socket
import serial
import time
import json

with open('settings.json') as f:
    settings = json.loads(f.read())
    for key in settings:
        val = settings[key]
        if val.isdigit():
            settings[key] = int(val)

server_addr = settings['address']
server_port = settings['port']
serial_addr = settings['serial_address']

ser = serial.Serial(port=serial_addr, baudrate=9600)
ser.flush()
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind((server_addr, server_port))
sock.listen(1)
print("waiting for connections at {}:{}".format(server_addr, server_port))

connection = 0

while True:
    socket_list = [ser, sock, connection]
    read_sockets, write_sockets, error_sockets = select.select(socket_list, [], [])
    for s in read_sockets:
        if s == sock:
            print('new connection')
            connection, client_addr = sock.accept()

            # send something to the arduino
            data = connection.recv(1024)
            try:
                string = data.split('\n')[0]
                # writing ticks
                if string.isdigit():
                    ticks = int(data.split('\n')[0])
                    written = ser.write("{}".format(ticks) + '\n')
                elif string == 'stop':
                    written_string = "{}\n".format(string)
                    written = ser.write(written_string)
                else:
                    connection.send("malformed")

            except socket.error:
                print('connection lost')
                ser.write('stop\n') # stop pouring
                connection = 0

            except:
                connection.send("malformed\n")
                continue

        elif s == connection:
            print('existing connection')
            data = connection.recv(1024)
            try:
                string = data.split('\n')[0]
                # writing ticks
                if string.isdigit():
                    ticks = int(data.split('\n')[0])
                    written = ser.write("{}".format(ticks) + '\n')
                elif string == 'stop':
                    written_string = "{}\n".format(string)
                    written = ser.write(written_string)
                else:
                    connection.send("malformed")

            except socket.error:
                print('connection lost')
                ser.write('stop\n') # stop pouring
                connection = 0
            except:
                connection.send("malformed\n")
                continue
        else:
            # receive something (temp data) from arduino
            data = ser.readline()
            if connection != 0:
                try:
                    connection.send(data.split('\n')[0] + '\n')
                except socket.error, e:
                    print('connection lost')
                    connection = 0
            else:
                print(data)
