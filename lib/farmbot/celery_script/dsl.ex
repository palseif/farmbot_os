defmodule Farmbot.CeleryScript.DSL do
  @moduledoc """
  A handy domain specific language for quickly executing CeleryScript.
  """

  def compile_string(string) do
    case Code.string_to_quoted(string) do
      {:ok, {:__block__, _, args}} ->
        :ignore
      {:ok, {function_name, _meta, args}} ->
        module = Module.concat(["Farmbot", "CeleryScript", "AST", "Node", Macro.camelize(to_string(function_name))])
        if Code.ensure_loaded?(module) do
          maybe_compile_args(function_name, module, [args])
        else
          {:error, "Undefined command: #{inspect function_name}"}
        end
      {:error, _} = er -> er
    end
  end

  def maybe_compile_args(function_name, module, args) do
    if function_exported?(module, :compile_args, 1) do
      case apply(module, :compile_args, args) do
        {:error, _} = er -> er
        args when is_list(args) -> {module, :execute, args}
      end
    else
      {:error, "#{inspect function_name} does not export a serializer for args: #{inspect args}"}
    end
  end

  @doc "Compile arguments for the CeleryScript AST."
  @callback compile_args([term]) :: [Farmbot.CeleryScript.AST.t]
  @optional_callbacks compile_args: 1
end
