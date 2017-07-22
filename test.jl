using Base.Dates

using parameter

using solution

type aa
  x
  value
  function aa(a; value=0)
    return new(a, value)
  end
end

# temp = aa(1, value=2)
# print(temp)
# par = Parameter()
# print(par)
sol1 = Solution(x=[3], value=4)
sol2 = Solution(x=[2], value=3)

print(find_max([sol1, sol2]))
