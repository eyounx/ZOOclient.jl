push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/example")
print("load successfully")

importall dimension, optimize, fx, solution, objective, parameter, tool_function

using Base.Dates.now

function result_analysis(result, top)
  sort!(result)
  top_k = result[1:top]
  meanr = mean(top_k)
  println(meanr)
end

time_log1 = now()
result = []
repeatn = 15
for i in 1:repeatn
  dim_size = 100
  dim_regs = [[-1, 1] for i = 1:dim_size]
  dim_tys = [true for i = 1:dim_size]
  dim = Dimension(dim_size, dim_regs, dim_tys)
  obj = Objective(sphere, dim)

  budget = 10 * dim_size
  par = Parameter(budget=budget)

  sol = zoo_min(obj, par)
  push!(result, sol.value)
  println("solved solution is:")
  sol_print(sol)
end
result_analysis(result, 5)
time_log2 = now()
expect_time = Dates.value(time_log2 - time_log1) / 1000
println(expect_time)
