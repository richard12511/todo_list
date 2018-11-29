defmodule Todo.Server do
  use GenServer

  def start_link(list_name) do
    IO.puts("Starting todo server for #{list_name}")
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def add_entry(pid, entry), do: GenServer.cast(pid, {:add_entry, entry})
  def entries(pid, date \\ nil), do: GenServer.call(pid, {:entries, date})

  def whereis_name(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def init(name), do: {:ok, {name, Todo.Database.get(name) || Todo.List.new}}

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_call({:entries, date}, _, {_, todo_list} = state), do: {:reply, Todo.List.entries(todo_list, date), state}
  defp via_tuple(name), do: {:via, Todo.ProcessRegistry, {:n, :l, {:todo_server, name}}}
end