defmodule Crisp.Repl do
  def start do
    {_, env} = Crisp.Env.start()
    repl(env)
  end

  def repl(env) do
    try do
      result =
        IO.gets("Crisp> ")
        |> Crisp.Eval.eval(env)

      if result == "SIGTERM" do
        exit(:shutdown)
      else
        IO.inspect(result)
      end
    rescue
      x ->
        IO.inspect(x)
        # catch
        #   :exit, value ->
        #     IO.puts("Exited with value #{inspect(value)}")
    end

    repl(env)
  end
end
