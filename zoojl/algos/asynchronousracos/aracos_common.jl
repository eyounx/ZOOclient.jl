module aracos_common

importall objective, dimension, racos_common, racos_classification, zoo_global,
  solution, tool_function

export ARacosCommon, init_sample_set!

type ARacosCommon
  rc::RacosCommon
  core_num
  sample_set
  result_set
  asyn_result
  is_finish
  function ARacosCommon(ncore)
    new(RacosCommon(), ncore, RemoteChannel(()->Channel(ncore)),
    RemoteChannel(()->Channel(ncore)), RemoteChannel(()->Channel(1)), false)
  end
end

function init_sample_set!(arc::ARacosCommon, ub)
  rc = arc.rc
  for i = 1:arc.core_num
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
    sol_print(solution)
    put!(arc.sample_set, solution)
  end
end
end
