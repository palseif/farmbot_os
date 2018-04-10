defmodule Farmbot.CeleryScript.AST do
  @moduledoc """
  Handy functions for turning various data types into Farbot Celery Script
  Ast nodes.
  """

  @typedoc "Arguments to a Node."
  @type args :: map

  @typedoc "Body of a Node."
  @type body :: [t]

  @typedoc "Kind of a Node."
  @type kind :: module

  @typedoc "AST node."
  @type t :: %__MODULE__{
    kind: kind,
    args: args,
    body: body,
    comment: binary
  }

  # AST struct.
  defstruct [:kind, :args, :body, :comment]

  @doc "Encode a AST back to a map."
  # def encode(%__MODULE__{kind: mod, args: args, body: body, comment: comment}) do
  #   case mod.encode_args(args) do
  #     {:ok, encoded_args} ->
  #       case encode_body(body) do
  #         {:ok, encoded_body} ->
  #           {:ok, %{kind: kind_to_string(mod), args: encoded_args, body: encoded_body, comment: comment}}
  #         {:error, _} = err -> err
  #       end
  #     {:error, _} = err -> err
  #   end
  # end

  def encode(thing) do
    {:error, "#{inspect thing} is not an AST node for encoding."}
  end

  @doc "Encode a list of asts."
  def encode_body(body, acc \\ [])

  def encode_body([ast | rest], acc) do
    case encode(ast) do
      {:ok, encoded} -> encode_body(rest, [encoded | acc])
      {:error, _} = err -> err
    end
  end

  def encode_body([], acc), do: {:ok, Enum.reverse(acc)}

  @doc "Try to decode anything into an AST struct."
  def decode(arg1)

  def decode(binary) when is_binary(binary) do
    case Poison.decode(binary, keys: :atoms) do
      {:ok, map}  -> decode(map)
      {:error, :invalid, _} -> {:error, :unknown_binary}
      {:error, _} -> {:error, :unknown_binary}
    end
  end

  def decode(list) when is_list(list), do: decode_body(list)

  def decode(%{__struct__: _} = herp) do
    Map.from_struct(herp) |> decode()
  end

  def decode(%{"kind" => kind, "args" => str_args} = str_map) do
    args = Map.new(str_args, &str_to_atom(&1))
    case decode(str_map["body"] || []) do
      {:ok, body} ->
        %{kind: kind,
          args: args,
          body: body,
          comment: str_map["comment"]}
        |> decode()
      {:error, _} = err -> err
    end
  end

  def decode(%{kind: kind, args: %{}} = map) do
    k = str_to_atom(kind)
    do_decode(k, %{map | kind: k})
  end

  defp do_decode(kind, %{kind: kind, args: args} = map) do
    case decode_body(map[:body] || []) do
      {:ok, body} ->
        case decode_args(args) do
          {:ok, decoded} ->
            opts = [kind: kind,
                    args: decoded,
                    body: body,
                    comment: map[:comment]]
            val = struct(__MODULE__, opts)
            {:ok, val}
          {:error, reason} -> {:error, {kind, reason}}
        end
      {:error, _} = err -> err
    end
  end

  # decode a list of ast nodes.
  defp decode_body(body, acc \\ [])
  defp decode_body([node | rest], acc) do
    case decode(node) do
      {:ok, re} -> decode_body(rest, [re | acc])
      {:error, _} = err -> err
    end
  end

  defp decode_body([], acc), do: {:ok, Enum.reverse(acc)}

  # todo make this more readable l o l.
  defp decode_args(args) when is_map(args) do
    case Enum.reduce(args, %{}, fn({key, val}, acc) ->
      if is_map(acc) do
        if match?(%{kind: _}, val) do
          case decode(val) do
            {:ok, more_ast} -> Map.put(acc, key, more_ast)
            {:error, _} = er -> er
          end
        else
          Map.put(acc, key, val)
        end
      else
        acc
      end
    end) do
      map when is_map(map) -> {:ok, map}
      {:error, _} = err -> err
    end
  end

  defp str_to_atom({key, value}) do
    k = str_to_atom(key)
    cond do
      is_map(value)  -> {k, Map.new(value, &str_to_atom(&1))}
      is_list(value) -> {k, Enum.map(value, fn(sub_str_map) -> Map.new(sub_str_map, &str_to_atom(&1)) end)}
      is_binary(value) -> {k, value}
      is_atom(value) -> {k, value}
      is_number(value) -> {k, value}
    end
  end

  defp str_to_atom(key) when is_binary(key) do
    String.to_atom(key)
  end

  defp str_to_atom(key) when is_atom(key) do
    key
  end

end
