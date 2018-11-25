defmodule Todo.Database do
  use GenServer
  @db_folder "./persist"

  def start_link() do
    IO.puts("Starting database server")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, value) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, value)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end

#  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
  defp start_workers() do
    for i <- 1..3, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {i - 1, pid}
    end
  end
end