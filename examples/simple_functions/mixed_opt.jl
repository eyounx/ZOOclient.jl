using ZOOjl
using PyPlot
include("fx.jl")

dim_size = 10
dim_regs = []
dim_tys = []

# In this example, the search space is mixed (continuous and discrete).
# If the dimension index is odd, the search space of this dimension if discrete,
# Otherwise, it's continuous.
for j in 1:dim_size
    if j % 2 == 0
        push!(dim_regs, [0, 1])
        push!(dim_tys, true)
    else
        push!(dim_regs, [0, 100])
        push!(dim_tys, false)
    end
end
dim = Dimension(dim_size, dim_regs, dim_tys)
obj = Objective(dim, func=mixed_function)
budget = 2000
par = Parameter(budget=budget, autoset=true)
sol = zoo_min(obj, par)

history = get_history_bestsofar(obj)
plt[:plot](history)
plt[:savefig]("figure.pdf")
