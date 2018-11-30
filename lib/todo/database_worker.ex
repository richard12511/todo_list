defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder, worker_id) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  def store(worker_id, key, value), do: GenServer.call(via_tuple(worker_id), {:store, key, value})
  def get(worker_id, key), do: GenServer.call(via_tuple(worker_id), {:get, key})

  def init(db_folder) do
    [node_name, _] = "#{node}" |> String.split("@")
    db_folder = "#{db_folder}/#{node_name}/"
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_call({:store, key, value}, _, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(value))

    {:reply, :ok, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case(file_name(db_folder, key) |> File.read) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"

  defp via_tuple(worker_id) do
    {:via, :gproc, {:n, :l, {:database_worker, worker_id}}}
  end
end