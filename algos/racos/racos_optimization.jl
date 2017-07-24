module racos_optimization

importall SRacos, 
type RacosOptimization
  best_solution
  algorithm

  function RacosOptimization()
    best_solution = Nullable()
    algorithm = Nullable()
    return new(best_solution, algorithm)
  end
end

# General optimization function, it will choose optimization algorithm according to parameter.get_sequential()
# Default replace strategy is 'WR'
# If user hasn't define uncertain_bits in parameter, set_ub() will set uncertain_bits automatically according to dim
# in objective
function racos_opt(ro::RacosOptimization, objective, parameter, strategy="WR")
  clear!(ro)
  ub = set_ub(objective)
  if parameter.sequential == true
    ro.algorithm = SRacos()
    ro.best_solution = sracos_opt!(objective, parameter, strategy, ub)
  else
    ro.algorithm = Racos()
    ro.best_solution = racos_opt!(objective, parameter, ub)
  end
  return ro.best_solution
end

function clear!(ro::RacosOptimization)
  ro.best_solution = Nullable()
  ro.algorithm = Nullable()

end

# Set uncertain_bits
function set_ub(objective)
  dim = objective.dim
  dim_size = dim.size
  is_discrete = dim.is_discrete
  if is_discrete==false
    if dim_size <= 100
      ub = 1
    elseif dim_size <= 1000
      ub = 2
    else
      ub = 3
    end
  else
    if dim_size <= 10
      ub = 1
    elseif dim_size <= 50
      ub = 2
    elseif dim_size <= 100
      ub = 3
    elseif dim_size <= 1000
      ub = 4
    else
      ub = 5
  end
  return ub
end
