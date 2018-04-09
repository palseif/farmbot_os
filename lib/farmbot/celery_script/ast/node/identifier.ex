defmodule Farmbot.CeleryScript.AST.Node.Identifier do
  @moduledoc false

  use Farmbot.CeleryScript.AST.Node
  allow_args [:label]

  return_self()
end
