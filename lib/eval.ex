defmodule Crisp.Eval do
  def eval(str, env), do: str |> Crisp.Parse.parse() |> eval_ast(env)

  def eval_ast([h | _], _) when is_integer(h), do: h
  def eval_ast([h | _], _) when is_bitstring(h), do: h
  def eval_ast([h | _], _) when is_float(h), do: h
  def eval_ast([h | _], env) when is_list(h), do: eval_ast_func(h, env)
  def eval_ast([h | _], env) when is_atom(h), do: Crisp.Env.fetch_atom(h, env)

  # quote
  # if
  # define
  # set!
  # lambda

  def eval_ast_func([:if | [test | [a | [b | _]]]], env) do
    if eval_ast([test], env) do
      eval_ast([a], env)
    else
      eval_ast([b], env)
    end
  end

  def eval_ast_func([:quote | val], env) do
    val
  end

  def eval_ast_func([:set! | [key | val]], env) do
    send(env, {:put, key, eval_ast(val, env)})
  end

  def eval_ast_func([:define | [key | val]], env) do
    send(env, {:put, key, eval_ast(val, env)})
  end

  def eval_ast_func([:list | args], env) do
    Enum.map(args, fn a -> eval_ast([a], env) end)
  end

  def eval_ast_func([:begin | args], env) do
    Enum.map(args, fn a -> eval_ast([a], env) end)
    |> List.last()
  end

  # Return a function which will populate the env then eval the body
  def eval_ast_func([:lambda | [params | body]], env) do
    fn args ->
      {_, new_env} = Crisp.Env.start_link()
      # Set params in new_env using args which will be passed in at eval time
      pairs = Enum.zip(params, args)
      for {p, a} <- pairs, do: send(new_env, {:put, p, a})

      eval_ast([body], new_env)
    end
  end

  def eval_ast_func([func | args], env) do
    function = eval_ast([func], env)
    IO.inspect(function)

    arguments = Enum.map(args, fn a -> eval_ast([a], env) end)
    IO.inspect(arguments)

    function.(arguments) |> IO.inspect()
  end
end
