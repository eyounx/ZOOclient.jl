push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/asynchronousracos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example")
print("load successfully")

using asracos

@everywhere function test_computer(asracos::ASRacos)
  println("in test_computer")
end

@everywhere function test_updater(asracos::ASRacos)
  println("in test_updater")
end

@everywhere function test_parallel(asracos::ASRacos)
  arc = asracos.arc
  rc = arc.rc
  for i = 1:5
    put!(arc.sample_set, i)
  end
  addprocs(6)
  i = 1
  for p in workers()
    if i == 1
      @async remote_do(test_updater, p, asracos)
      i += 1
    else
      @async remote_do(test_computer, p, asracos)
    end
  end
end

asr = ASRacos(5)
test_parallel(asr)
