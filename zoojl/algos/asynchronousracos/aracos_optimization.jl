module aracos_optimization

importall asracos, racos, dimension, racos_optimization

export asyn_opt!

# General optimization function, it will choose optimization algorithm according to parameter.get_sequential()
# Default replace strategy is 'WR'
# If user hasn't define uncertain_bits in parameter, set_ub() will set uncertain_bits automatically according to dim
# in objective
function asyn_opt!(ro::RacosOptimization, objective, parameter, stra="WR")
  clear!(ro)
  uncertain_bits = set_ub(objective)
  if parameter.sequential == true
    ro.algorithm = ASRacos(parameter.computer_num)
    ro.best_solution = asracos_opt!(ro.algorithm, objective, parameter, strategy
      =stra, ub=uncertain_bits)
  else
    ro.algorithm = Racos()
    ro.best_solution = racos_opt!(ro.algorithm, objective, parameter, ub=uncertain_bits)
  end
  return ro.best_solution
end

end
