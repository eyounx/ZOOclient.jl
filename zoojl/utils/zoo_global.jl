module zoo_global

export rng, my_precision, set_seed, set_precision

@everywhere global rng = srand()
@everywhere global my_precision = 1e-17

@everywhere function set_seed(seed)
  srand(rng, seed)
end

@everywhere function set_precision(prec)
  my_precision = prec
end

end

# a = rand(rng, 1:10)
