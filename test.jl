using Base.Dates

type aa
  x
  value
  function aa(a, value=0)
    return new(a, value)
  end
end

# sol = aa(1)
# print(sol)
t1 = now()
sleep(2)
t2 = now()
# t = (t2 - t1) / 1000
print(convert(Int64, Dates.value(t2-t1)) / 1000)
# print(Int64(t2-t1))
