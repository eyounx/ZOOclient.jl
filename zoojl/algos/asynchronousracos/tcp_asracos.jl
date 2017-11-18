module tcp_asracos

importall racos_common, aracos_common, asracos, objective, parameter, solution,
zoo_global, tool_function, racos_classification, sracos

export tcp_asracos!

function tcp_asracos!(asracos::ASRacos, objective::Objective, parameter::Parameter;
  strategy="WR", ub=1)
  println(parameter.control_server_port)
  arc = asracos.arc
  rc = arc.rc
  rc.objective = objective
  rc.parameter = parameter

  # require calculator server
  ip = parameter.control_server_ip
  port = parameter.control_server_port
  cs_send = connect(ip, port[1])
  println(cs_send, string(parameter.computer_num))
  msg = readline(cs_send)

  servers_msg = readline(cs_send)
  servers = split(servers_msg, " ")
  println(servers)
  parameter.ip_port = RemoteChannel(()->Channel(length(servers)))
  for server in servers
    put!(parameter.ip_port, server)
  end

  tcp_init_attribute!(asracos, parameter)
  init_sample_set!(arc, ub)
  println("after init")
  finish = SharedArray{Bool}(1)
  finish[1] = false
  # addprocs(1)
  @spawn tcp_updater(asracos, parameter.budget, ub, strategy, finish)
  # remote_do(updater, 2, asracos, parameter.budget, ub, strategy)
  i = parameter.train_size
  br = false
  while true
      i += 1
      if finish[1] == true
        break
      end
      # println("iteration: $(i-1), before take ip_port")
      ip_port = take!(parameter.ip_port)
      sol = take!(arc.sample_set)
      # println("iteration: $(i-1), ip_port: $(ip_port)")
      # if br == true
      #   println("Error: break")
      #   break
      # end
      @spawn begin
        try
          br, x = compute_fx(sol, ip_port, asracos, parameter)
          # println("$(br), $(x.value)")
          # sample_sol = tcp_sample(rc, ub)
          # # print("$(sample_sol.x)")
          # put!(arc.sample_set, sample_sol)
          put!(parameter.ip_port, ip_port)
          put!(arc.result_set, x)
          if i <= parameter.budget
            println("compute fx: $(i), value=$(x.value), ip_port=$(ip_port)")
          end
        catch e
          println("Exception")
          println(e)
          # cs_exception = connect(ip, port[3])
          # servers_msg = string(servers_msg, "#")
          # println(cs_exception, servers_msg)
          # br = true
        end
    end
  end
  # finish task
  result = take!(arc.asyn_result)
  cs_receive = connect(ip, port[2])
  servers_msg = string(servers_msg, "#")
  # println(servers_msg)
  println(cs_receive, servers_msg)
  return result
end

function compute_fx(sol::Solution, ip_port, asracos::ASRacos, parameter::Parameter)
  # ip_port = take!(parameter.ip_port)
  # println("after take ip_port$(i): $(ip_port)")
  # println(ip_port)
  ip, port = get_ip_port(ip_port)
  client = connect(ip, port)
  # println("connect success")

  # send calculate info
  println(client, "client: calculate#")
  msg = readline(client)
  br = false
  if check_exception(msg) == true
    br = true
  end
  # println(msg)

  # send working_directory:func
  if br == false
    smsg = string(parameter.working_directory, ":", parameter.func, "#")
    # println(smsg)
    println(client, smsg)
    msg = readline(client)
    if check_exception(msg) == true
      br = true
    end
  end
  # println(msg)

  # send x
  if br == false

    str = list2str(sol.x)
    println(client, str)
    receive = readline(client)
    if check_exception(receive) == true
      br = true
    end
  end
  # println(receive)

  if br == false
    value = parse(Float64, receive)
    sol.value = value
  end
  return br, sol
end

