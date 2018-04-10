defmodule Farmbot.CeleryScript.Runtime.Instruction do
  alias Farmbot.CeleryScript.{Address, Runtime}
  alias Runtime.{State, Utils}
  import Utils

  def apply(state, %{__kind: name} = instruction) do
    vm_debug("instruction: #{name}")
    case name do
      # Sequence jumps into it's own body.
      :sequence ->
        %{state | pc: instruction.__body}
      _ ->
        %{state | pc: instruction.__next}
    end
  end
end
