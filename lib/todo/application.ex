defmodule Todo.Application do
  use Application

  def start(_, _) do
    response = Todo.SystemSupervisor.start_link()
#    Todo.Web.start_server()
    response
  end
end