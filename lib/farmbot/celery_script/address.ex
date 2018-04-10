defmodule Farmbot.CeleryScript.Address do
  @moduledoc "Address on the heap or vm."

  defstruct [:value]

  @doc "New heap address."
  def new(num) when is_integer(num) do
    %__MODULE__{value: num}
  end

  @doc "Increment an address."
  def inc(%__MODULE__{value: num}) do
    %__MODULE__{value: num + 1}
  end

  @doc "Decrement an address."
  def dec(%__MODULE__{value: num}) do
    %__MODULE__{value: num - 1}
  end

  @doc "Replace an address value."
  def eq(%__MODULE__{value: _num}, val) do
    %__MODULE__{value: val}
  end

  @doc false
  def unquote(:+)(%__MODULE__{} = adr) do
    inc(adr)
  end

  @doc false
  def unquote(:-)(%__MODULE__{} = adr) do
    dec(adr)
  end

  def unquote(:=)(%__MODULE__{} = adr, val) do
    eq(adr, val)
  end

  defimpl Inspect, for: __MODULE__ do
    def inspect(%{value: val}, _), do: "Address(#{val})"
  end
end
