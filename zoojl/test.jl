using Base.Test
# using Base.Dates

importall parameter, dimension, solution, zoo_global, objective

type aa
  x
  value
  function aa(a; value=0)
    return new(a, value)
  end
end

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
