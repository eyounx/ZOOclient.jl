# ZOOjl

[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/eyounx/ZOOjl/blob/master/LICENSE)

ZOOjl provides distributed Zeroth-Order Optimization with the help of the Julia language for Python described functions.

Zeroth-order optimization (a.k.a. derivative-free optimization/black-box optimization) does not rely on the gradient of the objective function, but instead, learns from samples of the search space. It is suitable for optimizing functions that are nondifferentiable, with many local minima, or even unknown but only testable.

**Documents:** [Wiki of ZOOjl]()

**Single-thread version:** [ZOOpt](https://github.com/eyounx/ZOOpt)

## Installation

If you have not done so already, [download and install Julia](http://julialang.org/downloads/) (Any version starting with 0.6 should be fine)

To install ZOOjl, start Julia and run:

```julia
Pkg.add("ZOOjl")
```

This will download ZOOjl and all of its dependencies.

## A quick example

We will demonstrate ZOOjl by using it to optimize the Ackley function.

Ackley function is a classical function with many local minima. In 2-dimension, it looks like (from wikipedia)

<table border=0><tr><td width="400px"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Ackley%27s_function.pdf/page1-400px-Ackley%27s_function.pdf.jpg"/></td></tr></table>

First, we define the Ackley function implemented by Python for minimization.

```python
import numpy as np
def ackley(solution):
    x = solution.get_x()
    bias = 0.2
    value = -20 * np.exp(-0.2 * np.sqrt(sum([(i - bias) * (i - bias) for i in x]) / len(x))) - \
            np.exp(sum([np.cos(2.0*np.pi*(i-bias)) for i in x]) / len(x)) + 20.0 + np.e
    return value	
```

Then, run the control server example by providing four ports.  (Apis of the python servers are povided in `servers/server_api/`, specific examples can be found in `servers/server_example/`. )

>  servers/server_example/control_server_example.py:

```python
import os
import sys
sys.path.insert(0, os.path.abspath('../server_api'))

from control_server import run_control_server


if __name__ == "__main__":
    # users should provide four ports occupied by the control server
    run_control_server([20000, 20001, 20002, 20003])
```

A configuration text should be provided for running evaluation servers.

> servers/server_example/configuration.txt

```
/path/to/your/directory/ZOOjl/servers/python_server/
192.168.1.105:20000
10 60003 600020
```

The first line indicates the root directory of  your evaluation servers. The objective function should be located in this directory. The second line means control_server_ip:first_port. (first_port is the first port occupied by the control server) The third line states we want to start 2 evaluation servers by choosing 2 available ports from 60003 to 60020.

Then, we can start the evaluation servers easily. 

>  servers/server_example/evaluation_server_example.py

```python
import os
import sys
sys.path.insert(0, os.path.abspath('../server_api'))

from evaluation_server import run_evaluation_server

if __name__ == "__main__":
    run_evaluation_server("configuration.txt")
```

Finally, use ZOOjl to optimize a 100-dimension Ackley function 

> examples/asracos_client.jl

```julia
using ZOOjl
using PyPlot

# define a Dimension object
dim_size = 100
dim_regs = [[-1, 1] for i = 1:dim_size]
dim_tys = [true for i = 1:dim_size]
mydim = Dimension(dim_size, dim_regs, dim_tys)
# define an Objective object
obj = Objective(mydim)

# define a Parameter Object, the six parameters are indispensable.
# budget:  the number of calls to the objective function
# evalueation_server_num: the number of evaluation servers
# control_server_ip: the ip address of the control server
# control_server_port: the last three ports of the four ports occupied by the control server
# objective_file: the objective funtion is defined in this file
# func: the name of the objective function
par = Parameter(budget=10000, evaluation_server_num=2, control_server_ip="192.168.1.105",
    control_server_port=[20001, 20002, 20003], objective_file="fx.py", func="ackley")

# perform optimization
sol = zoo_min(obj, par)
# print the Solution object
sol_print(sol)

# visualize the optimization progress
history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.png")
```

To run this example, type the following command

```
$ ./julia -p 4 /path/to/your/directory/ZOOjl/examples/asracos_client.jl
```

Starting with `julia -p n` provides `n` worker processes on the local machine. Generally it makes sense for `n` to equal the number of CPU cores on the machine.

For a few seconds, the optimization is done and we will get the result.

<table border=0><tr><td width="700px"><img src="https://github.com/eyounx/ZOOjl/blob/dev/img/result.png"/></td></tr></table>

Visualized optimization progress looks like:

<table border=0><tr><td width="400px"><img src="https://github.com/eyounx/ZOOjl/blob/dev/img/figure.png"/></td></tr></table>