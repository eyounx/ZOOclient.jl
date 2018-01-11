module asracos

include("../racos/sracos.jl")
include("../racos/racos_common.jl")
include("../racos/racos_classification.jl")
include("../../dimension.jl")
include("../../objective.jl")
include("../../parameter.jl")
include("../../solution.jl")
include("../../utils/zoo_global.jl")
include("../../utils/tool_function.jl")

importall aracos_common, racos_common, sracos, racos_classification, objective,
  parameter, zoo_global, solution, tool_function

using Base.Dates.now

export ASRacos, asracos_opt!, updater

type ASRacos
  arc::ASRacosCommon

  function ASRacos(computer_num=1)
    return new(ASRacosCommon(computer_num))
  end
end

# @async remote_do(updater, p, asracos, parameter.budget, ub)
function updater(asracos::ASRacos, budget,  ub)
  # println("in updater")
  t = 1
  arc = asracos.arc
  rc = arc.rc
  parameter = rc.parameter
  strategy = parameter.replace_strategy
  time_log1 = now()
  # println(budget)
  while(t <= budget)
    t += 1
    if t == arc.computer_num + 1
      time_log1 = now()
    end
    # println("updater before take solution")
    sol = take!(arc.result_set)
    # println("updater after take solution")
    bad_ele = replace(rc.positive_data, sol, "pos")
    replace(rc.negative_data, bad_ele, "neg", strategy=strategy)
    rc.best_solution = rc.positive_data[1]
    if rand(rng, Float64) < rc.parameter.probability
      classifier = RacosClassification(rc.objective.dim, rc.positive_data,
        rc.negative_data, ub=ub)
      # println(classifier)
      # zoolog("before classification")
      mixed_classification(classifier)
      # zoolog("after classification")
      solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
    else
      solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
    end
    #painc stop
    if distinct_flag == false
      zoolog("ERROR: dimension limited")
      break
    end
    if isnull(solution)
      zoolog("ERROR: solution null")
      break
    end
    # println("updater before sample")
    put!(arc.sample_set, solution)
    # println("updater after sample: $(solution.x)")
    if t == arc.computer_num * 2
      time_log2 = now()
      expected_time = (parameter.budget - parameter.train_size) *
        (Dates.value(time_log2 - time_log1) / 1000) / arc.computer_num
      zoolog(string("expected remaining running time: ", convert_time(expected_time)))
    end
    # println("update $(t-1)")
  end
  arc.is_finish = true
  put!(arc.asyn_result, rc.best_solution)
end

function computer(asracos::ASRacos, objective::Objective)
  # println("in computer")
  arc = asracos.arc
  while arc.is_finish == false
    # println("computer before take")
    sol = take!(arc.sample_set)
    # println("computer after take")
    obj_eval(objective, sol)
    put!(arc.result_set, sol)
    # println("computer after put")
  end
end

function asracos_opt!(asracos::ASRacos, objective::Objective, parameter::Parameter;
  ub=1)
  arc = asracos.arc
  rc = arc.rc
  rc.objective = objective
  rc.parameter = parameter
  init_attribute!(rc)
  init_sample_set!(arc, ub)
  # addprocs(parameter.computer_num + 1)
  first = true
  is_finish = false
  for p in workers()
    if first
      remote_do(updater, p, asracos, parameter.budget, ub)
      first = false
      # println("updater begin")
    else
      remote_do(computer, p, asracos, objective)
      # computer(asracos, objective)
      # println("computer begin")
    end
  end
  # print("Finish workers")
  result = take!(arc.asyn_result)
  return result
end

end
