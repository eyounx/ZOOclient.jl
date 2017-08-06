module fx

importall solution

export sphere

function sphere(solution, args)
  l = 0
  for i = 1:5000000
    l += rand(1:5)
  end
  x = solution.x
  value = sum((x - 0.2).^2)
  return value
end

# x = Solution(x = [0.2, 0.2, 0.2])
# print(sphere(x))

end
