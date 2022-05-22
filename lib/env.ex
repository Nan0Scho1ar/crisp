defmodule Crisp.Env do
  @default_envars %{
    car: &Crisp.Env.c_car/1,
    cdr: &Crisp.Env.c_cdr/1,
    eq?: &Crisp.Env.c_eq?/1,
    print: &Crisp.Env.c_print/1,
    +: &Crisp.Env.c_sum/1,
    -: &Crisp.Env.c_sub/1,
    *: &Crisp.Env.c_mul/1,
    /: &Crisp.Env.c_div/1,
    >: &Crisp.Env.c_gt/1,
    <: &Crisp.Env.c_lt/1,
    >=: &Crisp.Env.c_ge/1,
    <=: &Crisp.Env.c_le/1,
    ==: &Crisp.Env.c_eq/1,
    exit: &Crisp.Env.c_exit/1,
    begin: &Crisp.Env.c_begin/1,
    read: &Crisp.Env.c_read/1,
    list: &Crisp.Env.c_list/1
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

  # Compare each element to the next using given function
  def cmp(lst, func) do
    Enum.chunk_every(lst, 2, 1, :discard)
    |> Enum.all?(func)
  end

  #############################################################################
  #                               BEGIN Builtins                              #
  #############################################################################
  def c_exit(_), do: "SIGTERM"
  # 'car':     lambda x: x[0],
  def c_car([h | _]), do: h
  # 'cdr':     lambda x: x[1:],
  def c_cdr([_ | t]), do: t
  # 'eq?':     op.is_,
  def c_eq?([a | [b | _]]), do: a == b
  # 'print':   print,
  def c_print([str]), do: IO.puts(str)
  # '+':op.add,
  def c_sum(lst), do: Enum.reduce(lst, fn x, acc -> x + acc end)
  # '-':op.sub,
  def c_sub(lst), do: Enum.reduce(lst, fn x, acc -> x - acc end)
  # '*':op.mul,
  def c_mul(lst), do: Enum.reduce(lst, fn x, acc -> x * acc end)
  # '/':op.truediv,
  def c_div(lst), do: Enum.reduce(lst, fn x, acc -> x / acc end)
  # '>':op.gt,
  def c_gt(lst), do: cmp(lst, fn [a, b] -> a > b end)
  # '<':op.lt,
  def c_lt(lst), do: cmp(lst, fn [a, b] -> a < b end)
  # '>=':op.ge,
  def c_ge(lst), do: cmp(lst, fn [a, b] -> a >= b end)
  # '<=':op.le,
  def c_le(lst), do: cmp(lst, fn [a, b] -> a <= b end)
  # '=':op.eq,
  def c_eq(lst), do: cmp(lst, fn [a, b] -> a == b end)
  # 'abs':     abs,
  # 'append':  op.add,
  # 'apply':   lambda proc, args: proc(*args),
  # 'begin':   lambda *x: x[-1],
  def c_begin(lst), do: List.last(lst)
  # 'cons':    lambda x,y: [x] + y,
  # 'expt':    pow,
  # 'equal?':  op.eq,
  # 'length':  len,
  # 'list':    lambda *x: List(x),
  def c_list(lst), do: lst
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
  def c_read([h | _]), do: Crisp.Parse.parse(h) |> hd
end
