using ZOOclient
# using PyPlot

function construct_init_sample(init_file)
    f = open(init_file)
    lines = readlines(f)
    count = floor(Int, length(lines)/2)
    result = []
    for i in 1:count
        value_num = 2 * i - 1
        x_num = 2 * i
        value = eval(parse(split(lines[value_num], "=")[2]))
        x = eval(parse(split(lines[x_num], "=Any")[2]))
        sol = Solution(x=x, value=value)
        push!(result, sol)
    end
    return result
end

# define a Dimension object
dim_size = 100
dim_regs = [[-1, 1] for i = 1:dim_size]
dim_tys = [true for i = 1:dim_size]
mydim = Dimension(dim_size, dim_regs, dim_tys)
# define an Objective object
obj = Objective(mydim)

# define a Parameter Object, the five parameters are indispensable.
# budget:  number of calls to the objective function
# evalueation_server_num: number of evaluation cores user requires
# control_server_ip_por4t: the ip:port of the control server
# objective_file: objective funtion is defined in this file
# func: name of the objective function
init_sample = construct_init_sample("/Users/liu/.julia/v0.6/ZOOclient/example/init.txt")
par = Parameter(budget=400, evaluation_server_num=2, control_server_ip_port="192.168.100.108:20000",
    objective_file="fx.py", func="ackley", output_file="log.txt", init_sample=init_sample, uncertain_bits=5)

# perform optimization
sol = zoo_min(obj, par)
# print the Solution object
sol_print(sol)
f = open("result.txt", "w")
positive_data = take!(par.positive_data)
negative_data = take!(par.negative_data)
write(f, "########################################")
write(f, "positive_data: ")
for sol in positive_data
    sol_write(sol, f)
end
write(f, "########################################")
write(f, "negative_data: ")
for sol in negative_data
    sol_write(sol, f)
end
# visualize the optimization progress
# history = get_history_bestsofar(obj)
# plt[:plot](history)
# plt[:savefig]("figure.png")
