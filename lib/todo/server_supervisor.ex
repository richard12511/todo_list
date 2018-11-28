defmodule Todo.ServerSupervisor do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, nil, name: :todo_server_supervisor)
  def start_child(name), do: Supervisor.start_child(:todo_server_supervisor, [name])

  def init(_) do
    children = [worker(Todo.Server, [])]
    supervise(children, strategy: :simple_one_for_one)
  end
end