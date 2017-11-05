module tcp_asracos

importall racos_common, aracos_common, asracos, objective, parameter

export tcp_asracos!

function tcp_asracos!(asracos::ASRacos, objective::Objective, parameter::Parameter;
  strategy="WR", ub=1)
  println(parameter.control_server_port)
  arc = asracos.arc
  rc = arc.rc
  rc.objective = objective
  rc.parameter = parameter
  init_attribute!(rc)
  init_sample_set!(arc, ub)
  # print_positive_data(rc)
  # print_negative_data(rc)

  ip = parameter.control_server_ip
  port = parameter.control_server_port
  println(port)
  cs_send = connect(ip, port[1])
  println(cs_send, string(parameter.computer_num))
  msg = readline(cs_send)
  println(msg)
  servers_msg = readline(cs_send)
  servers = split(servers_msg, " ")
  println(servers)
  parameter.ip_port = RemoteChannel(()->Channel(length(servers)))
  for server in servers
    put!(parameter.ip_port, server)
  end
  # addprocs(1)
  @spawn updater(asracos, parameter.budget, ub, strategy)
  # remote_do(updater, 2, asracos, parameter.budget, ub, strategy)
  i = 1
  while i <= parameter.budget
      i += 1
      @spawn begin
        ip_port = take!(parameter.ip_port)
        # println("after take ip_port$(i): $(ip_port)")
        ip, port = get_ip_port(ip_port)
        client = connect(ip, port)
        # println("connect success")

        # send calculate info
        println(client, "client: calculate#")
        msg = readline(client)
        # println(msg)

        # send working_directory
        # print(parameter.working_directory)
        smsg = string(parameter.working_directory, "#")
        # println(smsg)
        println(client, smsg)
        msg = readline(client)
        # println(msg)

        # send x

        sol = take!(arc.sample_set)
        str = list2str(sol.x)
        println(client, str)
        receive = readline(client)
        # println(receive)
        value = parse(Float64, receive)
        sol.value = value
        put!(arc.result_set, sol)
        put!(parameter.ip_port, ip_port)
        println("tcp_asracos: $(i-1), value=$value, ip_port=$(ip_port)")
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
