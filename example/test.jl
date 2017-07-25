push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/example")
print("load successfully")

importall dimension, optimize, fx, solution, objective, parameter

dim_size = 100
dim_regs = [[-1, 1] for i = 1:dim_size]
dim_tys = [true for i = 1:dim_size]
dim = Dimension(dim_size, dim_regs, dim_tys)
obj = Objective(sphere, dim)

budget = 10 * dim_size
par = Parameter(budget=budget)

solution = zoo_min(obj, par)
println("solved solution is:")
print_solution(solution)
