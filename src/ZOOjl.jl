module ZOOjl

using Base.Dates.now

export Dimension, dim_rand_sample, dim_limited_space, dim_print, is_discrete
export Objective, obj_construct_solution, obj_eval, get_history_bestsofar
export zoo_min, exp_min
export Parameter, autoset!
export Solution, find_max, find_min, sol_print, sol_equal

export zoolog, rand_uniform, convert_time, mydistance
export rng, my_precision, set_seed, set_precision

export RacosClassification, mixed_classification, rand_sample
# racos_common.jl
export RacosCommon, rc_clear!, init_attribute!, selection!, distinct_sample,
distinct_sample_classifier, print_positive_data, print_negative_data, print_data,
distinct_sample_from_set
# racos_optimization.jl
export RacosOptimization, opt!, ro_clear!, set_ub
# racos.jl
export Racos, racos_opt!
# sracos.jl
export SRacos, sracos_opt!, sracos_replace!

export ASRacos, asracos_init_sample_set!

export asracos_opt!
export aposs_opt!

include("zoojl/utils/tool_function.jl")
include("zoojl/utils/zoo_global.jl")
include("zoojl/dimension.jl")
include("zoojl/objective.jl")
include("zoojl/parameter.jl")
include("zoojl/solution.jl")
include("zoojl/algos/racos/racos_classification.jl")
include("zoojl/algos/racos/racos_common.jl")
include("zoojl/algos/racos/racos.jl")
include("zoojl/algos/racos/sracos.jl")
include("zoojl/algos/racos/racos_optimization.jl")
include("zoojl/algos/asracos/asracos.jl")
include("zoojl/algos/asracos/asracos_opt.jl")
include("zoojl/algos/aposs/aposs_opt.jl")
include("zoojl/optimize.jl")
end
