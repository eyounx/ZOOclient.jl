push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/asynchronousracos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example")
print("load successfully")

@everywhere importall test_datastructure

# @everywhere type Test
#   tt
# end

@everywhere function test_computer(t::Test)
  println("in test_computer $(t.tt)")
end

@everywhere function test_updater(t::Test)
  println("in test_updater $(t.tt)")
end

@everywhere function test_parallel(t::Test)
  addprocs(6)
  i = 1
  for p in workers()
    if i == 1
      @async remote_do(test_updater, p, t)
      i += 1
    else
      @async remote_do(test_computer, p, t)
    end
  end
end

# asr = ASRacos(5)
t = Test(5)
test_parallel(t)
