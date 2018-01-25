"""
You can run this file to start the evaluation servers.

Author:
    Yu-Ren Liu
"""

import os
import sys
import socket
from components.solution import Solution
from components.loader import Loader
from components.receive import receive
from components.tool_function import ToolFunction
from components.port_conflict import is_open
import multiprocessing
import ConfigParser


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

    def start_server(self, control_server, shared_fold):
        """
        Start this evaluation server.

        :param control_server: control server address
        :param shared_fold: current working directory
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
        ToolFunction.log("evaluation process initializes successfully: ip=%s, port=%s" % (self.__server_ip, self.__server_port))
        while True:
            # get x from client
            es, address = s.accept()
            # print all_connect + 1, ' get connected...'
            all_connect += 1
            ToolFunction.log("connect num:"+str(all_connect)+" address:"+str(address))
            cmd = receive(self.__data_length, es)
            if cmd == "control server: shutdown":
                es.sendall("success#")
                break
            elif cmd == "client: calculate":
                es.sendall("calculate\n")
                try:
                    msg = receive(self.__data_length, es)
                    es.sendall("receive\n")
                    if msg == "pposs":
                        msg = receive(self.__data_length, es)
                        addr, func, constraint = msg.split(":")
                        es.sendall("receive\n")
                        load = Loader()
                        module = load.load(shared_fold + addr)
                        calculate_fx = module[func]
                        calculate_constraint = module[constraint]
                        data = receive(self.__data_length, es)
                        x = []
                        data_str = data.split(' ')
                        for istr in data_str:
                            x.append(float(istr))
                        fx = calculate_fx(Solution(x=x))
                        c = calculate_constraint(Solution(x=x))
                        fx_x = str(fx) + ' ' + str(c) + "\n"
                        es.sendall(fx_x)
                    elif msg == "asracos":
                        msg = receive(self.__data_length, es)
                        addr, func = msg.split(":")
                        es.sendall("receive\n")
                        load = Loader()
                        module = load.load(shared_fold + addr)
                        calculate = module[func]
                        data = receive(self.__data_length, es)
                        x = []
                        data_str = data.split(' ')
                        for istr in data_str:
                            x.append(float(istr))
                        fx = calculate(Solution(x=x))
                        fx_x = str(fx) + "\n"
                        es.sendall(fx_x)
                    else:
                        ToolFunction.log("Exception: %s method is unavailable" % msg)
                except Exception, msg:
                    ToolFunction.log("Exception")
                    es.sendall("Exception: " + str(msg))
                    restart = True
                    break
                # print ("send result finished, result: " + str(fx_x))
            elif cmd == "control server: restart":
                restart = True
                break
            else:
                ToolFunction.log("no such cmd")
            es.close()
        ToolFunction.log("server close!")
        s.close()
        if restart is True:
            ToolFunction.log("server restart")
            self.start_server(control_server, shared_fold)

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


def run(port, shared_fold, control_server):
    """
    Api of running evaluation server.

    :param port: port of evaluation server
    :param shared_fold: the working directory shared by julia client and evaluation servers
    :param control_server: ip:port of the control server
    :return: no return value
    """
    local_ip = socket.gethostbyname(socket.gethostname())
    data_length = 1024
    server_ip = local_ip
    server_port = port

    # set server ip, port and longest data length in initialization
    server = EvaluationServer(server_ip, server_port, data_length)

    server.start_server(control_server=control_server, shared_fold=shared_fold)


def start_evaluation_server(configuration):
    """
    Starting evaluation servers from configuration file.

    :param configuration:
        configuration is a file name
        configuration  has five lines
        he first line is the directory this server works under, objective functions should be defined in this directory
        the second line is the address of control server
        the third line is the number of evaluation servers to be started
        the fourth line is the lower bound of the range that ports are chosen from
        the last line is the upper bound of the range that ports are chosen from
        2 means opening 2 server, 60003 and 60010 mean these servers can use port between 60003 and 60010([60003, 60010])
    :return: no return value
    """
    conf = ConfigParser.ConfigParser()
    conf.read(configuration)
    section = conf.sections()[0]
    options = conf.options(section)
    shared_fold = conf.get(section, "shared fold")
    control_server = conf.get(section, "control server's ip_port")
    num = conf.getint(section, "evaluation processes")
    starting_port = conf.getint(section, "starting port")
    ending_port = conf.getint(section, "ending port")
    local_ip = socket.gethostbyname(socket.gethostname())  # get local ip
    count = 0
    workers = []
    for port in range(starting_port, ending_port):
        if is_open(local_ip, port) is False:
            count += 1
            workers.append(multiprocessing.Process(target=run, args=(port, shared_fold, control_server)))
            if count >= num:
                break
    for w in workers:
        w.start()

if __name__ == "__main__":
    start_evaluation_server("python_server/evaluation_server.cfg")
