defmodule Todo.List do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      fn(entry, acc) ->
        add_entry(acc, entry)
      end
    )
  end

  def new_from_file(path) do
    File.stream!(path)
    |> Stream.map(fn line -> String.replace(line, "\n", "") end)
    |> Stream.map(fn line -> line_to_entry(line) end)
    |> new

  end

  def add_entry(%Todo.List{entries: entries, auto_id: auto_id} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %Todo.List{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def add_entry(todo_list, entry) do
    IO.puts("Todo.List is invalid")
    IO.inspect(todo_list)
  end

  def entries(%Todo.List{entries: entries} = todo_list, nil) do
    entries
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def entries(%Todo.List{entries: entries}, date) do
    IO.puts("date is not nil")
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def all_entries(%Todo.List{entries: entries}) do
    entries
  end

  def update_entry(%Todo.List{entries: entries} = todo_list, entry_id, updater_fun) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  defp line_to_entry(line) do
    line_list = String.split(line, ",")
    date_str = Enum.at(line_list, 0)
    title_str = Enum.at(line_list, 1)

    %{date: parse_date(date_str), title: title_str}
  end

  defp parse_date(date) do
    date_list = String.split(date, "/")
    year = date_list |> Enum.at(0) |> String.to_integer
    month = date_list |> Enum.at(1) |> String.to_integer
    day = date_list |> Enum.at(2) |> String.to_integer

    {year, month, day}
  end
end