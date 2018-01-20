"""
This file contains example of running evaluation server.

Author:
    Yu-Ren Liu
"""

import os
import sys
sys.path.insert(0, os.path.abspath('./components'))

import socket
from solution import Solution
from loader import Loader
from receive import receive
from tool_function import ToolFunction
from port_conflict import is_open
import multiprocessing


class EvaluationServer:
    """
        Evaluation server ,an important part in asynchronous racos, is responsible for
        evaluating solution sent by client.
    """
    def __init__(self, s_ip, s_port, data_len):
        """
        Initialization.

        :param s_ip: server ip
        :param s_port: server port
        :param data_len: data length in tcp
        """
        self.__server_ip = s_ip
        self.__server_port = s_port
        self.__data_length = data_len

        return

    def start_server(self, control_server, working_dir):
        """
        Start this evaluation server.

        :param control_server: control server address
        :param working_dir: current working directory
        :return: target function name
        """

        # send evaluation server address to control server
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((self.explain_address(control_server)))
        s.sendall("evaluation server#")
        receive(self.__data_length, s)
        s.sendall(self.__server_ip + ':' + str(self.__server_port) + "#")
        s.close()

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((self.__server_ip, self.__server_port))
        s.listen(5)
        all_connect = 0
        restart = False
        print("this is server !")
        print ("waiting for connector...")
        while True:
            # get x from client
            es, address = s.accept()
            # print all_connect + 1, ' get connected...'
            all_connect += 1
            print("connect num:"+str(all_connect)+" address:"+str(address))
            cmd = receive(self.__data_length, es)
            if cmd == "control server: shutdown":
                es.sendall("success#")
                break
            elif cmd == "client: calculate":
                try:
                    es.sendall("calculate\n")
                    msg = receive(self.__data_length, es)
                    addr, func = msg.split(":")
                    es.sendall("receive\n")

                    load = Loader()
                    module = load.load(working_dir + addr)
                    calculate = module[func]
                    print("module load success")
                    data = receive(self.__data_length, es)
                    x = []
                    data_str = data.split(' ')

                    for istr in data_str:
                        x.append(float(istr))
                    fx = calculate(Solution(x=x))
                    fx_x = str(fx) + "\n"
                    es.sendall(fx_x)
                    print("finish calculating")
                except Exception, msg:
                    print("Exception")
                    es.sendall("Exception: " + str(msg))
                    restart = True
                    break
                # print ("send result finished, result: " + str(fx_x))
            elif cmd == "control server: restart":
                restart = True
                break
            else:
                print(cmd)
                print("no such cmd")
            es.close()
        print ("server close!")
        s.close()
        if restart is True:
            print("server restart")
            self.start_server(control_server, working_dir)

    def result_2_string(self, fx=0, x=[0]):
        """
        Transfer result value to string, which has the form "fx: x"
        :param fx:
        :param x:
        :return:
        """
        my_string = str(fx) + ':' + self.list2string(x)
        return my_string

    def list2string(self, list):
        """
        Transfer a list to string, [x1, x2, x3] --> 'x1 x2 x3'.
        :param list: input list
        :return: a string
        """
        my_str = str(list[0])
        i = 1
        while i < len(list):
            my_str = my_str + ' ' + str(list[i])
            i += 1
        return my_str

    def explain_address(self, addr):
        """
        Get ip and port from ad`dress 'ip:port'. Ip is a string and port is a integer.

        :param addr: address
        :return: ip and port
        """
        addr = addr.split(':')
        t_ip = addr[0]
        t_port = int(addr[1])
        return t_ip, t_port


def run(port, work_dir, control_server):
    """
    Api of running evaluation server.

    :param port: port of evaluation server
    :param work_dir: working directory
    :param control_server: ip:port of control server
    :return: no return
    """
    local_ip = socket.gethostbyname(socket.gethostname())
    data_length = 1024
    server_ip = local_ip
    server_port = port

    # set server ip, port and longest data length in initialization
    server = EvaluationServer(server_ip, server_port, data_length)

    server.start_server(control_server=control_server, working_dir=work_dir)


def start_evaluation_server(configuration):
    """
    Api of running evaluation servers from configuration file.

    :param configuration:
        configuration is a file name
        configuration  has three lines
        he first line is the working directory this server works on
        the second line is the address of control server
        the third line has three numbers, for example, 2 50000 50002
        2 means opening 2 server, 50000 50002 means these servers can use port between 50000 and 50002([50000, 50002])
    :return: no return
    """

    file_obj = open(configuration)
    list_of_all_lines = file_obj.readlines()
    working_dir = list_of_all_lines[0][:-1]
    control_server = list_of_all_lines[1][:-1]
    info = list_of_all_lines[2].split()
    sys.path.insert(0, os.path.abspath(working_dir))
    num = int(info[0])
    lowerb = int(info[1])
    upperb = int(info[2])
    local_ip = socket.gethostbyname(socket.gethostname())  # get local ip
    ToolFunction.log("evaluation server ip: " + local_ip)
    count = 0
    workers = []
    for port in range(lowerb, upperb):
        if is_open(local_ip, port) is False:
            count += 1
            workers.append(multiprocessing.Process(target=run, args=(port, working_dir, control_server)))
            if count >= num:
                break
    for w in workers:
        w.start()

if __name__ == "__main__":
    start_evaluation_server("evaluation_server.cfg")
