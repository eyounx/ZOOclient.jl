using ZOOjl
using PyPlot

dim_size = 100
dim_regs = [[-1, 1] for i = 1:dim_size]
dim_tys = [true for i = 1:dim_size]
mydim = Dimension(dim_size, dim_regs, dim_tys)
obj = Objective(mydim)

par = Parameter(budget=10000, asynchronous=true, tcp=true, computer_num=2,
    control_server_ip="172.28.147.174", control_server_port=[20001, 20002, 20003],
    working_directory="fx.py", func="ackley")

ins = zoo_min(obj, par)

history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.pdf")
