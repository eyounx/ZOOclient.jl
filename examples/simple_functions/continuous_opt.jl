using ZOOjl
using PyPlot
include("fx.jl")

dim_size = 100
dim_regs = [[-1, 1] for j = 1:dim_size]
dim_tys = [true for j = 1:dim_size]
dim = Dimension(dim_size, dim_regs, dim_tys)
obj = Objective(ackley, dim)

budget = 20 * dim_size

par = Parameter(budget=budget)
# par = Parameter(budget=budget, sequential=true, asynchronous=false)

sol = zoo_min(obj, par)
sol_print(sol)

history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.pdf")
