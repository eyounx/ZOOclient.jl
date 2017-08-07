module gym_task

importall nn_model

using PyCall

export GymTask, transform_action, new_nnmodel!, nn_policy_sample, sum_reward!

# @pyimport("gym")

# @pyimport("gym.spaces.discrete") as Discrete

gym = pyimport("gym")

# @pyimport("gym.spaces.discrete.Discrete") as Discrete

isinstance = pybuiltin("isinstance")

type GymTask
  envir
  envir_name
  obser_size
  obser_low_bound
  obser_up_bound
  action_size
  action_sca
  action_type
  action_low_bound
  action_up_bound
  policy_model
  max_step
  stop_step

  function GymTask(name)
    envir = gym[:make](name)
    envir_name = name
    obser_size = envir[:observation_space][:shape][1]
    obser_up_bound = []
    obser_low_bound = []
    for i in 1:obser_size
      push!(obser_low_bound, envir[:observation_space][:high][i])
      push!(obser_up_bound, envir[:observation_space][:low][i])
    end

    #default settting
    action_size = 0
    action_sca = []
    action_type = []
    action_low_bound = []
    action_up_bound = []
    policy_model = Nullable()
    max_step = 0
    stop_step = 0

    # gym[:spaces][:discrete][:Discrete]
    if isinstance(envir[:action_space], gym[:spaces][:discrete][:Discrete])
      println("envir discrete")
      action_size = 1
      action_sca = []
      action_type = []
      push!(action_sca, envir[:action_space][:n])
      push!(action_type, false)
    else
      action_size = envir[:action_space][:shape][1]
      for i in 1:action_size
        push!(action_type, true)
        push!(action_low_bound, envir[:action_space][:low][i])
        push!(action_up_bound, envir[:action_space][:high][i])
      end
    end
    return new(envir, envir_name, obser_size, obser_low_bound, obser_up_bound,
      action_size, action_sca, action_type, action_low_bound, action_up_bound,
      policy_model, max_step, stop_step)
  end
end

function transform_action(gt::GymTask, temp_act)
  action = []
  for i in 1:gt.action_size
    # if action is continue
    if gt.action_type[i]
      tmp_act = (temp_act[i] + 1) * ((gt.action_up_bound[i] -
        gt.action_low_bound[i]) / 2.0) + gt.action_low_bound[i]
      push!(action, tmp_act)
    else
      sca = 2.0 / gt.action_sca[1]
      start = -1.0
      now_value = start + sca
      true_act = 0
      while now_value <= 1.0
        if temp_act[i] <= now_value
          break
        else
          now_value += sca
          true_act += 1
        end
      end
      if true_act >= gt.action_sca[i]
        true_act = gt.action_sca[i] - 1
      end
      push!(action, true_act)
    end
  end
  if gt.action_size == 1
    action = action[1]
  end
  return action
end

function new_nnmodel!(gt::GymTask, layers)
  gt.policy_model = NNModel()
  construct_nnmodel!(gt.policy_model, layers)
end

function nn_policy_sample(gt::GymTask, observation)
  #action = []
  output = cal_output_nnm(gt.policy_model, observation)
  action = transform_action(output)
  return action
end

function sum_reward!(solution, gt::GymTask)
  x = solution.x
  sum_re = 0
  # reset stop step
  gt.stop_step = gt.max_step
  # reset nn model weight
  decode_w_nnm(gt.policy_model, x)
  # reset enviroment
  observation = gt.envir[:reset]()
  for i in 1:gt.max_step
    action = nn_policy_sample(gt, observation)
    observation, reward, done, info = gt.envir[:step](action)
    sum_re += reward
    if done
      gt.stop_step = i
      break
    end
  end
  value = sum_re
  name = gt.envir_name
  if name == "CartPole-v0" || name == "MountainCar-v0" name == "Acrobot-v1" ||
    name == "HalfCheetah-v1" || name == "Humanoid-v1" || name == "Swimmer-v1" ||
    name == "Ant-v1" || name == "Hopper-v1" || name == "LunarLander-v2" ||
    name == "BipedalWalker-v2"
    value = -value
  end
  return value
end

end
