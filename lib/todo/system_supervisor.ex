defmodule Todo.SystemSupervisor do
  use Supervisor

  def start_link do
    IO.puts("Starting #{__MODULE__}")
    Supervisor.start_link(__MODULE__, nil, name: :system_supervisor)
  end

  def init(_) do
    processes = [
      supervisor(Todo.Database, ["./persist/"]),
      supervisor(Todo.ServerSupervisor, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end