module tcp_asracos

importall racos_common, aracos_common, asracos, objective, parameter

export tcp_asracos!

function tcp_asracos!(asracos::ASRacos, objective::Objective, parameter::Parameter;
  strategy="WR", ub=1)
  arc = asracos.arc
  rc = arc.rc
  rc.objective = objective
  rc.parameter = parameter
  init_attribute!(rc)
  init_sample_set!(arc, ub)
  # print_positive_data(rc)
  # print_negative_data(rc)
  ip_port = parameter.ip_port
  addprocs(1)
  remote_do(updater, 2, asracos, parameter.budget, ub, strategy)
  i = 1
  while i <= parameter.budget
    ip_port = take!(parameter.ip_port)
    ip, port = get_ip_port(ip_port)
    i += 1
    @async begin
      client = connect(ip, port)
      sol = take!(arc.sample_set)
      # println(list2str(sol.x))
      println(client, list2str(sol.x))
      receive = readline(client)
      # println(receive)
      value = parse(Float64, receive)
      sol.value = value
      put!(arc.result_set, sol)
      put!(parameter.ip_port, ip_port)
    end
  end
  result = take!(arc.asyn_result)
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
  result
end

end
