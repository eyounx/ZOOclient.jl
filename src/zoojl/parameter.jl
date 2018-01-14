type Parameter
    algorithm
    budget

    # common parameters that all algorithm should accept
    init_sample
    terminal_value

    # for racos optimization
    sequential
    precision
    uncertain_bits
    train_size
    positive_size
    negative_size
    probability
    replace_strategy

    # for asynchronousracos
    asynchronous
    computer_num

    # for tcp with python
    tcp
    ip_port
    control_server_ip
    control_server_port
    working_directory
    func
    show_x
    output_file
    time_limit

    # for pareto optimization
    isolationfunc

    function Parameter(; algorithm=Nullable{String}(), budget=0, init_sample=Nullable(),
        terminal_value=Nullable(), sequential=true, precision=Nullable(), uncertain_bits=Nullable{Int64}(),
        train_size=0, positive_size=0, negative_size=0, probability=0.99, replace_strategy="WR",
        asynchronous=false, computer_num = 1, tcp=false, control_server_ip=Nullable{String}(),
        control_server_port=Nullable{String}(), working_directory=Nullable{String}(),
        func="target_func", show_x=false, output_file=Nullable{String}(), time_limit=Nullable{Int64}(),
        isolationfunc=x->0, autoset=true)

        parameter = new(algorithm, budget, init_sample, time_budget, terminal_value,
        sequential, precision, uncertain_bits, train_size, positive_size, negative_size,
        probability, replace_strategy, asynchronous, computer_num, tcp, control_server_ip,
        control_server_port, working_directory, func, show_x, output_file,
        time_limit, isolationfunc)
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
