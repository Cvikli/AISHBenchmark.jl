using Dates
using Printf
using TOML
using DataStructures: OrderedDict

function extract_sh_block_to_julia_code(input_string)
    @show "input_string"
    println(input_string)
    code_block_regex = r"```sh\n(.*?)```\n"s
    m = match(code_block_regex, input_string)
    m === nothing && return input_string

    code_content = m.captures[1]
    julia_code = replace(code_content, r".*?\"EOL\"\n"s => "")
    julia_code = replace(julia_code, r"\nEOL.*"s => "")

    return replace(input_string, code_block_regex => "```julia\n$julia_code\n```")
end


function save_benchmark_result(benchmark_results::OrderedDict{String, Dict{String, Any}} = BENCHMARK_RESULTS)
    date_str = Dates.format(Dates.now(), "yymmdd_HHMM")

    git_commit = try
        readchomp(`git rev-parse --short HEAD`)
    catch
        "Unknown"
    end

    total_passed = sum(res["unit_tests_passed"] for (_, res) in benchmark_results)
    total_all_passed = sum(res["unit_tests_count"] for (_, res) in benchmark_results)
    total_exec = sum(res["examples_executed"] for (_, res) in benchmark_results)
    total_all_exec = sum(res["examples_count"] for (_, res) in benchmark_results)

    pass_percentage = @sprintf("%.2f", (total_passed / total_all_passed) * 100)
    exec_percentage = @sprintf("%.2f", (total_exec / total_all_exec) * 100)

    filename = "bench_$(pass_percentage)_$(exec_percentage)_$(date_str)_$(git_commit).toml"

    result = OrderedDict(
        "metadata" => Dict(
            "date" => date_str,
            "git_commit" => git_commit,
            "overall_pass" => "$(pass_percentage)%",
            "overall_exec" => "$(exec_percentage)%",
        ),
        "prompt_results" => benchmark_results
    )

    benchmark_dir = joinpath(@__DIR__, "..", "benchmarks")
    mkpath(benchmark_dir)
    filepath = joinpath(benchmark_dir, filename)

    open(filepath, "w") do file
        TOML.print(file, result)
    end

    println("Benchmark results saved to $filename")
    return filename
end