function tcp_updater(asracos::ASRacos, budget, ub, strategy, finish)
  # println("in updater")
  t = asracos.arc.rc.parameter.train_size + 1
  arc = asracos.arc
  rc = arc.rc
  parameter = rc.parameter
  time_log1 = now()
  # println(budget)
  while(t <= budget)
    t += 1
    if t == arc.computer_num + 1
      time_log1 = now()
    end
    sol = take!(arc.result_set)
    # println("updater after take solution")
    bad_ele = replace(rc.positive_data, sol, "pos")
    replace(rc.negative_data, bad_ele, "neg", strategy=strategy)
    rc.best_solution = rc.positive_data[1]
    if rand(rng, Float64) < rc.parameter.probability
      classifier = RacosClassification(rc.objective.dim, rc.positive_data,
        rc.negative_data, ub=ub)
      # println(classifier)
      # zoolog("before classification")
      mixed_classification(classifier)
      # zoolog("after classification")
      solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
    else
      solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
    end
    #painc stop
    if distinct_flag == false
      zoolog("ERROR: dimension limited")
      break
    end
    if isnull(solution)
      zoolog("ERROR: solution null")
      break
    end
    # println("updater before put sample")
    put!(arc.sample_set, solution)
    # println("$(rc.best_solution.value)")
    if t == arc.computer_num * 2
      time_log2 = now()
      expected_time = (parameter.budget - parameter.train_size) *
        (Dates.value(time_log2 - time_log1) / 1000) / arc.computer_num
      zoolog(string("expected remaining running time: ", convert_time(expected_time)))
    end
    println("update $(t-1)")
  end
  finish[1] = true
  put!(arc.asyn_result, rc.best_solution)
end

function tcp_sample(rc, ub)
  if rand(rng, Float64) < rc.parameter.probability
    classifier = RacosClassification(rc.objective.dim, rc.positive_data,
      rc.negative_data, ub=ub)
    # println(classifier)
    zoolog("before classification")
    mixed_classification(classifier)
    zoolog("after classification")
    solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
  else
    solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
  end
  #painc stop
  if distinct_flag == false
    zoolog("ERROR: dimension limited")
  end
  if isnull(solution)
    zoolog("ERROR: solution null")
  end
  return solution
end

function tcp_init_attribute!(asracos::ASRacos, parameter::Parameter)
  rc = asracos.arc.rc
  # check if the initial solutions have been set
  data_temp = rc.parameter.init_sample
  if !isnull(data_temp) && isnull(rc.best_solution)
    for j in 1:length(date_temp)
      x = obj_construct_solution(rc.objective, data_temp[j])
      ip_port = take!(parameter.ip_port)
      br, x = compute_fx(x, ip_port, asracos, parameter)
      put!(parameter.ip_port, ip_port)
      println("compute fx: $(j), value=$(x.value), ip_port=$(ip_port)")
      push!(rc.data, x)
    end
    selection!(rc)
    return
  end
  # otherwise generate random solutions
  iteration_num = rc.parameter.train_size
  i = 1
  while i <= iteration_num
    # distinct_flag: True means sample is distinct(can be use),
    # False means sample is distinct, you should sample again.
    x, distinct_flag = distinct_sample_from_set(rc, rc.objective.dim, rc.data,
      data_num=iteration_num)
    # panic stop
    if isnull(x)
      break
    end
    if distinct_flag
      ip_port = take!(parameter.ip_port)
      br, x = compute_fx(x, ip_port, asracos, parameter)
      put!(parameter.ip_port, ip_port)
      push!(rc.data, x)
      println("compute fx: $(i), value=$(x.value), ip_port=$(ip_port)")
      i += 1
    end
  end
  selection!(rc)
  return
end

function check_exception(msg)
  if length(msg) < 9
    return false
  end
  res = msg[1:9]
  if res == "Exception"
    println(msg)
    return true
  end
  return false
end
function get_ip_port(ip_port)
  temp = split(ip_port, ":")
  ip = temp[1]
  port = parse(Int64, temp[2])
  return ip, port
end

function list2str(list)
  result = ""
  for i = 1:length(list)
    if i == 1
      result = string(list[i])
    else
      result = string(result, " ", string(list[i]))
    end
  end
  result = string(result, "#")
  result
end

end
