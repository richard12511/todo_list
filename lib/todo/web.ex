#defmodule Todo.Web do
#  use Plug.Router
#
#  plug :match
#  plug :dispatch
#
#  post "/add_entry" do
#    conn
#    |> Plug.Conn.fetch_params()
#    |> add_entry()
#    |> respond()
#  end
#
#  get "/entries" do
#    conn
#    |> Plug.Conn.fetch_params()
#    |> get_entries()
#    |> respond()
#  end
#
#  def start_server do
#    Plug.Adapters.Cowboy.http(__MODULE__, nil, port: 5454)
#  end
#
#  defp add_entry(conn) do
#    conn.params["list"]
#    |> Todo.Cache.server_process()
#    |> Todo.Server.add_entry(%{date: parse_date(conn.params["date"]), title: conn.params["title"]})
#
#    Plug.Conn.assign(conn, :response, "OK")
#  end
#
#  defp get_entries(conn) do
#    entries = conn.params["list"]
#    |> Todo.Cache.server_process()
#    |> Todo.Server.entries()
#
#    Plug.Conn.assign(conn, :response, entries)
#  end
#
#  defp respond(conn) do
#    conn
#    |> Plug.Conn.put_resp_content_type("text/plain")
#    |> Plug.Conn.send_resp(200, conn.assigns[:response])
#  end
#end