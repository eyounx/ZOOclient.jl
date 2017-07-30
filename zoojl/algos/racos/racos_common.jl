module racos_common

importall objective, dimension, racos_classification, solution

export RacosCommon, clear!, init_attribute!, selection!, distinct_sample,
distinct_sample_classifier, print_positive_data, print_negative_data, print_data

@everywhere type RacosCommon
  parameter
  objective
  data
  positive_data
  negative_data
  best_solution
  function RacosCommon()
    new(Nullable(), Nullable(), [], [], [], Nullable())
  end
end

@everywhere function clear!(rc::RacosCommon)
  rc.parameter = Nullable()
  rc.objective = Nullable()
  rc.data = []
  rc.positive_data = []
  rc.negative_data = []
  rc.best_solution = Nullable()
end

# Construct self._data, self._positive_data, self._negative_data
@everywhere function init_attribute!(rc::RacosCommon)
  # check if the initial solutions have been set
  data_temp = rc.parameter.init_sample
  if !isnull(data_temp) && isnull(rc.best_solution)
    for j in 1:length(date_temp)
      x = obj_construct_solution(rc.objective, data_temp[j])
      rc.data.append(obj_eval(rc.objective, x))
    end
    selection!(rc)
    return
  end
  # otherwise generate random solutions
  iteration_num = rc.parameter.train_size
  i = 0
  while i < iteration_num
    # distinct_flag: True means sample is distinct(can be use),
    # False means sample is distinct, you should sample again.
    x, distinct_flag = distinct_sample(rc, rc.objective.dim)
    # panic stop
    if isnull(x)
      break
    end
    if distinct_flag
      obj_eval(rc.objective, x)
      push!(rc.data, x)
      i += 1
    end
  end
  selection!(rc)
  return
end

# Sort self._data
# Choose first-train_size solutions as the new self._data
# Choose first-positive_size solutions as self._positive_data
# Choose [positive_size, train_size) (Include the begin, not include the end) solutions as self._negative_data
@everywhere function selection!(rc::RacosCommon)
  # print(length(rc.data))
  sort!(rc.data, by = x->x.value)
  rc.positive_data = rc.data[1:rc.parameter.positive_size]
  rc.negative_data = rc.data[(rc.parameter.positive_size+1):rc.parameter.train_size]
  rc.best_solution = rc.positive_data[1]
end

# distinct sample form dim, return a solution
@everywhere function distinct_sample(rc::RacosCommon, dim::Dimension; check_distinct=true, data_num=0)
  objective = rc.objective
  x = obj_construct_solution(objective, dim_rand_sample(dim))
  times = 1
  distinct_flag = true
  if check_distinct == true
    while is_distinct(rc.positive_data, x) == false ||
      is_distinct(rc.negative_data, x) == false
      x = obj_construct_solution(objective, dim_rand_sample(dim))
      times += 1
      if times % 10 == 0
        limited, number = dim_limited_space(dim)
        if limited == true
          if number <= data_num
            zoolog("racos_common.py: WARNING -- sample space has been fully enumerated. Stop early")
            return Nullable(), Nullable()
          end
        end
        if times > 100
          distinct_flag = false
          break
        end
      end
    end
  end
  return x, distinct_flag
end

# Distinct sample from a classifier, return a solution
# if check_distinct is False, you don't need to sample distinctly
@everywhere function distinct_sample_classifier(rc::RacosCommon, classifier; check_distinct=true, data_num=0)
  objective = rc.objective
  x = rand_sample(classifier)
  ins = obj_construct_solution(rc.objective, x)
  times = 1
  distinct_flag = true
  if check_distinct == true
    while is_distinct(rc.positive_data, ins) == false || is_distinct(rc.negative_data, ins) == false
      x = rand_sample(classifier)
      ins = obj_construct_solution(rc.objective, x)
      times += 1
      if times % 10 == 0
        space = classifier.sample_region
        limited, number = dim_limited_space(space)
        if limited == true
          if number <= data_num
            zoolog("racos_common: WARNING -- sample space has been fully enumerated. Stop early")
            return Nullable(), Nullable()
          end
        end
        if times > 100
          distinct_flag = false
          break
        end
      end
    end
  end
  return ins, distinct_flag
end

# Check if x is distinct from each solution in seta
# return False if there exists a solution the same as x,
# otherwise return True
@everywhere function is_distinct(seta, x)
  for ins in seta
    if sol_equal(x, ins)
      return false
    end
  end
  return true
end

# for dubugging
@everywhere function print_positive_data(rc::RacosCommon)
  zoolog("------print positive_data------")
  zoolog("the size of positive data is $(length(rc.positive_data))")
  for x in rc.positive_data
    sol_print(x)
  end
end

@everywhere function print_negative_data(rc::RacosCommon)
  zoolog("------print negative_data------")
  zoolog("the size of negative_data is $(length(rc.negative_data))")
  for x in rc.negative_data
    sol_print(x)
  end
end

@everywhere function print_data(rc::RacosCommon)
  zoolog("------print data------")
  zoolog("the size of data is $(length(rc.data))")
  for x in rc.data
    sol_print(x)
  end
end

end
