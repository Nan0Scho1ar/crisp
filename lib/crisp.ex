defmodule Crisp do
  @moduledoc """
  Documentation for `Crisp`.
  """

  def run do
    {status, env} = Crisp.Env.start_link()
    prog = "(print \"testing\")"
    Crisp.Eval.eval(prog, env)
  end

  def repl do
    {status, env} = Crisp.Env.start_link()
    Crisp.Repl.repl(env)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Crisp.hello()
      :world

  """
  def hello do
    :world
  end
end
