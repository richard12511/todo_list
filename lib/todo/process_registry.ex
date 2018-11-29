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

  def whereis_name(key) do
    case :ets.lookup(:ets_process_registry, key) do
      [{^key, pid}] -> pid
      _ -> :undefined
    end
  end

  def register_name(key, pid), do: GenServer.call(:process_registry, {:register_name, key, pid})
  def unregister_name(key), do: GenServer.cast(:process_registry, {:unregister_name, key})

  #server
  def init(_) do
    :ets.new(:ets_process_registry, [:named_table])
    {:ok, nil}
  end

  def handle_call({:register_name, key, pid}, _, _) do
    case whereis_name(key) do
      :undefined ->
        :ets.insert(:ets_process_registry, {key, pid})
        Process.monitor(pid)
        {:reply, :yes, nil}
      _ ->
        {:reply, :no, nil}
    end
  end

  def handle_cast({:unregister_name, key}, _) do
    :ets.match_delete(:ets_process_registry, key)
    {:noreply, nil}
  end

  def handle_info({:DOWN, _, :process, pid, _}, _) do
    :ets.match_delete(:ets_process_registry, {:_, pid})
    {:noreply, nil}
  end

end