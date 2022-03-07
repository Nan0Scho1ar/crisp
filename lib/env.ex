defmodule Crisp.Env do
  @default_envars %{
    car: &Crisp.Env.car/1,
    cdr: &Crisp.Env.cdr/1,
    eq?: &Crisp.Env.eq?/2,
    print: &Crisp.Env.print/1
  }

  def start do
    Task.start(fn -> environment(@default_envars) end)
  end

  def start_link do
    Task.start_link(fn -> environment(@default_envars) end)
  end

  def fetch_atom(h, env) do
    send(env, {:get, self(), h})

    receive do
      {:ok, value} -> value
    after
      200 -> IO.puts("env did not respond within 200ms")
    end
  end

  def environment(envars) do
    receive do
      {:put, key, val} -> environment(Map.put(envars, key, val))
      {:get, sender, key} -> send(sender, {:ok, Map.get(envars, key)})
      {:print} -> IO.inspect(envars)
    end

    environment(envars)
  end

  #############################################################################
  #                               BEGIN Builtins                              #
  #############################################################################
  def car([h | _]), do: h
  def cdr([_ | t]), do: t
  def eq?(a, b), do: a == b
  def print(str), do: IO.puts(str)
end