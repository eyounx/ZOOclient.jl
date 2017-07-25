module fx

importall solution

export sphere

function sphere(solution)
  x = solution.x
  value = sum((x - 0.2).^2)
  return value
end

# x = Solution(x = [0.2, 0.2, 0.2])
# print(sphere(x))

end
