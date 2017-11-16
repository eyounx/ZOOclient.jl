module tcp_asracos

importall racos_common, aracos_common, asracos, objective, parameter, solution

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
  # addprocs(1)
  @spawn updater(asracos, parameter.budget, ub, strategy)
  # remote_do(updater, 2, asracos, parameter.budget, ub, strategy)
  i = 1
  br = false
  while i <= parameter.budget
      i += 1
      msg = ""
      if br == true
        println("Error: break")
        break
      end
      @spawn begin
        try
          sol = take!(arc.sample_set)
          br, sol = compute_fx(sol, asracos, parameter)
          put!(arc.result_set, sol)
          println("compute fx: $(i-1), value=$sol.value, ip_port=$(ip_port)")
        catch e
          # println("Exception")
          # cs_exception = connect(ip, port[3])
          # servers_msg = string(servers_msg, "#")
          # println(cs_exception, servers_msg)
          br = true
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

function compute_fx(sol::Solution, asracos::ASRacos, parameter::Parameter)
  ip_port = take!(parameter.ip_port)
  # println("after take ip_port$(i): $(ip_port)")
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
  put!(parameter.ip_port, ip_port)
  println("compute fx: value=$(sol.value), ip_port=$(ip_port)")
  return br, sol
end

function tcp_init_attribute!(asracos::ASRacos, parameter::Parameter)
  rc = asracos.arc.rc
  # check if the initial solutions have been set
  data_temp = rc.parameter.init_sample
  if !isnull(data_temp) && isnull(rc.best_solution)
    for j in 1:length(date_temp)
      x = obj_construct_solution(rc.objective, data_temp[j])
      br, x = compute_fx(x, asracos, parameter)
      push!(rc.data, x)
    end
    selection!(rc)
    return
  end
  # otherwise generate random solutions
  iteration_num = rc.parameter.train_size
  i = 0
  while i < iteration_num
    # distinct_flag: True means sample is distinct(can be use),
    # False means sample is distinct, you should sample again.
    x, distinct_flag = distinct_sample_from_set(rc, rc.objective.dim, rc.data,
      data_num=iteration_num)
    # panic stop
    if isnull(x)
      break
    end
    if distinct_flag
      br, x = compute_fx(x, asracos, parameter)
      push!(rc.data, x)
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
