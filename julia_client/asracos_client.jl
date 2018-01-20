using ZOOjl
using PyPlot

# define a Dimension object
dim_size = 100
dim_regs = [[-1, 1] for i = 1:dim_size]
dim_tys = [true for i = 1:dim_size]
mydim = Dimension(dim_size, dim_regs, dim_tys)
# define an Objective object
obj = Objective(mydim)

# define a Parameter Object
# budget:  the number of calls to the objective function
# evalueation_server_num: the number of evaluation servers
# control_server_ip_port: the ip:port of the control server
# objective_file: the objective funtion is defined in this file
# func: the name of the objective function

par = Parameter(budget=10000, evaluation_server_num=2, control_server_ip_port="192.168.1.104:20000",
    objective_file="fx.py", func="ackley")

# perform optimization
sol = zoo_min(obj, par)
# print the Solution object
sol_print(sol)

# visualize the optimization progress
history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.png")
