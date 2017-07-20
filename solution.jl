module solution

using zoo_global

export Solution

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

end
