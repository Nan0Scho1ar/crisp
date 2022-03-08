defmodule Crisp do
  # @moduledoc """
  # Documentation for `Crisp`.
  # """

  def run_file(fname) do
    {_, env} = Crisp.Env.start_link()
    {:ok, prog} = File.read(fname)
    IO.puts(prog)
    Crisp.Eval.eval(prog, env)
  end

  # @doc """
  # Run a hardcoded command

  # ## Example

  #     iex> Crisp.run()

  # """
  def run do
    {_, env} = Crisp.Env.start_link()
    prog = "
(begin
  (define a 10)
  (define b 20)
  (define double-then-add
    (lambda (x y)
      (+ ((lambda (i) (+ i i)) x)
         ((lambda (j) (+ j j)) y))))
  (double-then-add a b))"
    IO.puts(prog)
    Crisp.Eval.eval(prog, env)
  end

  # @doc """
  # Start a repl

  # ## Example

  #     iex> Crisp.repl()
  #     Crisp> (print "Hello world")
  #     Hello World
  #     Crisp> (exit)
  #     nil
  #     iex>
  # """
  def start do
    Crisp.Repl.start()
  end
end
