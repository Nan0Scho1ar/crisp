defmodule Crisp.Repl do
  def start do
    {_, env} = Crisp.Env.start()
    repl(env)
  end

  def repl(env) do
    result =
      IO.gets("Crisp> ")
      |> Crisp.Eval.eval(env)

    unless result == "SIGTERM" do
      IO.inspect(result)
      repl(env)
    end
  end
end
