defmodule Crisp do
  import RegexCase

  def environment(envars) do
    receive do
      {:put, key, val} -> environment(Map.put(envars, key, val))
      {:get, sender, key} -> send(sender, {:ok, Map.get(envars, key)})
      {:print} -> IO.inspect(envars)
    end

    environment(envars)
  end

  def tokenize_string(str), do: str |> String.split("") |> tokenize

  def tokenize(char_list, atom \\ "", accumulator \\ [], mode \\ :default)

  def tokenize([], _, acc, _) do
    acc
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.reverse()
  end

  def tokenize([h | t], atom, acc, :default) do
    case h do
      "\"" -> tokenize(t, "", ["STRING" | acc], :string)
      " " -> tokenize(t, "", [atom | acc], :default)
      "\n" -> tokenize(t, "", [atom | acc], :default)
      "\t" -> tokenize(t, "", [atom | acc], :default)
      "(" -> tokenize(t, "", [h | acc], :default)
      ")" -> tokenize(t, "", [h | [atom | acc]], :default)
      _ -> tokenize(t, atom <> h, acc, :default)
    end
  end

  def tokenize([h | t], atom, acc, :string) do
    case h do
      "\"" -> tokenize(t, "", [atom | acc], :default)
      _ -> tokenize(t, atom <> h, acc, :string)
    end
  end

  # Build the abstract syntax tree using list of tokens
  def build_ast(tokens, accumulator \\ [])
  def build_ast([], []), do: raise("unexpected EOF")
  def build_ast([h | _], []) when h == ")", do: raise("unexpected )")
  def build_ast([], acc), do: acc
  # TODO use [head | tail] for acc (reverse input)
  def build_ast([token | rest], acc) do
    case token do
      "(" ->
        {result, remain} = build_ast(rest)
        build_ast(remain, acc ++ [result])

      ")" ->
        {acc, rest}

      "STRING" ->
        build_ast(tl(rest), acc ++ [hd(rest)])

      _ ->
        build_ast(rest, acc ++ [atomize(token)])
    end
  end

  def atomize(a) do
    regex_case a do
      ~r/^[0-9]+$/ -> String.to_integer(a)
      ~r/^[0-9]+\.[0-9]+$/ -> String.to_float(a)
      ~r/.*/ -> String.to_atom(a)
    end
  end

  def parse(str), do: str |> tokenize_string |> build_ast

  def eval(str, env), do: str |> parse |> eval_ast(env)

  def eval_ast(ast, env) do
    [token | _] = ast

    cond do
      is_atom(token) ->
        send(env, {:get, self(), token})

        receive do
          {:ok, value} ->
            value
        after
          200 -> IO.puts("env did not respond within 200ms")
        end

      is_integer(token) ->
        token

      is_bitstring(token) ->
        token

      is_float(token) ->
        token

      is_list(token) ->
        [func | args] = token

        case func do
          :if ->
            [test | [a | [b | _]]] = args

            if eval_ast([test], env) do
              eval_ast([a], env)
            else
              eval_ast([b], env)
            end

          :define ->
            [key | val] = args
            send(env, {:put, key, eval_ast(val, env)})

          :list ->
            Enum.map(args, fn a -> eval_ast([a], env) end)

          :begin ->
            Enum.map(args, fn a -> eval_ast([a], env) end)
            |> List.last()

          :exit ->
            "SIGTERM"

          _ ->
            function = eval_ast([func], env)
            arguments = Enum.map(args, fn a -> eval_ast([a], env) end)
            apply(function, arguments)
        end
    end
  end

  def start_env do
    envars = %{
      begin: fn x -> Enum.last(x) end,
      car: fn [h | _] -> h end,
      cdr: fn [_ | t] -> t end,
      eq?: fn a, b -> a == b end,
      print: fn str -> IO.puts(str) end
    }

    env = spawn(Crisp, :environment, [envars])
  end

  def start_repl do
    env = start_env()
    repl(env)
  end

  def repl(env) do
    result =
      IO.gets("Crisp> ")
      |> eval(env)

    unless result == "SIGTERM" do
      repl(env)
    end
  end
end
