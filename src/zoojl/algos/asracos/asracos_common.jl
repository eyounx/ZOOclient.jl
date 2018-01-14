type ASRacosCommon
    rc::RacosCommon
    computer_num
    sample_set
    result_set
    asyn_result
    is_finish

    function ASRacosCommon(ncomputer)
        new(RacosCommon(), ncomputer, RemoteChannel(()->Channel(ncomputer)),
        RemoteChannel(()->Channel(ncomputer)), RemoteChannel(()->Channel(1)), false)
    end
end

function init_sample_set!(arc::ASRacosCommon, ub)
    rc = arc.rc
    classifier = RacosClassification(rc.objective.dim, rc.positive_data,
      rc.negative_data, ub=ub)
    mixed_classification(classifier)
    for i = 1:arc.computer_num
        if rand(rng, Float64) < rc.parameter.probability
            solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
        else
            solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
        end
        # sol_print(solution)
        put!(arc.sample_set, solution)
    end
end
