defmodule Farmbot.CeleryScript.AST.Node.ScopeDeclaration do
  @moduledoc false
  use Farmbot.CeleryScript.AST.Node
  allow_args []

  # takes body of either ParamaterDecleration or VariableDecleration

  def execute(args, body, env) do
    env = mutate_env(env)
    # implementation of allocating data on the stack.
    {:ok, env}
  end
end
