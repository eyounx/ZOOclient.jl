module tcp_asracos!

importall aracos_common, asracos, objective, parameter

function tcp_asracos!(asracos::ASRacos, objective::Objective, parameter::Parameter;
  strategy="WR", ub=1)
  arc = asracos.arc
  rc = arc.rc
  rc.objective = objective
  rc.parameter = parameter
  init_attribute!(rc)
  init_sample_set!(arc, ub)
  ip_port = parameter.ip_port
  addprocs(1)
  remote_do(updater, 2, asracos, parameter.budget, ub, strategy)
  i = 1
  while i <= parameter.budget
    ip_port = take!(parameter.ip_port)
    ip, port = get_ip_port(ip, port)
    i += 1
    @async begin
      client = connect(ip, port)
      sol = take!(arc.sample_set)
      println(client, list2str(sol.x))
      value = parse(Float64, readline(client))
      sol.value = value
      put!(arc.result_set, sol)
      put!(parameter.ip_port, ip_port)
    end
  end
  result = take!(arc.asyn_result)
  return result
end

function get_ip_port(ip_port)
end

function list2str(list)
  result = ""
  for i = 1:length(list)
    result = string(result, " ", string(list[i]))
  end
  result
end

end
