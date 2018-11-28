defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting :todo_cache"
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(list_name) do
    case Todo.Server.whereis_name(list_name) do
      :undefined ->  GenServer.call(:todo_cache, {:server_process, list_name})
      pid -> pid
    end
  end

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:server_process, list_name}, _, _todo_servers) do
    case Todo.Server.whereis_name(list_name) do
      :undefined ->
        {:ok, new_server} = Todo.ServerSupervisor.start_child(list_name)
        {:reply, new_server, %{}}
      pid -> {:reply, pid, %{}}
    end
  end
end