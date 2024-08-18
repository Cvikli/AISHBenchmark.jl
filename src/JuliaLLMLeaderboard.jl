


function benchmark_event_scheduler()
    println("Benchmark started...")
    fn_definitions = find_definitions(joinpath(dirname(dirname(pathof(JuliaLLMLeaderboard))),"code_generation/"))

    for fn_definition in fn_definitions
        definition = TOML.parsefile(fn_definition)["code_generation"]
        name = definition["name"]

        if haskey(BENCHMARK_RESULTS, name) &&
           BENCHMARK_RESULTS[name]["examples_executed"] == BENCHMARK_RESULTS[name]["examples_count"] &&
           BENCHMARK_RESULTS[name]["unit_tests_passed"] == BENCHMARK_RESULTS[name]["unit_tests_count"]
            println("Skipping $name - All tests already passed.")
        else
            result = run_generic_benchmark(fn_definition)
            BENCHMARK_RESULTS[name] = Dict(
                "examples_executed" => result.examples_executed,
                "examples_count" => result.examples_count,
                "unit_tests_passed" => result.unit_tests_passed,
                "unit_tests_count" => result.unit_tests_count,
                "parsed" => result.parsed,
                "executed" => result.executed,
                "elapsed_seconds" => result.elapsed_seconds,
                "cost" => result.cost,
                "prompt_label" => result.prompt_label
            )
        end
    end
    return
end


function run_generic_benchmark(definition_file::String)
    println("Definition file: $definition_file")
    definition = TOML.parsefile(definition_file)["code_generation"]
    @show definition["name"]
    ai_state = initialize_ai_state()
    user_question = definition["prompt"]
    println(user_question)
    push!(cur_conv_msgs(ai_state), Message(now(), :user, user_question))
  
    conversation = anthropic_ask_safe(ai_state, return_all=true)
  
    # Evaluate 1SHOT
    conversation_mod = deepcopy(conversation)
    println("CODE:")
    println(conversation_mod[end].content)
    conversation_mod[end] = AIMessage(
      conversation_mod[end].content,
              # extract_sh_block_to_julia_code(conversation_mod[end].content),
              conversation_mod[end].status,
              conversation_mod[end].tokens,
              conversation_mod[end].elapsed,
              conversation_mod[end].cost,
              conversation_mod[end].log_prob,
              conversation_mod[end].finish_reason,
              conversation_mod[end].run_id,
              conversation_mod[end].sample_id,
              conversation_mod[end]._type
    )
  
    eval_result = evaluate_1shot(
        conversation=conversation_mod,
        fn_definition=definition_file,
        definition=definition,
        model=ai_state.model,
        prompt_label=definition["name"],
        device="HM-PC",
        schema="-",
        prompt_strategy="1SHOT",
        verbose=true,
        capture_stdout=true 
    )
  
    # println("\nEvaluation result:")
    # display(eval_result)
    print_score(eval_result)
    eval_result
  end
  



