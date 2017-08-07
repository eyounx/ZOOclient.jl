push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/asynchronousracos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/direct_policy_search_for_gym")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example/simple_functions")
print("load successfully")

importall gym_task, nn_model, dimension, parameter, objective, solution, tool_function,
  zoo_global, optimize
# in_layers means layers information. eg. [2, 5, 1] means input layer has 2 neurons, hidden layer(only one) has 5,
# output layer has 1.
# in_budget means budget
# maxstep means stop step in gym
# repeat means repeat number in a test.
function run_test(task_name, layers, in_budget, max_step, repeat)
  gym_task = GymTask(task_name)  # choose a task by name
  new_nnmodel!(gym_task, layers) # construct a neural network
  gym_task.max_step = max_step # set max step in gym
  budget = in_budget # number of calls to the objective function
  rand_probability = 0.95 # the probability of sample in model

  dim_size = gym_task.policy_model.w_size
  zoolog(dim_size)
  dim_regs = [[-10, 10] for i = 1:dim_size]
  dim_tys = [true for i = 1:dim_size]
  dim = Dimension(dim_size, dim_regs, dim_tys)

  objective = Objective(sum_reward!, dim, args=gym_task)
  parameter = Parameter(budget=budget, autoset=true, probability=rand_probability, asynchronous=false)

  result = []
  sum = 0
  zoolog("solved solution is:")
  for i in 1:repeat
    ins = zoo_min(objective, parameter)
    push!(ins.value)
    sum += ins.value
    sol_print(ins)
  end
  zoolog(result)
  zoolog(sum / length(result))
end

mountain_car_layers = [2 5 1]
acrobot_layers = [6 5 3 1]
halfcheetah_layers = [17 10 6]
humanoid_layers = [376 25 17]
swimmer_layers = [8 5 3 2]
ant_layers = [111 15 8]
hopper_layers = [11 9 5 3]
lunarlander_layers = [8 5 3 1]
run_test("MountainCar-v0", mountain_car_layers, 10000, 10000, 10)
# run_test('Acrobot-v1', acrobot_layers, 2000, 500, 10)
# If you want to run the following examples, you may need to install more libs(mujoco, Box2D).
# run_test('HalfCheetah-v1', halfcheetah_layers, 2000, 10000, 10)
# run_test('Humanoid-v1', humanoid_layers, 2000, 50000, 10)
# run_test('Swimmer-v1', swimmer_layers, 2000, 10000, 10)
# run_test('Ant-v1', ant_layers, 2000, 10000, 10)
# run_test('Hopper-v1', hopper_layers, 2000, 10000, 10)
# run_test('LunarLander-v2', lunarlander_layers, 2000, 10000, 10)
