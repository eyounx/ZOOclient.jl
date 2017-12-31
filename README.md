# ZOOjl

[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/eyounx/ZOOjl/blob/master/LICENSE)

ZOOjl provides distributed Zeroth-Order Optimization with the help of the Julia language for Python described functions.

<!--Due to the advance of parallel performance of Julia language, ZOOjl implements the core codes of the cliend in Julia. However, the evaluation servers and the control server are implemented in Python, which means the objective function provided by the user to ZOOjl is still described in Python. Also, the evaluation process, running at the evaluation server end, can utilize the full environments in Python. -->

Zeroth-order optimization (a.k.a. derivative-free optimization/black-box optimization) does not rely on the gradient of the objective function, but instead, learns from samples of the search space. It is suitable for optimizing functions that are nondifferentiable, with many local minima, or even unknown but only testable.

## A quick example

1. Define the Ackley function implemented in Python for minimization.

```python
from random import Random
import numpy as np


def ackley(solution):
    """
        Ackley function for continuous optimization
        In order to simulate CPU-bound tasks, extra 100 thousand for loops are added
        to extend evalution.

        :param solution: a data structure containing x and fx
        :return: value of fx
    """
    a = 0
    rd = Random()
    for i in range(100000):
        a += rd.uniform(0, 1)
    x = solution.get_x()
    bias = 0.2
    ave_seq = sum([(i - bias) * (i - bias) for i in x]) / len(x)
    ave_cos = sum([np.cos(2.0 * np.pi * (i - bias)) for i in x]) / len(x)
    value = -20 * np.exp(-0.2 * np.sqrt(ave_seq)) - np.exp(ave_cos) + 20.0 + np.e
    return value
```

2. Run control server by providing four ports.

   `example/julia_tcp_with_python/python_server/control_server_example.py`

```python
import sys
project_path = "/Users/liu/Desktop/CS/github/"  #project path
sys.path.append(project_path + "ZOOjl/zoojl/algos/asynchronous_racos_server/")

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
```

3. Run evaluation servers by providing a configuration text.

`example/julia_tcp_with_python/python_server/evaluation_server_example.py`

```python
import sys
project_path = "/Users/liu/Desktop/CS/github/"
sys.path.append(project_path + "ZOOjl/zoojl/algos/asynchronous_racos_server/")

import socket
import multiprocessing
from evaluation_server import EvaluationServer
from tool_function import ToolFunction
from port_conflict import is_open


def run_server(port, work_dir, control_server):
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


def run(configuration):
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
            workers.append(multiprocessing.Process(target=run_server, args=(port, working_dir, control_server)))
            if count >= num:
                break
    for w in workers:
        w.start()

if __name__ == "__main__":
    run("configuration.txt")
```

configuration text looks like

```
/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/julia_tcp_with_python/python_server/
192.168.0.102:20000
2 60003 60005
```

4. Provide *dimension*, *objective* and  *parameter* in client.jl.

```julia
root = "/Users/liu/Desktop/CS/github/"

push!(LOAD_PATH, string(root, "ZOOjl/zoojl"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/algos/racos"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/algos/asynchronous_racos_client"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/utils"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/example/direct_policy_search_for_gym"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/example/simple_functions"))
print("load successfully")

importall fx, dimension, parameter, objective, solution, tool_function,
  zoo_global, optimize

export test

using Base.Dates.now

function test(budget, computer_num; output_file="")
  time_log1 = now()
  dim_size = 100
  dim_regs = [[-1, 1] for i = 1:dim_size]
  dim_tys = [true for i = 1:dim_size]
  mydim = Dimension(dim_size, dim_regs, dim_tys)

  rand_probability = 0.99

  obj = Objective(dim=mydim)
  par = Parameter(budget=budget, probability=rand_probability, replace_strategy="WR", asynchronous=true,
    computer_num=computer_num, tcp=true, control_server_ip="192.168.0.102", control_server_port=[20001, 20002, 20003],
    working_directory="fx.py", func="ackley", output_file=output_file)
  result = []
	# println(par.control_server_port)
  sum = 0
  repeat = 1
  zoolog("solved solution is:")
  for i in 1:repeat
    ins = zoo_min(obj, par)
    sum += ins.value
    zoolog(ins.x)
    zoolog(ins.value)
    push!(result, ins.value)
  end
  zoolog(result)
  zoolog(sum / length(result))
  time_log2 = now()
  expect_time = Dates.value(time_log2 - time_log1) / 1000
  println(expect_time)
end

function repeat_test(budget, cal_num, repeat)
  output = ["/Users/liu/Desktop/test_data/evaluation_server_$(cal_num)_$(i).txt" for i = 1:repeat]
  # println(output)
  for i = 1:repeat
    # test(budget, cal_num, output[i])
    test(budget, cal_num)
  end
end

if true
  budget = parse(Int64,ARGS[1])
  cal_num = parse(Int64,ARGS[2])
  repeat = parse(Int64,ARGS[3])
  println(repeat)
  repeat_test(budget, cal_num, repeat)
end

```



5. Run client.jl using command line.

> ./julia -p 4 //Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/julia_tcp_with_python/julia_client/client.jl 3000 2 3

client.jl read three arguments provided by command line, respectively are budget, requested calculator server number, repeat times.

6. For a few seconds, the optimization is done and we will get the result.