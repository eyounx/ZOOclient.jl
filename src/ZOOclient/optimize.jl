function zoo_min(obj::Objective, par::Parameter)
    obj_clean_history(obj)
    if isnull(par.constraint)
        if par.algorithm == "pracos"
            algorithm = pracos_opt!
            zoolog("using algorithm: pracos")
        elseif par.algorithm == "psracos"
            algorithm = psracos_opt!
            zoolog("using algorithm: psracos")
        else
            algorithm = asracos_opt!
            zoolog("using algorithm: asracos")
        end
    else
        algorithm = pposs_opt!
        zoolog("using algorith: pposs")
    end
    solution = algorithm(obj, par)
    return solution
end
