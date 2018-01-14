function aposs_mutation(s, n)
    s_temp = copy(s)
    threshold = 1.0 / n
    flipped = false
    for i = 1:n
        if rand(rng, Float64) <= threshold
            s_temp[i] = (s_temp[i] + 1) % 2
            flipped = true
        end
    end
    if !flipped
        mustflip = rand(rng, 1:n)
        s_temp[mustflip] = (s_temp[mustflip] + 1) % 2
    end
    return s_temp
end

function aposs_opt!(objective::Objective, parameter::Parameter)
    sample_set = RemoteChannel(()->Channel(parameter.ncomputer))
    result_set = RemoteChannel(()->Channel(parameter.ncomputer))
    population = []
    # require calculator server
    ip = parameter.control_server_ip
    port = parameter.control_server_port
    cs_send = connect(ip, port[1])
    println(cs_send, string(parameter.computer_num))
    msg = readline(cs_send)

    servers_msg = readline(cs_send)
    servers = split(servers_msg, " ")
    println("get $(length(servers)) servers")
    parameter.ip_port = RemoteChannel(()->Channel(length(servers)))
    for server in servers
      put!(parameter.ip_port, server)
    end
    n = objective.dim.dim_size
    sol = Solution(x=[0 for i = 1:n])
    ip_port = take!(parameter.ip_port)
    br, x = aposs_compute_fx(sol, ip_port, parameter)
    put!(parameter.ip_port, ip_port)

    push!(population, x)

    aposs_init_sample_set!(sample_set, sol, parameter.computer_num)
    println("after init")
    finish = SharedArray{Bool}(1)
    finish[1] = false
  # addprocs(1)
    @spawn tcp_aposs_updater(population, result_set, parameter.budget, finish)

    br = false
    while true
        i += 1
        if finish[1] == true
            break
        end
        ip_port = take!(parameter.ip_port)
        sol = take!(sample_set)
        @spawn begin
            try
                br, x = aposs_compute_fx(sol, ip_port, parameter)
                put!(parameter.ip_port, ip_port)
                put!(result_set, x)
                if i <= parameter.budget
			        #  println("compute fx: $(i), value=$(x.value), ip_port=$(ip_port)")
                end
            catch e
                println("Exception")
                println(e)
            end
        end
    end
end

function aposs_init_sample_set(sample_set, sol, computer_num)
    i = 1
    while i <= computer_num
        new_x = aposs_mutation(sol.x, length(sol.x))
        put!(sample_set, new_x)
    end
end

function tcp_aposs_updater(population, result_set, budget, finish)

end

function aposs_compute_fx(sol::Solution, ip_port::String, parameter::Parameter)
    ip, port = get_ip_port(ip_port)
    client = connect(ip, port)

    # send calculate info
    println(client, "client: calculate#")
    msg = readline(client)
    br = false
    if check_exception(msg) == true
        br = true
    end

    # send working_directory:func
    if br == false
        smsg = string(parameter.working_directory, ":", parameter.func, "#")
        println(client, smsg)
        msg = readline(client)
        if check_exception(msg) == true
            br = true
        end
    end

    # send x
    if br == false
        str = list2str(sol.x)
        println(client, str)
        receive = readline(client)
        if check_exception(receive) == true
            br = true
        end
    end
    if br == false
        value = parse(Float64, receive)
        sol.value = value
    end
    return br, sol
end
