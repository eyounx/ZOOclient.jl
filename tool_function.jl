module ToolFunction

export zoolog, rand_uniform

function zoolog(text)
  println("[zoopt] $text")
end

function rand_uniform(rng, lower, upper)
  return rand(rng, float) * (upper - lower) + lower
end
end

function convert_time(second)
  sec = second
  hour = Int64(floor(sec / 3600))
  sec = sec - hour * 3600
  min = Int64(floor(sec / 60))
  sec = Int64(round(sec - min * 60))
  return "$(hour)h $(min)min $(sec)sec"
end

t = convert_time(70)
print(t)
