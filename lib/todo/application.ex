defmodule Todo.Application do
  use Application

  def start(_, _) do
    Todo.SystemSupervisor.start_link()
  end
end