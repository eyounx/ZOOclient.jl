module parameter

export Parameter, autoset!

@everywhere type Parameter
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
  core_num

  # for pareto optimization
  isolationfunc

  function Parameter(; algorithm=Nullable(), budget=0, autoset=true, sequential=true,
    precision=Nullable(), uncertain_bits=Nullable(), init_sample=Nullable(),
    time_budget=Nullable(), terminal_value=Nullable(), asynchronous=false, core_num = 1)
    parameter = new(algorithm, budget, init_sample, time_budget, terminal_value,
    sequential, precision, uncertain_bits, 0, 0, 0, 0.99, asynchronous, core_num, x->0)
    if budget != 0 && autoset == true
      autoset!(parameter)
    end
    return parameter
  end
end

@everywhere function autoset!(parameter)
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
