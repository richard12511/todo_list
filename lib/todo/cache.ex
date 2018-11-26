defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting :todo_cache"
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(list_name) do
    GenServer.call(:todo_cache, {:server_process, list_name})
  end

  def init(_) do
#    Todo.Database.start_link()
    {:ok, Map.new}
  end

  def handle_call({:server_process, list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, list_name) do
      {:ok, todo_server} -> {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(list_name)
        {:reply, new_server, Map.put(todo_servers, list_name, new_server)}
    end
  end
end