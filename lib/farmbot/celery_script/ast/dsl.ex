defmodule Farmbot.CeleryScript.DSL do
  @moduledoc """
  A handy domain specific language for quickly executing CeleryScript.
  """

  def compile_string(string) do
    case Code.string_to_quoted(string, "celeryscript") do
      {:ok, {function_name, _meta, args}} ->
        module = Module.concat(["Farmbot", "CeleryScript", "AST", "Node", Macro.camelize(function_name)])
        if Code.ensure_loaded?(module) do
          args = apply(module, :compile_quoted, args)
          {module, :execute, [args | struct(Macro.Env)]}
        else
          {:error, "Undefined command: #{inspect function_name}"}
        end
      {:error, _} = er -> er
    end
  end

end
