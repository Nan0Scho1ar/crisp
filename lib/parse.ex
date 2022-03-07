defmodule Crisp.Parse do
  import RegexCase

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
end
