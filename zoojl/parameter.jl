module parameter

export Parameter, autoset!

type Parameter
  algorithm
  budget

  # common parameters that all algorithm should accept
  init_sample
  time_budget
  terminal_value

  # for racos optimization
  sequential
  precision
  uncertain_bits
  train_size
  positive_size
  negative_size
  probability

  # for asynchronousracos
  asynchronous
  computer_num

  # for tcp with python
  tcp
  ip_port
  control_server_ip
  control_server_port
  working_directory

  # for pareto optimization
  isolationfunc

  function Parameter(; algorithm=Nullable(), budget=0, init_sample=Nullable(),
    time_budget=Nullable(), terminal_value=Nullable(), sequential=true,
    precision=Nullable(), uncertain_bits=Nullable(), train_size=0, positive_size=0,
    negative_size=0, probability=0.99, asynchronous=false, computer_num = 1, tcp=false,
    ip_port=Nullable(), control_server_ip="", control_server_port=Nullable(),
    working_directory="", isolationfunc=x->0, autoset=true)

    # if !isnull(ip_port)
    #   temp_ip_port = RemoteChannel(()->Channel(length(ip_port)))
    #   for ins in ip_port
    #     put!(temp_ip_port, ins)
    #   end
    #   ip_port = temp_ip_port
    # end
    # ip_port = RemoteChannel(()->Channel(length(ip_port)))

    parameter = new(algorithm, budget, init_sample, time_budget, terminal_value,
    sequential, precision, uncertain_bits, train_size, positive_size, negative_size,
    probability, asynchronous, computer_num, tcp, ip_port, control_server_ip, control_server_port,
    working_directory, isolationfunc)
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


end
