defmodule Todo.Server do
  use GenServer

  def start, do: GenServer.start(Todo.Server, nil)
  def add_entry(pid, entry), do: GenServer.cast(pid, {:add_entry, entry})
  def entries(pid, date \\ nil), do: GenServer.call(pid, {:entries, date})

  def init(_), do: {:ok, Todo.List.new}
  def handle_cast({:add_entry, entry}, state), do: {:noreply, Todo.List.add_entry(state, entry)}
  def handle_call({:entries, date}, _, state), do: {:reply, Todo.List.entries(state, date), state}
end