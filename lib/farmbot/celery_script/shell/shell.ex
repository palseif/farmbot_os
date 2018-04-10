defmodule Farmbot.CeleryScript.Shell do
  alias Farmbot.CeleryScript.Shell.Server

  @doc """
  This is the callback invoked by Erlang's shell when someone presses Ctrl+G
  and types `s #{__MODULE__}` or `s celeryscript`.
  """
  def start(opts \\ [], mfa \\ {__MODULE__, :dont_display_result, []}) do
    spawn(fn ->
      # The shell should not start until the system is up and running.
      case :init.notify_when_started(self()) do
        :started -> :ok
        _        -> :init.wait_until_started()
      end

      :io.setopts(Process.group_leader, binary: true, encoding: :unicode)

      Server.start(opts, mfa)
    end)
  end

  def dont_display_result, do: "don't display result"
end

defmodule :celeryscript do
  defdelegate start, to: Farmbot.CeleryScript.Shell
end
