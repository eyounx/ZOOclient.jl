push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/racos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/algos/asynchronousracos")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/utils")
push!(LOAD_PATH, "/Users/liu/Desktop/CS/github/ZOOjl/zoojl/example")
print("load successfully")

@everywhere importall test_parallel, test_datastructure

t = Test(5)
test_par(t)
