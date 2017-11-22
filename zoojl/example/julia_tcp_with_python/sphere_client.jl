root = "/Users/liu/Desktop/CS/github/"
push!(LOAD_PATH, string(root, "ZOOjl/zoojl"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/algos/racos"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/algos/asynchronousracos"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/utils"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/example/direct_policy_search_for_gym"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/example/simple_functions"))
print("load successfully")

importall fx, dimension, parameter, objective, solution, tool_function,
  zoo_global, optimize

using Base.Dates.now

if true
  time_log1 = now()
  dim_size = 100
  dim_regs = [[-1, 1] for i = 1:dim_size]
  dim_tys = [true for i = 1:dim_size]
  mydim = Dimension(dim_size, dim_regs, dim_tys)

  budget = 10 * dim_size
  rand_probability = 0.99

  # ip_port = ["127.0.0.1:$(i)" for i = 50000:50004]
  # print(ip_port)
  obj = Objective(dim=mydim)
  par = Parameter(budget=budget, probability=rand_probability, replace_strategy="RR", asynchronous=true,
    computer_num=2, tcp=true, control_server_ip="172.28.145.49", control_server_port=[20001, 20002, 20003],
    working_directory="sphere.py", func="sphere")
  result = []
	# println(par.control_server_port)
  sum = 0
  repeat = 1
  zoolog("solved solution is:")
  for i in 1:repeat
    ins = zoo_min(obj, par)
    sum += ins.value
    zoolog(ins.x)
    zoolog(ins.value)
    push!(result, ins.value)
  end
  zoolog(result)
  zoolog(sum / length(result))
  time_log2 = now()
  expect_time = Dates.value(time_log2 - time_log1) / 1000
  println(expect_time)
end
