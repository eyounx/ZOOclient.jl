using ZOOjl
using PyPlot

# define a Dimension object
dim_size = 60
dim_regs = [[0, 1] for i = 1:dim_size]
dim_tys = [false for i = 1:dim_size]
mydim = Dimension(dim_size, dim_regs, dim_tys)
# define an Objective object
obj = Objective(mydim)

# define a Parameter Object
# algorithm: 'pposs' or 'asracos', 'asracos' by default
# budget:  the number of calls to the objective function
# evalueation_server_num: the number of evaluation servers
# control_server_ip: the ip address of the control server
# control_server_port: the last three ports of the four ports occupied by the control server
# objective_file: the objective funtion is defined in this file
# func: the name of the objective function
par = Parameter(algorithm="pposs", budget=1000, evaluation_server_num=2, control_server_ip="192.168.1.105",
    control_server_port=[20001, 20002, 20003], objective_file="sparse_mse.py", func="target_func")

# perform optimization
sol = zoo_min(obj, par)
# print the Solution object
sol_print(sol)

# visualize the optimization progress
history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.pdf")
