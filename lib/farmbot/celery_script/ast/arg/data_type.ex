defmodule Farmbot.CeleryScript.AST.Arg.DataType do
  @moduledoc false
  @behaviour Farmbot.CeleryScript.AST.Arg
  alias Farmbot.Asset.{
    Tool,
    Coordinate,
    Point
  }

  def decode("tool"), do: Tool
  def decode("coordinate"), do: Coordinate
  def decode("point"), do: Point
  def decode(val), do: {:error, "unknown data type: #{inspect val}"}

  def encode(Tool), do: "tool"
  def encode(Coordinate), do: "coordinate"
  def encode(Point), do: "point"
  def encode(data), do: {:error, "unknown data type: #{inspect data}"}
end
