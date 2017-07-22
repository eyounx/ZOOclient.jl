module Racos

using RacosCommon

using Objective

using Parameter

using ZooGlobal

using Base.Dates.now

using RacosClassification
type Racos
  rc::RacosCommon
end

function racos_opt(racos::Racos, objective::Objective, parameter::Parameter; ub=1)
  rc = racos.rc
  clear!(rc)
  rc.objective = objective
  rc.parameter = parameter
  init_attribute!(rc)
  t = parameter.budget / parameter.negative_size
  time_log1 =
  for i in 1:t
    j = 0
    iteration_num = length(rc.negative_data)
    while j < iteration_num
      if rand(rng, Float64) < rc.parameter.probability
        classifier = RacosClassification(rc.objective.dim, rc.positive_data,
          rc.negative_data, ub=ub)
          mixed_classification(classifier)
          solution, distinct_flag = distinct_sample_classifier(classifier, data_num=rc.parameter.train_size)
      else
        solution, distinct_flag = distinct_sample(rc.objective.dim)
      end
      #painc stop
      if isnull(solution)
        return rc.best_solution
      end
      if !distinct_flag
        continue
      end
      obj_eval(objective, solution)
      push!(rc.data, solution)
      j += 1
    end
    selection!(rc)
    rc.best_solution = rc.positive_data[0]
    # display expected running time
    if i == 4:
      time_log
    end
  end
end
end
