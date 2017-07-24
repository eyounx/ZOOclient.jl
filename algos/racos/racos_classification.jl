module racos_classification

importall solution, tool_function

export RacosClassification, mixed_classification

type RacosClassification
  solution_space
  sample_region
  label
  positive_solution
  negative_solution
  x_positive
  uncertain_bit

  function RacosClassification(dim, positive, negative; ub=1)
    solution_space = dim
    sample_region = []
    label = []
    # solution
    positive_solution = positive
    negative_solution = negative
    x_positive = Nullable()
    uncertain_bit = ub

    regions = dim.regions()
    for i in 1:dim.size
      temp = [regions[i][1], regions[i][2]]
      append!(sample_region, temp)
      append!(label, false)
    end
  end
end

function reset_classifier(classifier)
  regions = classfier.solution_space.regions
  for i in 1:classifier.solution_space.size
    classifier.sample_region[i][0] = regions[i][0]
    classifier.sample_region[i][1] = regions[i][1]
    classifier.label[i] = false
  end
  classifier.x_positive = Nullable()
end

function mixed_classification(classifier)
  classifier.x_positive = classifier.positive_solution(rand(rng, 1:length(classifier.positive_solution)))
  len_negative = length(classifier.negative_solution)
  index_set = 1:classifier.solution_space.size
  types = classifier.solution_space.types
  while len_negative > 0
    k = index_set(rand(rng, 1:len(index_set)))
    x_pos_k = classifier.x_positive.x[k]
    # continuous
    if types[k] == true
      x_negative = classifier.negative_solution[rand(rng, 1:len_negative)]
      x_neg_k = x_negative[k]
      if x_pos_k < x_neg_k
        r = rand(rng, Float) * (x_neg_k - x_pos_k) + x_pos_k
        if r < classifier.sample_region[k][2]
          classifier.sample_region[k][2] = r
          i = 0
          while i < len_negative
            if classifier.negative_solution[i].x[k] >= r
              len_negative -= 1
              itemp = classifier.negative_solution[i]
              classifier.negative_solution[i] = classifier.negative_solution[len_negative]
              classifier.negative_solution[len_negative] = itemp
            else
              i += 1
            end
          end
        end
      else
        r = rand(rng, Float) * (x_pos_k - x_neg_k) + x_neg_k
        if r > classifier.sample_region[k][1]
          classifier.sample_region[k][1] = r
          i = 0
          while i < len_negative
            if classifier.negative_solution[i].x[k] <= r
              len_negative -= 1
              itemp = classifier.negative_solution[i]
              classifier.negative_solution[i] = classifier.negative_solution[len_negative]
              classifier.negative_solution[len_negative] = itemp
            else
              i += 1
            end
          end
        end
      end
    # discrete
    else
      delete = 0
      i = 0
      while i < len_negative
        if classifier.negative_solution[i].x[k] != x_pos_k
          len_negative -= 1
          delete += 1
          itemp = classifier.negative_solution[i]
          classifier.negative_solution[i] = classifier.negative_solution[len_negative]
          classifier.negative_solution[len_negative] = itemp
        else
          i += 1
        end
      end
      if delete != 0
        splice!(index_set, k)
      end
    end
    set_uncertain_bit!(classifier, index_set)
  end
end

function set_uncertain_bit!(classifier, iset)
  index_set = iset
  for i in 1:classifier.uncertain_bits
    index = index_set[rand(rng, 1:length(index_set))]
    classifier.label[index] = true
    splice!(index_set, index)
  end
end

function rand_sample(classifier)
  x = []
  for i in 1:classifier.solution_space.size
    if classifier.label[i] == true
      if classifier.solution_space.types[i] == true
        push!(x, rand_uniform(rng, classifier.sampleregion[i][1]), classifier.sample_region[i][2])
      else
        push!(x, rand(rng, classifier.sample_region[i][1]:classifier.sample_region[i][2]))
      end
    else
      push!(x, classifier.x_positive.x[i])
    end
  end
  return x
end

# for dubugging
function print_neg(classifier)
  zoolog("------print neg------")
  for x in classifier.negative_solution
    sol_print(x)
  end
end

function print_pos(classifier)
  zoolog("------print pos------")
  for x in classifier.positive_solution
    sol_print(x)
  end
end

function print_sample_region(classifier)
  zoolog("------print sample region------")
  zoolog(classifier.sample_region)
end

end
