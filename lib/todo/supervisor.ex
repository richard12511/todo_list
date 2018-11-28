defmodule Todo.Supervisor do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, nil, name: :supervisor)

  def init(_) do
    children = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.SystemSupervisor, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end