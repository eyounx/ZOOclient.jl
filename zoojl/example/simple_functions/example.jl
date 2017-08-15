push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/asynchronousracos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/simple_functions")
print("load successfully")

importall optimize, dimension, fx, solution, objective, parameter, tool_function,
  zoo_global

using Base.Dates.now

# a function to print optimization results
function result_analysis(result, top)
  sort!(result)
  top_k = result[1:top]
  meanr = mean(top_k)
  println(meanr)
end

# example for minimizing the sphere function
if false
  time_log1 = now()
  # repeat of optimization experiments
  result = []
  repeatn = 5
  # the random seed for zoojl can be set
  set_seed(12345)
  for i in 1:repeatn
    # setup optimization problem
    dim_size = 100  # dimensions
    dim_regs = [[-1, 1] for j = 1:dim_size] # dimension range
    dim_tys = [true for j = 1:dim_size] # dimension type : real
    dim = Dimension(dim_size, dim_regs, dim_tys) # form up the dimension object
    obj = Objective(sphere, dim)  # form up the objective function

    # setup algorithm parameters
    budget = 10 * dim_size  # number of calls to the objective function
    # by default, the algorithm is sequential RACOS, asynchronous is false
    # if asynchronous is false, computer_num makes no sense and can be omitted
    par = Parameter(budget=budget, sequential=true, asynchronous=false)

    # perform the optimization
    sol = zoo_min(obj, par)

    # store the optimization result
    push!(result, sol.value)
    println("solved solution is:")
    sol_print(sol)
  end
  result_analysis(result, 5)
  time_log2 = now()
  expect_time = Dates.value(time_log2 - time_log1) / 1000
  println(expect_time)
end

# example for minimizing the ackley function
if true
  time_log1 = now()
  result = []
  repeatn = 15
  # set_seed(12345)
  for i in 1:repeatn
    dim_size = 100
    dim_regs = [[-1, 1] for j = 1:dim_size]
    dim_tys = [true for j = 1:dim_size]
    dim = Dimension(dim_size, dim_regs, dim_tys)
    obj = Objective(ackley, dim)

    budget = 20 * dim_size

    par = Parameter(budget=budget, sequential=true, asynchronous=true, computer_num = 3)
    # par = Parameter(budget=budget, sequential=true, asynchronous=false)

    sol = zoo_min(obj, par)
    push!(result, sol.value)
    println("solved solution is:")
    sol_print(sol)
  end
  result_analysis(result, 5)
  time_log2 = now()
  expect_time = Dates.value(time_log2 - time_log1) / 1000
  println(expect_time)
end

# discrete optimization example using minimum set cover instance
if false
  time_log1 = now()
  result = []
  repeatn = 15
  # set_seed(12345)
  for i in 1:repeatn
    problem = setcover()
    dim = setcover_dim()
    obj = Objective(setcover_fx, dim, args=problem)

    budget = 100 * dim.size
    par = Parameter(budget=budget, autoset=false, asynchronous=false, computer_num = 3)
    par.train_size = 6
    par.positive_size = 1
    par.negative_size = 5

    sol = zoo_min(obj, par)
    push!(result, sol.value)
    println("solved solution is:")
    sol_print(sol)
  end
  result_analysis(result, 5)
  time_log2 = now()
  expect_time = Dates.value(time_log2 - time_log1) / 1000
  println(expect_time)
end

# mixed optimization
if false
  repeat = 15
  result = []
  set_seed(12345)
  for i in 1:repeat
    dim_size = 10
    dim_regs = []
    dim_tys = []
    # In this example, dimension is mixed. If dimension index is odd, this dimension if discrete, Otherwise, this
    # dimension is continuous.
    for j in 1:dim_size
      if j % 2 == 0
        push!(dim_regs, [0, 1])
        push!(dim_tys, true)
      else
        push!(dim_regs, [0, 100])
        push!(dim_tys, false)
      end
    end
    dim = Dimension(dim_size, dim_regs, dim_tys)
    obj = Objective(mixed_functin, dim)
    budget = 2000
    par = Parameter(budget=budget, autoset=true)
    sol = zoo_min(obj, par)
    sol_print(sol)
    push!(result, sol.value)
  end
  result_analysis(result, 5)
end
