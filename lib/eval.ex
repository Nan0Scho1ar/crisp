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

  def eval_ast_func([func | args], env) do
    # IO.inspect(func)
    function = Crisp.Env.fetch_atom(func, env)
    arguments = Enum.map(args, fn a -> eval_ast([a], env) end)
    # IO.inspect(arguments)
    function.(arguments)
  end
end
