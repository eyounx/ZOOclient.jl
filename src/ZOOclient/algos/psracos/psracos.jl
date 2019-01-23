type PSRacos
    rc::RacosCommon
    evaluation_server_num
    sample_set
    result_set
    asyn_result
    history
    is_finish

    function PSRacos(ncomputer)
        new(RacosCommon(), ncomputer, RemoteChannel(()->Channel(ncomputer)),
        RemoteChannel(()->Channel(ncomputer)), RemoteChannel(()->Channel(1)),
        RemoteChannel(()->Channel(1)), false)
    end
end

function psracos_init_sample_set!(psracos::PSRacos, ub)
    rc = psracos.rc
    classifier = RacosClassification(rc.objective.dim, rc.positive_data,
        rc.negative_data, ub=ub)
    mixed_classification(classifier)
    for i = 1:(psracos.evaluation_server_num)
        if rand(rng, Float64) < rc.parameter.probability
            solution, distinct_flag = distinct_sample_classifier(rc, classifier, data_num=rc.parameter.train_size)
        else
            solution, distinct_flag = distinct_sample(rc, rc.objective.dim)
        end
        # sol_print(solution)
        put!(psracos.sample_set, solution)
    end
end
