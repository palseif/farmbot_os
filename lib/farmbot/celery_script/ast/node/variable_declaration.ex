defmodule Farmbot.CeleryScript.AST.Node.VariableDeclaration do
  @moduledoc false

  use Farmbot.CeleryScript.AST.Node
  allow_args [:label, :data_value]

  # used for defining variables at runtime.
  return_self()

end
