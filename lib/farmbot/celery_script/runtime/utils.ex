defmodule Farmbot.CeleryScript.Runtime.Utils do
  def vm_debug(str) do
    IO.puts "[CS VM #{inspect self()}]: #{str}"
  end
end
