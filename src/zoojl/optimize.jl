function zoo_min(obj::Objective, par::Parameter)
    obj_clean_history(obj)
    if par.algorithm == "asracos"
        algorithm = asracos_opt!
    elseif par.algorithm == "pposs"
        algorithm = pposs_opt!
    else
        zoolog("Error: No such algorithm")
        exit()
    end
    solution = algorithm(obj, par)
    return solution
end


function exp_min(obj::Objective, par::Parameter; repeat=1, best_n=Nullable(),
    seed=Nullable())
    time_log1 = now()
    if isnull(best_n)
        best_n = repeat
    end
    if !isnull(seed)
        set_seed(seed)
    end
    solutions = []
    result_value = []
    for i = 1:repeat
        solution = zoo_min(obj, par)
        push!(solutions, solution)
        push!(result_value, solution.value)
        sol_print(solution)
    end
    zoolog("results: $(result_value)")
    time_log2 = now()
    run_time = Dates.value(time_log2 - time_log1) / 1000
    zoolog("runtime: $(run_time)")
    return solutions
end
