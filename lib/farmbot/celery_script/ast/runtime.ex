# defmodule Farmbot.CeleryScript.Runtime do
#
#   defmodule SymbolEntry do
#     defstruct [
#       :type,
#       :value,
#       :label,
#     ]
#   end
#
#   defmodule StackFrame do
#     defstruct [
#       :locals, #symbol table
#     ]
#   end
#
#   defmodule State do
#     defstruct [
#       :flat_tree, # output of Slicer. # rename back to heap.
#       :stack,
#       :pc, # Current address.
#     ]
#   end
#
#   def init(ast) do
#     flat_tree = Farmbot.CeleryScript.AST.Slicer.run(ast)
#     %State{
#       flat_tree: flat_tree,
#       stack: [],
#       sp: 1,
#       pc: 1
#     }
#     |> execute()
#   end
#
#   def execute(%{pc: 0}) do
#     # done!
#   end
#
#   def execute(state) do
#     pc = state.pc
#     current_thing = state.flat_tree[pc]
#     new_state = current_thing.kind.execute(state)
#   end
#
#   def resolve_variable(name, state) do
#     climb state.stack until local.name == name or raise UnboundVariable
#   end
#
#   def push_variable(name, value, state) do
#     # wrong we need to use the stack pointer
#     %{state | stack: [StackFrame.new(name, value) | state.stack]}
#   end
#
# end
