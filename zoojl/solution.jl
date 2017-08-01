module solution

@everywhere importall dimension, zoo_global, tool_function

export Solution, find_max, find_min, sol_print, sol_equal

type Solution
  x
  value
  attach::Nullable
  function Solution(; x=[], value=0, attach = Nullable())
    new(x, value, attach)
  end
end

function sol_equal(sol1, sol2)
  if abs(sol1.value - sol2.value) > my_precision
    return false
  end
  if length(sol1.x) != length(sol2.x)
    return false
  end
  for i = 1:length(sol1.x)
    if abs(sol1.x[i] - sol2.x[i]) > my_precision
      return false
    end
  end
  return true
end

# find minimum solution in iset
function find_min(iset)
  min = Inf
  min_index = 0
  res = Solution()
  i = 0
  for sol in iset
    i += 1
    if sol.value < min
      min = sol.value
      min_index = i
      res = sol
    end
  end
  return res, min_index
end

# find maximum solution in iset
function find_max(iset)
  max = -Inf
  max_index = 0
  res = Solution()
  i = 0
  for sol in iset
    i += 1
    if sol.value > max
      max = sol.value
      max_index = i
      res = sol
    end
  end
  return res, max_index
end

function sol_print(sol)
  zoolog("x: $(sol.x)")
  zoolog("value: $(sol.value)")
  zoolog("attach: $(sol.attach)")
end

end
