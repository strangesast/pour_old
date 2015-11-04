import socket
import serial
import time

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(('localhost', 3001))
client.send("hello {}\n".format(i))
client.send("hello {}\n".format(i))
