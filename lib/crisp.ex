defmodule Crisp do
  @moduledoc """
  Documentation for `Crisp`.
  """

  @doc """
  Run a hardcoded command

  ## Example

      iex> Crisp.run()
      testing

  """
  def run do
    {status, env} = Crisp.Env.start_link()
    prog = "(print \"testing\")"
    Crisp.Eval.eval(prog, env)
  end

  @doc """
  Start a repl

  ## Example

      iex> Crisp.repl()
      Crisp> (print "Hello world")
      Hello World
      Crisp> (exit)
      nil
      iex>
  """
  def repl do
    Crisp.Repl.start()
  end
end
