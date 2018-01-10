root = "/Users/liu/Desktop/CS/github/"

push!(LOAD_PATH, string(root, "ZOOjl/zoojl"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/algos/racos"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/algos/asynchronous_racos_client"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/utils"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/example/direct_policy_search_for_gym"))
push!(LOAD_PATH, string(root, "ZOOjl/zoojl/example/simple_functions"))
print("load successfully")

importall fx, dimension, parameter, objective, solution, tool_function,
  zoo_global, optimize

export test

using Base.Dates.now

function test(budget, computer_num; output_file="")
  time_log1 = now()
  dim_size = 100
  dim_regs = [[-1, 1] for i = 1:dim_size]
  dim_tys = [true for i = 1:dim_size]
  mydim = Dimension(dim_size, dim_regs, dim_tys)

  rand_probability = 0.99

  obj = Objective(dim=mydim)
  par = Parameter(budget=budget, probability=rand_probability, replace_strategy="WR", asynchronous=true,
    computer_num=computer_num, tcp=true, control_server_ip="192.168.0.102", control_server_port=[20001, 20002, 20003],
    working_directory="fx.py", func="ackley", output_file=output_file)
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
  # zoolog(result)
  # zoolog(sum / length(result))
  time_log2 = now()
  expect_time = Dates.value(time_log2 - time_log1) / 1000
  println(expect_time)
end

function repeat_test(budget, cal_num, repeat)
  output = ["/Users/liu/Desktop/test_data/evaluation_server_$(cal_num)_$(i).txt" for i = 1:repeat]
  # println(output)
  for i = 1:repeat
    # test(budget, cal_num, output[i])
    test(budget, cal_num)
  end
end

if true
  budget = parse(Int64,ARGS[1])
  cal_num = parse(Int64,ARGS[2])
  repeat = parse(Int64,ARGS[3])
  println(repeat)
  repeat_test(budget, cal_num, repeat)
end
