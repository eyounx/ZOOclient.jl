function psracos_opt!(objective::Objective, parameter::Parameter)
    psracos = PSRacos(parameter.evaluation_server_num)
    rc = psracos.rc
    rc.objective = objective
    rc.parameter = parameter
    ub = isnull(parameter.uncertain_bits)? 1 : parameter.uncertain_bits

    # require calculator server
    ip = parameter.control_server_ip
    port = parameter.control_server_port
    cs_send = connect(ip, port)
    println(cs_send, "client: require servers#")
    readline(cs_send)
    println(cs_send, string(parameter.evaluation_server_num, "#"))
    msg = readline(cs_send)

    servers_msg = readline(cs_send)
    if servers_msg == "No available evaluation server"
        zoolog("Error: no available evaluation server")
        return Solution()
    end
    servers = split(servers_msg, " ")
    println("get $(length(servers)) servers")
    # close the socket
    close(cs_send)
    parameter.ip_port = RemoteChannel(()->Channel(length(servers)))
    for server in servers
        put!(parameter.ip_port, server)
    end
    psracos_init_attribute!(psracos, parameter)
    psracos_init_sample_set!(psracos, ub)
    println("Initialization succeeds")
    history = []
    # addprocs(1)
    i = parameter.train_size
    output_file = parameter.output_file
    f = Nullable()
    if !isnull(output_file)
        f = open(output_file, "w")
    end
    time_log1 = now()
    while i < parameter.budget
        # parallel estimation
        iteration_num = min(parameter.evaluation_server_num, parameter.budget-i)
        for j = 1:iteration_num
            ip_port = take!(parameter.ip_port)
            sol = take!(psracos.sample_set)
            @spawn begin
                try
                    br = compute_fx(sol, ip_port, parameter)
                    put!(parameter.ip_port, ip_port)
                    put!(psracos.result_set, sol)
                catch e
                    println("Exception")
                    println(e)
                    cs_exception = connect(ip, port)
                    println(cs_exception, "client: restart#")
                    readline(cs_exception)
                    println(cs_exception, string(servers_msg, "#"))
                    close(cs_exception)
                    return Solution()
                end
            end
        end
        # sequential update
        sol = Nullable()
        for j=1:iteration_num
            sol = take!(psracos.result_set)
            push!(history, sol.value)
            bad_ele = sracos_replace!(rc.positive_data, sol, "pos")
            sracos_replace!(rc.negative_data, bad_ele, "neg", strategy=parameter.replace_strategy)
            rc.best_solution = rc.positive_data[1]

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
    		 put!(psracos.sample_set, solution)
    		 i += 1
        end
        time_log2 = now()
        time_pass = Dates.value(time_log2 - time_log1) / 1000
        zoolog("Budget $(i): time=$(floor(time_pass))s, value=$(sol.value), best_solution_value=$(rc.best_solution.value)")
        str = "Budget $(i): time=$(floor(time_pass))s, value=$(sol.value), best_solution_value=$(rc.best_solution.value)\nbest_x=$(rc.best_solution.x)\n"
        if !isnull(f)
            write(f, str)
            flush(f)
        end
        if !isnull(parameter.time_limit) && time_pass > parameter.time_limit
            zoolog("Exceed time limit: $(parameter.time_limit)")
            break
        end
    end
    # finish task
    result = rc.best_solution
    objective.history = history
    parameter.positive_data = rc.positive_data
    parameter.negative_data = rc.negative_data
    cs_receive = connect(ip, port)
    println(cs_receive, "client: return servers#")
    readline(cs_receive)
    println(cs_receive, string(servers_msg, "#"))
    close(cs_receive)
    return result
end

# function psracos_sample(rc, ub)
#     if rand(rng, Float64) < rc.parameter.probability
#         classifier = RacosClassification(rc.objective.dim, rc.positive_data,
#         rc.negative_data, ub=ub)
#         zoolog("before classification")
#         mixed_classification(classifier)
#         zoolog("after classification")
#         solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
#     else
#         solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
#     end
#     #painc stop
#     if distinct_flag == false
#         zoolog("ERROR: dimension limited")
#     end
#     if isnull(solution)
#         zoolog("ERROR: solution null")
#     end
#     return solution
# end

function psracos_init_attribute!(psracos::PSRacos, parameter::Parameter)
    f = open("init.txt", "w")
    rc = psracos.rc
    # otherwise generate random solutions
    iteration_num = rc.parameter.train_size
    data_temp = rc.parameter.init_sample
    init_num = 0
    remote_data = RemoteChannel(()->Channel(iteration_num))
    remote_result = RemoteChannel(()->Channel(iteration_num))
    if !isnull(data_temp)
        init_num = length(data_temp) < iteration_num? length(data_temp):iteration_num
        for i = 1:init_num
            # str = "initial sample: $(i), value=$(data_temp[i].value)\nx=$(sol.x)\n"
            put!(remote_data, data_temp[i])
        end
    end
    i = 1
    while i <= iteration_num - init_num
        # distinct_flag: True means sample is distinct(can be use),
        # False means sample is distinct, you should sample again.
        sol, distinct_flag = distinct_sample_from_set(rc, rc.objective.dim, rc.data,
            data_num=iteration_num)
        # panic stop
        if isnull(sol)
            break
        end
        if distinct_flag
            put!(remote_data, sol)
            i += 1
        end
    end
    fn = RemoteChannel(()->Channel(1))
    for i = 1:iteration_num
        d = take!(remote_data)
        if d.value != 0
            put!(remote_result, d)
            if i == iteration_num
                put!(fn, 1)
            end
            continue
        end
        ip_port = take!(parameter.ip_port)
        @spawn begin
            compute_fx(d, ip_port, parameter)
            put!(parameter.ip_port, ip_port)
            put!(remote_result, d)
            if i == iteration_num
                put!(fn, 1)
            end
        end

    end
    result = take!(fn)
    f = open("init.txt", "w")
    for i = 1:iteration_num
        d = take!(remote_result)
        push!(rc.data, d)
        str_print = "init sample: $(i), value=$(d.value)"
        str = "init sample: $(i), value=$(d.value)\n x=$(d.x)\n"
        zoolog(str_print)
        write(f, str)
        flush(f)
    end
    # zoolog("after taking result")
    close(f)
    selection!(rc)
    return
end
