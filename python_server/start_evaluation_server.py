"""
This file contains example of running evaluation server.

Author:
    Yu-Ren Liu
"""

import os
import sys
sys.path.insert(0, os.path.abspath('./server_api'))

from evaluation_server import start_evaluation_server

if __name__ == "__main__":
    start_evaluation_server("configuration.txt")
