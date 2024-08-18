using Dates
using Printf
using TOML
using DataStructures: OrderedDict


print_score(res) = begin
    if res isa Dict
        println("Parsed: $(res["parsed"]) Executed: $(res["executed"]), P: $(res["unit_tests_passed"])/$(res["unit_tests_count"]), E: $(res["examples_executed"])/$(res["examples_count"]), $(res["elapsed_seconds"])s, \$$(res["cost"]) Label: $(res["prompt_label"])")
    else
        println("Parsed: $(res.parsed) Executed: $(res.executed), P: $(res.unit_tests_passed)/$(res.unit_tests_count), E: $(res.examples_executed)/$(res.examples_count), $(res.elapsed_seconds)s, \$$(res.cost) Label: $(res.prompt_label)")
    end
end


function print_benchmark_results(filename::String)
    results = TOML.parsefile(filename)

    println("Benchmark Results Summary")
    println("=========================")
    println("Date: $(results["metadata"]["date"])")
    println("Git Commit: $(results["metadata"]["git_commit"])")
    println("Overall Pass: $(results["metadata"]["overall_pass"])")
    println("Overall Exec: $(results["metadata"]["overall_exec"])")
    println("Score: $(results["metadata"]["score"])")
    println("\nIndividual Benchmark Scores:")

    for (prompt_label, res) in results["prompt_results"]
        println("\n$prompt_label:")
        print_score(res)
    end
end

function print_all_benchmark_results()
    benchmark_dir = "benchmarks"
    benchmark_files = filter(f -> startswith(f, "bench_") && endswith(f, ".toml"), readdir(benchmark_dir))

    for file in sort(benchmark_files, rev=true)
        println("\n\nProcessing file: $file")
        print_benchmark_results(joinpath(benchmark_dir, file))
    end
end
