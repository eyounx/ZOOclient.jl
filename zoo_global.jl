module ZooGlobal

export rng, my_precision, set_seet, set_precision

global rng = srand()
global my_precision = 1e-17

function set_seed(seed)
  srand(rng, seed)
end

function set_precision(prec)
  my_precision = prec
end

end

# a = rand(rng, 1:10)
