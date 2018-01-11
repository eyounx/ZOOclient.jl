module ZOOjl

export Dimension, dim_rand_sample, dim_limited_space, dim_print, is_discrete
export Objective, obj_construct_solution, obj_eval, get_history_bestsofar
export zoo_min
export Parameter, autoset!
export Solution, find_max, find_min, sol_print, sol_equal
# tool_function.jl
export zoolog, rand_uniform, convert_time, mydistance
export rng, my_precision, set_seed, set_precision
# racos_classification.jl
export RacosClassification, mixed_classification, rand_sample
# racos_common.jl
export RacosCommon, clear!, init_attribute!, selection!, distinct_sample,
distinct_sample_classifier, print_positive_data, print_negative_data, print_data,
distinct_sample_from_set
# racos_optimization.jl
export RacosOptimization, opt!, clear!, set_ub
# racos.jl
export Racos, racos_opt!
# sracos.jl
export SRacos, sracos_opt!, replace
# asracos_common
export ASRacosCommon, init_sample_set!
# asracos_optimization
export asyn_opt!
# asracos.jl
export ASRacos, asracos_opt!, updater
# tcp_asracos.jl
export tcp_asracos!

include("zoojl/dimension.jl")
include("zoojl/objective.jl")
include("zoojl/parameter.jl")
include("zoojl/solution.jl")
include("zoojl/utils/tool_function.jl")
include("zoojl/utils/zoo_global.jl")
include("zoojl/algos/racos/racos_classification.jl")
include("zoojl/algos/racos/racos_common.jl")
include("zoojl/algos/racos/racos.jl")
include("zoojl/algos/racos/sracos.jl")
include("zoojl/algos/racos/racos_optimization.jl")
include("zoojl/algos/asracos/asracos_common.jl")
include("zoojl/algos/asracos/asracos.jl")
include("zoojl/algos/asracos/tcp_asracos.jl")
include("zoojl/algos/asracos/asracos_optimization.jl")
include("zoojl/optimize.jl")
end
