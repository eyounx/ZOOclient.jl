push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/asynchronousracos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/direct_policy_search_for_gym")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/simple_functions")
print("load successfully")

@everywhere importall fx, dimension, parameter, objective, solution, tool_function,
  zoo_global, optimize

if true
  dim_size = 100
  dim_regs = [[-1, 1] for i = 1:dim_size]
  dim_tys = [true for i = 1:dim_size]
  dim = Dimension(dim_size, dim_regs, dim_tys)

  budget = 1000
  rand_probability = 0.95

  ip_port = ["127.0.0.1:$(i)" for i = 10000:10001]
  print(ip_port)
  obj = Objective(sphere, dim)
  par = Parameter(budget=budget, probability=rand_probability, asynchronous=true,
    computer_num=4, ip_port=ip_port)
  result = []
  sum = 0
  repeat = 5
  zoolog("solved solution is:")
  for i in 1:repeat
    ins = zoo_min(obj, par)
    sum += ins.value
    zoolog(ins.value)
    push!(result, ins.value)
  end
  zoolog(result)
  zoolog(sum / length(result))
end
