"""
This file contains example of running control server.

Author:
    Yu-Ren Liu
"""

import os
import sys
sys.path.insert(0, os.path.abspath('../asracos_server'))

import socket
from control_server import ControlServer


def run(port):
    """
    Api of running control server.

    :param port:
        port of control server
        port is a list having four elements, for example, [10000, 10001, 10002, 10003]
    :return: no return
    """
    local_ip = socket.gethostbyname(socket.gethostname())
    print("control server ip: " + local_ip)
    cs = ControlServer(local_ip, port)
    cs.start()

if __name__ == "__main__":
    run([20000, 20001, 20002, 20003])
