function zoo_min(obj::Objective, par::Parameter)
    if par.asynchronous == true
        algorithm = asyn_opt!
    else
        algorithm = opt!
    end
    optimizer = RacosOptimization()
    solution = algorithm(optimizer, obj, par)
    return solution
end

# a function to print optimization results
function result_analysis(result, top)
  sort!(result)
  top = top > length(result)? length(result) : top
  top_k = result[1:top]
  meanr = mean(top_k)
  stdr = (top == 1? 0: std(top_k))
  zoolog("$(meanr) +- $(stdr)")
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
    result_value = Float64[]
    for i = 1:repeat
        obj_clean_history(obj)
        solution = zoo_min(obj, par)
        push!(solutions, solution)
        push!(result_value, solution.value)
        sol_print(solution)
    end
    result_analysis(result_value, best_n)
    time_log2 = now()
    run_time = Dates.value(time_log2 - time_log1) / 1000
    zoolog("runtime: $(run_time)")
    return solutions
end
