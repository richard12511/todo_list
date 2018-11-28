defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]
  use GenServer

  def start_link do
    IO.puts("Starting process registry")
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def register_name(key, pid), do: GenServer.call(:process_registry, {:register_name, key, pid})
  def whereis_name(key), do: GenServer.call(:process_registry, {:whereis_name, key})
  def unregister_name(key), do: GenServer.cast(:process_registry, {:unregister_name, key})

  def init(_), do: {:ok, Map.new}

  def handle_call({:register_name, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}
      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _, process_registry) do
    {:reply, Map.get(process_registry, key, :undefined), process_registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  defp deregister_pid(registry, pid_to_remove) do
    registry
    |> Enum.filter(fn {_key, pid} -> pid != pid_to_remove end)
    |> Enum.into(%{})
  end

end