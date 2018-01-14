using ZOOjl
using PyPlot
include("fx.jl")

problem = setcover()
dim = setcover_dim()
obj = Objective(dim, func=setcover_fx, args=problem)

budget = 100 * dim.size
par = Parameter(budget=budget)

sol = zoo_min(obj, par)
sol_print(sol)

history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.pdf")
