module aracos_optimization

importall asracos, racos, dimension, racos_optimization, tcp_asracos

export asyn_opt!

# General optimization function, it will choose optimization algorithm according to parameter.get_sequential()
# Default replace strategy is 'WR'
# If user hasn't define uncertain_bits in parameter, set_ub() will set uncertain_bits automatically according to dim
# in objective
function asyn_opt!(ro::RacosOptimization, objective, parameter, stra="WR")
  clear!(ro)
  uncertain_bits = set_ub(objective)
  ro.algorithm = ASRacos(parameter.computer_num)
  if parameter.tcp == false
    ro.best_solution = asracos_opt!(ro.algorithm, objective, parameter, strategy
      =stra, ub=uncertain_bits)
  else
    ro.best_solution = tcp_asracos!(ro.algorithm, objective, parameter, strategy
      =stra, ub=uncertain_bits)
  end
  return ro.best_solution
end

end
