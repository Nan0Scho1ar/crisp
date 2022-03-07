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
    {_, env} = Crisp.Env.start_link()
    prog = "(begin
              (define a 10)
              (define b 20)
              (define add
                (lambda (x y) (+ x y)))
              (add a b))"
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
  def start do
    Crisp.Repl.start()
  end
end
