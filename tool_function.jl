module ToolFunction

export zoolog, rand_uniform

function zoolog(text)
  println("[zoopt] $text")
end

function rand_uniform(rng, lower, upper)
  return rand(rng, float) * (upper - lower) + lower
end
end
