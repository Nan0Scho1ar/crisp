defmodule Crisp.Eval do
  def eval(str, env), do: str |> Crisp.Parse.parse() |> eval_ast(env)

  def eval_ast([h | _], _) when is_integer(h), do: h
  def eval_ast([h | _], _) when is_bitstring(h), do: h
  def eval_ast([h | _], _) when is_float(h), do: h
  def eval_ast([h | _], env) when is_list(h), do: eval_ast_func(h, env)
  def eval_ast([h | _], env) when is_atom(h), do: Crisp.Env.fetch_atom(h, env)

  def eval_ast_func([:if | [test | [a | [b | _]]]], env) do
    if eval_ast([test], env) do
      eval_ast([a], env)
    else
      eval_ast([b], env)
    end
  end

  def eval_ast_func([:quote | val], env), do: val |> hd

  # Not sure if this is correct, but it seems to work.
  def eval_ast_func([:eval | val], env) do
    eval_ast(val, env) |> eval_ast_func(env)
  end

  def eval_ast_func([:set! | [key | val]], env) do
    send(env, {:put, key, eval_ast(val, env)})
  end

  def eval_ast_func([:define | [key | val]], env) do
    send(env, {:put, key, eval_ast(val, env)})
  end

  # Return a function which will populate the env, then eval the body when called
  def eval_ast_func([:lambda | [params | body]], env) do
    fn args ->
      # Set params in new_env using args which will be passed in at eval time
      {_, new_env} = Crisp.Env.clone(env)
      for {p, a} <- Enum.zip(params, args), do: send(new_env, {:put, p, a})
      eval_ast(body, new_env)
    end
  end

  def eval_ast_func([func | args], env) do
    function = eval_ast([func], env)
    arguments = Enum.map(args, fn a -> eval_ast([a], env) end)
    function.(arguments)
  end
end
