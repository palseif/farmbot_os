defmodule Farmbot.CeleryScript.AST.Node.ParameterDeclaration do
  @moduledoc false

  use Farmbot.CeleryScript.AST.Node
  allow_args [:label, :data_type]
  return_self()
end
