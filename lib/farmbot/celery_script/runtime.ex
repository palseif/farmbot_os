defmodule Farmbot.CeleryScript.Runtime do
  @moduledoc "CeleryScript Virtual Machine runtime."
  alias Farmbot.CeleryScript.{Address, AST, Heap, Runtime}
  alias Runtime.{Instruction, Utils}
  import Utils


  defmodule SymbolEntry do
    @moduledoc "Data stored on a StackFrame."
    defstruct [
      :type,
      :value,
      :label,
    ]
  end

  defmodule StackFrame do
    @moduledoc "Individual frame on the Stack."
    defstruct [
      locals: %{}
    ]
  end

  defmodule State do
    defstruct [
      heap: nil,
      stack: [],
      sp: Address.new(0),
      pc: Address.new(1)
    ]
  end

  defimpl Inspect, for: State do
    def inspect(%State{} = state, _) do
      "<CeleryMachine PC: #{inspect state.pc} SP: #{inspect state.sp}>"
    end
  end

  @doc "Execute an AST until complete."
  def run(%AST{} = ast) do
    initial_state = init(ast)
    do_run(initial_state)
  end

  defp do_run(state) do
    case execute(state) do
      %State{pc: %Address{value: 0}} = final_state ->
        vm_debug("Program Counter: 0")
        final_state
      %State{} = next_state  ->
        vm_debug("going to tick again.")
        do_run(next_state)
    end
  end

  @doc "Initialize the Machine's state."
  def init(ast) do
    vm_debug("init")
    heap = Farmbot.CeleryScript.AST.Slicer.run(ast)
    struct(State, [heap: heap])
  end

  @doc "One single tick."
  def execute(%State{} = state) do
    pc = state.pc
    vm_debug("tick: #{inspect pc}")
    instruction = state.heap[pc] || raise "Stack Overflow"
    Instruction.apply(state, instruction)
  end
end
