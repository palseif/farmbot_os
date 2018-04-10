defmodule Farmbot.CeleryScript.Shell.Evaluator do
  @moduledoc """
  """

  alias Farmbot.CeleryScript.DSL

  def init(command, server, leader, _opts) do
    old_leader = Process.group_leader
    Process.group_leader(self(), leader)

    command == :ack && :proc_lib.init_ack(self())

    state = %{}

    try do
      loop(server, state)
    after
      Process.group_leader(self(), old_leader)
    end
  end

  defp loop(server, state) do
    receive do
      {:eval, ^server, command, shell_state} ->
        case DSL.compile_string(command) do
          {:ok, {m, f, a}} -> apply(m, f, a)
          {:error, reason} -> IO.puts "Error parsing command: #{inspect reason}"
        end
        new_shell_state = %{shell_state | counter: shell_state.counter + 1}
        send(server, {:evaled, self(), new_shell_state})
        loop(server, state)
      {:done, ^server} ->
        :ok
      other ->
        IO.inspect(other, label: "Unknown message Farmbot CeleryScript command evaluator")
        loop(server, state)
    end
  end
end
