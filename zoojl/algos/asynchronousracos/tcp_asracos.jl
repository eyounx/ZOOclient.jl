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
          ip_port = take!(parameter.ip_port)
          # println("after take ip_port$(i): $(ip_port)")
          ip, port = get_ip_port(ip_port)
          client = connect(ip, port)
          # println("connect success")

          # send calculate info
          println(client, "client: calculate#")
          msg = readline(client)
          if check_exception(msg) == true
            br = false
          end
          println(msg)

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
            sol = take!(arc.sample_set)
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
            put!(arc.result_set, sol)
            put!(parameter.ip_port, ip_port)
            println("tcp_asracos: $(i-1), value=$value, ip_port=$(ip_port)")
          end
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
