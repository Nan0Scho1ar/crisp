defmodule Crisp.Env do
  @default_envars %{
    car: &Crisp.Env.car/1,
    cdr: &Crisp.Env.cdr/1,
    eq?: &Crisp.Env.eq?/2,
    print: &Crisp.Env.print/1,
    +: &Crisp.Env.sum/1,
    -: &Crisp.Env.sub/1,
    exit: &Crisp.Env.exit/1
  }

  def start do
    Task.start(fn -> environment(@default_envars) end)
  end

  def start_link do
    Task.start_link(fn -> environment(@default_envars) end)
  end

  def start_link(envars) do
    Task.start_link(fn -> environment(envars) end)
  end

  def clone(env) do
    send(env, {:clone, self()})

    receive do
      {:ok, value} -> value
    after
      200 -> IO.puts("env did not respond within 200ms")
    end
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
      {:dump, sender} -> send(sender, {:ok, envars})
      {:overwrite, new_envars} -> environment(new_envars)
      {:put, key, val} -> environment(Map.put(envars, key, val))
      {:get, sender, key} -> send(sender, {:ok, Map.get(envars, key)})
      {:clone, sender} -> send(sender, {:ok, start_link(envars)})
      {:print} -> IO.inspect(envars)
    end

    environment(envars)
  end

  #############################################################################
  #                               BEGIN Builtins                              #
  #############################################################################
  def exit(_), do: "SIGTERM"
  # 'car':     lambda x: x[0],
  def car([h | _]), do: h
  # 'cdr':     lambda x: x[1:],
  def cdr([_ | t]), do: t
  # 'eq?':     op.is_,
  def eq?(a, b), do: a == b
  # 'print':   print,
  def print([str]), do: IO.puts(str)

  # '+':op.add,
  def sum(lst, acc \\ 0)
  def sum([h], acc), do: acc + h
  def sum([h | t], acc), do: sum(t, acc + h)

  # '-':op.sub,
  def sub([h | t]), do: sub(t, h)
  def sub([h], acc), do: acc - h
  def sub([h | t], acc), do: sub(t, acc - h)
  # '*':op.mul,
  # '/':op.truediv,
  # '>':op.gt,
  # '<':op.lt,
  # '>=':op.ge,
  # '<=':op.le,
  # '=':op.eq,
  # 'abs':     abs,
  # 'append':  op.add,
  # 'apply':   lambda proc, args: proc(*args),
  # 'begin':   lambda *x: x[-1],
  # 'cons':    lambda x,y: [x] + y,
  # 'expt':    pow,
  # 'equal?':  op.eq,
  # 'length':  len,
  # 'list':    lambda *x: List(x),
  # 'list?':   lambda x: isinstance(x, List),
  # 'map':     map,
  # 'max':     max,
  # 'min':     min,
  # 'not':     op.not_,
  # 'null?':   lambda x: x == [],
  # 'number?': lambda x: isinstance(x, Number),
  # 'procedure?': callable,
  # 'round':   round,
  # 'symbol?': lambda x: isinstance(x, Symbol),
end
