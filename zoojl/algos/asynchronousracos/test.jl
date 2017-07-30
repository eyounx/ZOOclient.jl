# function count_heads(n)
#     c::Int = 0
#     for i=1:n
#         c += rand(0:1)
#     end
#     c
# end
function add_ele(set, n, time)
    print(n)
    sleep(time)
    return n
end

seta = []
i = 3
while i > 0
    a = @spawn add_ele(seta, i, i)
    push!(seta, fetch(a))
    i -= 1
end

# while()
print(seta)
#
# function rr()
#  sleep(5)
#  return 5
# end
#  r = @spawn rr()
#  # wait(r)
#  print(fetch(r))
