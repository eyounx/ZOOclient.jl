module asracos

importall aracos_common, racos_common, objective, parameter, zoo_global, solution,
  racos_classification, tool_function

using Base.Dates.now

export ASRacos, asracos_opt!

@everywhere type ASRacos
  arc::ARacosCommon
  function ASRacos(core_num)
    return new(ARacosCommon(core_num))
  end
end

@everywhere function updater(asracos, budget, strategy="WR")
  t = 0
  arc = asracos.arc
  rc = arc.rc
  println("in updater")
  while(t <= budget)
    t += 1
    println("before take solution")
    sol = take!(arc.result_set)
    println("after take solution")
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
    if isnull(solution)
      zoolog("ERROR: solution null")
      break
    end
    println("updater before sample")
    put!(arc.sample_set, solution)
    println("updater after sample")
  end
  arc.if_finish = true
  put!(arc.asyn_result, rc.best_solution)
end

@everywhere function computer(asracos::ASRacos, objective)
  println("in computer")
  arc = asracos.arc
  while arc.is_finish == false
    sol = take!(arc.sample_set)
    obj_eval(objective, sol)
    put!(arc.result_set, sol)
  end
end

@everywhere function asracos_opt!(asracos::ASRacos, objective::Objective, parameter::Parameter;
  strategy="WR", ub=1)
  arc = asracos.arc
  rc = arc.rc
  rc.objective = objective
  rc.parameter = parameter
  init_attribute!(rc)
  init_sample_set!(arc, ub)
  addprocs(parameter.core_num + 1)
  first = true
  is_finish = false
  for p in workers()
    if first
      remote_do(updater, p, asracos, parameter.budget, "WR")
      first = false
      println("updater begin")
    else
      remote_do(computer, p, asracos, objective)
      println("computer begin")
    end
  end
  print("Finish workers")
  result = take!(arc.asyn_result)
  return result
end

end
