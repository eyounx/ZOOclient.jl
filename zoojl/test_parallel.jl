module test_parallel

importall test_datastructure

export test_par
# @everywhere type Test
#   tt
# end

function test_computer(t::Test)
  println("in test_computer $(t.tt.aa)")
end

function test_updater(t::Test)
  println("in test_updater $(t.tt.aa)")
end

function test_par(t::Test)
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
end
