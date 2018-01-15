function asracos_opt!(objective::Objective, parameter::Parameter)
    asracos = ASRacos(parameter.computer_num)
    rc = asracos.rc
    rc.objective = objective
    rc.parameter = parameter
    ub = isnull(parameter.uncertain_bits)? 1 : parameter.uncertain_bits

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

    asracos_init_attribute!(asracos, parameter)
    asracos_init_sample_set!(asracos, ub)
    println("after init")
    finish = SharedArray{Bool}(1)
    finish[1] = false
    # addprocs(1)
    @spawn asracos_updater!(asracos, parameter.budget, ub, finish)
    i = parameter.train_size
    br = false
    while true
        i += 1
        if finish[1] == true
            break
        end
        ip_port = take!(parameter.ip_port)
        sol = take!(asracos.sample_set)
        @spawn begin
            try
                br = compute_fx(sol, ip_port, parameter)
                put!(parameter.ip_port, ip_port)
                put!(asracos.result_set, sol)
            catch e
                println("Exception")
                println(e)
            end
        end
    end
    # finish task
    result = take!(asracos.asyn_result)
    objective.history = take!(asracos.history)
    cs_receive = connect(ip, port[2])
    servers_msg = string(servers_msg, "#")
    println(cs_receive, servers_msg)
    return result
end

function compute_fx(sol::Solution, ip_port, parameter::Parameter)
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
    return br
end

function asracos_updater!(asracos::ASRacos, budget, ub, finish)
    rc = asracos.rc
    parameter = rc.parameter
    history = []
    t = parameter.train_size + 1
    strategy = parameter.replace_strategy
    time_log1 = now()
    interval = 10
    time_sum = interval
    output_file = parameter.output_file
    f = Nullable()
    if !isnull(output_file)
        f = open(output_file, "w")
    end
    br = false
    while(t <= budget)
        sol = take!(asracos.result_set)
        push!(history, sol.value)
        bad_ele = sracos_replace!(rc.positive_data, sol, "pos")
        sracos_replace!(rc.negative_data, bad_ele, "neg", strategy=strategy)
        rc.best_solution = rc.positive_data[1]
	    time_log2 = now()
        time_pass = Dates.value(time_log2 - time_log1) / 1000
	    if time_pass >= time_sum
	        time_sum = time_sum + interval
	        zoolog("time: $(time_pass) update $(t): best_solution value = $(rc.best_solution.value)")
            if parameter.show_x == true
                zoolog("best_solution x = $(rc.best_solution.x)")
            end
            str = "$(floor(time_pass)) $(rc.best_solution.value)\n"
            if parameter.show_x == true
                str = string(str, " ", rc.best_solution.x)
            end
            if !isnull(f)
                write(f, str)
            end
            if !isnull(parameter.time_limit) && time_pass > parameter.time_limit
                zoolog("Exceed time limit: $(parameter.time_limit)")
                br = true
            end
	     end
         if rand(rng, Float64) < rc.parameter.probability
             classifier = RacosClassification(rc.objective.dim, rc.positive_data,
             rc.negative_data, ub=ub)
             mixed_classification(classifier)
             solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
         else
             solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
         end
         if distinct_flag == false
             zoolog("ERROR: dimension limited")
             break
         end
         if isnull(solution)
             zoolog("ERROR: solution null")
             break
         end
         put!(asracos.sample_set, solution)
         t += 1
         if br == true
             break
         end
     end
     finish[1] = true
     # zoolog("update finish")
     if !isnull(f)
         close(f)
     end
     put!(asracos.asyn_result, rc.best_solution)
     put!(asracos.history, history)
end

function asracos_sample(rc, ub)
    if rand(rng, Float64) < rc.parameter.probability
        classifier = RacosClassification(rc.objective.dim, rc.positive_data,
        rc.negative_data, ub=ub)
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

function asracos_init_attribute!(asracos::ASRacos, parameter::Parameter)
    rc = asracos.rc
    # otherwise generate random solutions
    iteration_num = rc.parameter.train_size
    i = 1
    while i <= iteration_num
        # distinct_flag: True means sample is distinct(can be use),
        # False means sample is distinct, you should sample again.
        sol, distinct_flag = distinct_sample_from_set(rc, rc.objective.dim, rc.data,
        data_num=iteration_num)
        # panic stop
        if isnull(sol)
            break
        end
        if distinct_flag
            ip_port = take!(parameter.ip_port)
            br = compute_fx(sol, ip_port, parameter)
            put!(parameter.ip_port, ip_port)
            push!(rc.data, sol)
            println("compute fx: $(i), value=$(sol.value), ip_port=$(ip_port)")
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
