module AISHBenchmark

using RelevanceStacktrace

using JuliaLLMLeaderboard
using PromptingTools
using DataStructures: OrderedDict
using Anthropic
using TOML

using AISH: initialize_ai_state, curr_conv_msgs, anthropic_ask_safe
using AISH: Message

using JuliaLLMLeaderboard: find_definitions

# Global variable to store benchmark results
BENCHMARK_RESULTS::OrderedDict{String, Dict{String, Any}} = OrderedDict{String, Dict{String, Any}}()

include("utils.jl")
include("prints.jl")
include("JuliaLLMLeaderboard.jl")



end # module AISHBenchmark
