defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder), do: GenServer.start(__MODULE__, db_folder)
  def store(pid, key, value), do: GenServer.cast(pid, {:store, key, value})
  def get(pid, key), do: GenServer.call(pid, {:get, key})

  def init(db_folder) do
#    File.mkdir_p(db_folder)
    IO.puts "Worker starting"
    {:ok, db_folder}
  end

  def handle_cast({:store, key, value}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(value))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case(file_name(db_folder, key) |> File.read) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end