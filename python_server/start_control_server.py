"""
This file contains example of running control server.

Author:
    Yu-Ren Liu
"""

import os
import sys
sys.path.insert(0, os.path.abspath('./server_api'))

from control_server import start_control_server


if __name__ == "__main__":
    # users should provide four ports occupied by the control server
    start_control_server([20000, 20001, 20002, 20003])
