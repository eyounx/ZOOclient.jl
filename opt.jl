# main function
module zoo_min

function zoo_min(objective::Objective, parameter::Parameter)
  optimizer = RacosOptimization()
  result = opt(optimizer, objective, parameter)
  return result
end

end
