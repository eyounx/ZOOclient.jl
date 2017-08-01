# using Base.Test
# # using Base.Dates
#
# importall parameter, dimension, solution, zoo_global, objective
#
# type aa
#   x
#   value
#   function aa(a; value=0)
#     return new(a, value)
#   end
# end

## test parameter.jl
# temp = aa(1, value=2)
# print(temp)
# par = Parameter()
# print(par)

##test solution.jl
# sol1 = Solution(x=[3], value=4)
# sol2 = Solution(x=[2], value=3)
#
# print(find_max([sol1, sol2]))

## test zoo_global.jl
# set_seed(10)
# print(rand(rng, [1, 2, 3]))

## test obj.jl
# f(x) = x.x.^2
# dim = Dimension(3, [[0, 3], [0, 3], [0, 3]], [true, true, true])
# obj = Objective(f, dim)
# sol = obj_construct_solution(obj, [1, 2, 2])
# obj_eval(obj, sol)
# @test sol.value == [1, 4, 4]

addprocs(4) # add worker processes

@everywhere type T
    icount
end

jobs = RemoteChannel(()->Channel(32));

results = RemoteChannel(()->Channel(32));

@everywhere function do_work(i, jobs, results) # define work function everywhere
  println("in do_work$(i.icount)")
  while true
      job_id = take!(jobs)
      exec_time = rand()
      sleep(exec_time) # simulates elapsed time doing actual work
      put!(results, (job_id, exec_time, myid()))
  end
end

function make_jobs(n)
   for i in 1:n
       put!(jobs, i)
   end
end;

n = 12;

make_jobs(n); # feed the jobs channel with "n" jobs

# for p in jobs
#     print(p)
# end
count = 1
for p in workers() # start tasks on the workers to process requests in parallel
    a = T(count)
   @async remote_do(do_work, p, a, jobs, results)
   count += 1
end

# @elapsed while n > 0 # print out results
#    job_id, exec_time, where = take!(results)
#    println("$job_id finished in $(round(exec_time,2)) seconds on worker $where")
#    n = n - 1
# end
