defmodule Farmbot.CeleryScript.AST.Slicer do
  @moduledoc """
  ORIGINAL IMPLEMENTATION HERE: https://github.com/FarmBot-Labs/Celery-Slicer
  Slices a CeleryScript AST into a flat tree.
  """
  alias Farmbot.CeleryScript.{Address, AST, Heap}

  @doc "Run the Slicer on the canonical AST format."
  def run(canonical, heap \\ nil)
  def run(%AST{} = canonical, heap) do
    heap || Heap.new()
    |> allocate(canonical, Heap.null)
    |> elem(1)
    |> Map.update(:entries, :error, fn(entries) ->
      Map.new(entries, fn({key, entry}) ->
        entry = Map.put(entry, Heap.body, Map.get(entry, Heap.body, Heap.null))
        entry = Map.put(entry, Heap.next, Map.get(entry, Heap.next, Heap.null))
        {key, entry}
      end)
    end)
  end

  @doc false
  def allocate(%Heap{} = heap, %AST{} = ast, %Address{} = parent_addr) do
    %Heap{here: addr} = heap = Heap.alot(heap, ast.kind)
    heap =
      heap
      |> Heap.put(Heap.parent(), parent_addr)
      |> iterate_over_body(ast, addr)
      |> iterate_over_args(ast, addr)
    {addr, heap}
  end

  @doc false
  def iterate_over_args(%Heap{} = heap, %AST{} = canonical_node, parent_addr) do
    keys = Map.keys(canonical_node.args)
    Enum.reduce(keys, heap, fn(key, %Heap{} = heap) ->
      case canonical_node.args[key] do
        %AST{} = another_node ->
          k = Heap.link <> to_string(key)
          {addr, heap} = allocate(heap, another_node, parent_addr)
          Heap.put(heap, parent_addr, k, addr)
        val -> Heap.put(heap, parent_addr, key, val)
      end
    end)
  end

  @doc false
  def iterate_over_body(%Heap{} = heap, %AST{} = canonical_node, parent_addr) do
    recurse_into_body(heap, canonical_node.body, parent_addr)
  end

  @doc false
  def recurse_into_body(heap, body, parent_addr, index \\ 0)
  def recurse_into_body(%Heap{} = heap, [body_item | rest], prev_addr, 0) do
    {my_heap_address, %Heap{} = heap} =
      heap
        |> Heap.put(prev_addr, Heap.body, Address.inc(prev_addr))
        |> allocate(body_item, prev_addr)
    heap
      |> Heap.put(prev_addr, Heap.next, Heap.null)
      |> recurse_into_body(rest, my_heap_address, 1)
  end

  def recurse_into_body(%Heap{} = heap, [body_item | rest], prev_addr, index) do
    {my_heap_address, %Heap{} = heap} = allocate(heap, body_item, prev_addr)
    heap = Heap.put(heap, prev_addr, Heap.next, my_heap_address)
    recurse_into_body(heap, rest, my_heap_address, index + 1)
  end

  def recurse_into_body(heap, [], _, _), do: heap
end
