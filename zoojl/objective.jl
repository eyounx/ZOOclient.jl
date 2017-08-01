module objective

importall solution

using Base.Test

export Objective, obj_construct_solution, obj_eval, get_history_bestsofar

type Objective
  func
  dim
  inherit
  constraint
  history

  function Objective(func=Nullable(), dim=Nullable(); constraint=Nullable())
    return new(func, dim, obj_default_inherit, constraint, [])
  end
end

function obj_construct_solution(objective, x; parent=Nullable())
  sol = Solution()
  sol.x = x
  sol.attach = objective.inherit(parent=parent)
  return sol
end

# evaluate the objective function of a solution
function obj_eval(objective, solution)
  solution.value = objective.func(solution)
  append!(objective.history, solution.value)
end

function obj_eval_constraint(objective, solution)
  #Todo
end

function obj_default_inherit(; parent=Nullable())
  return Nullable()
end

function get_history_bestsofar(objective)
  history_bestsofar = []
  bestsofar = Inf
  for i in 1:length(objective.history)
    if objective.history[i] < bestsofar
      bestsofar = objective.history[i]
    end
    history_bestsofar.append(bestsofar)
  end
  return history_bestsofar
end

end
