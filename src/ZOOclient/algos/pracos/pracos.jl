type PRacos
    rc::RacosCommon
    evaluation_server_num
    sample_set
    result_set
    asyn_result
    history
    is_finish

    function PRacos(ncomputer)
        new(RacosCommon(), ncomputer, RemoteChannel(()->Channel(ncomputer)),
        RemoteChannel(()->Channel(ncomputer)), RemoteChannel(()->Channel(1)),
        RemoteChannel(()->Channel(1)), false)
    end
end
