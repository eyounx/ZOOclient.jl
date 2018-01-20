type Parameter
    algorithm
    budget

    # common parameters that all algorithm should accept
    init_sample
    time_limit

    # for racos optimization
    precision
    uncertain_bits
    train_size
    positive_size
    negative_size
    probability
    replace_strategy

    # for tcp with python
    evaluation_server_num
    ip_port
    control_server_ip
    control_server_port
    objective_file
    func
    show_x
    output_file


    # for pareto optimization
    isolationfunc

    # init_sample
    # sequential
    # asynchronous
    # tcp
    function Parameter(; algorithm="asracos", budget=0, init_sample=Nullable(),
        time_limit=Nullable{Int64}(), precision=Nullable(),
        uncertain_bits=Nullable{Int64}(), train_size=0, positive_size=0, negative_size=0,
        probability=0.99, replace_strategy="WR", evaluation_server_num = 1,
        control_server_ip_port=Nullable{String}(), objective_file=Nullable{String}(),
        func="target_func", show_x=false, output_file=Nullable{String}(), isolationfunc=x->0,
        autoset=true)

        temp = split(control_server_ip_port, ":")
        control_server_ip = temp[1]
        control_server_port = parse(Int64, temp[2])
        parameter = new(algorithm, budget, init_sample, time_limit,
        precision, uncertain_bits, train_size, positive_size, negative_size,
        probability, replace_strategy, evaluation_server_num, Nullable(), control_server_ip,
        control_server_port, objective_file, func, show_x, output_file,
        isolationfunc)
        if budget != 0 && autoset == true
            autoset!(parameter)
        end
        return parameter
    end
end

function autoset!(parameter)
    if parameter.budget < 3
        zoolog("parameter.jl: budget too small")
    elseif parameter.budget <= 50
        parameter.train_size = 4
        parameter.positive_size = 1
    elseif parameter.budget <= 100
        parameter.train_size = 6
        parameter.positive_size = 1
    elseif parameter.budget <= 1000
        parameter.train_size = 12
        parameter.positive_size = 2
    else
        parameter.train_size = 22
        parameter.positive_size = 2
    end
    parameter.negative_size = parameter.train_size - parameter.positive_size
end
