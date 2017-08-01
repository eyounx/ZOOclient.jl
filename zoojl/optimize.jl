# main function
module optimize

@everywhere importall objective, parameter, racos_optimization, aracos_optimization

export zoo_min

function zoo_min(obj::Objective, par::Parameter)
  if par.asynchronous == true
    algorithm = asyn_opt!
  else
    algorithm = opt!
  end
  optimizer = RacosOptimization()
  result = algorithm(optimizer, obj, par)
  return result
end

end
