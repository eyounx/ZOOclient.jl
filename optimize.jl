# main function
module optimize

importall objective, parameter, racos_optimization

export zoo_min

function zoo_min(obj::Objective, par::Parameter)
  optimizer = RacosOptimization()
  result = opt!(optimizer, obj, par)
  return result
end

end
