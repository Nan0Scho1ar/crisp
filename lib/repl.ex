defmodule Crisp.Repl do
  def start, do: Crisp.Env.start() |> repl

  def repl(env) do
    result =
      IO.gets("Crisp> ")
      |> Crisp.Eval.eval(env)

    unless result == "SIGTERM" do
      repl(env)
    end
  end
end
