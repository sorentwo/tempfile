defmodule Tempfile.File do
  @moduledoc """
  The server responsible for generating random files with random
  prefixes and ensuring that those files are cleaned up when the
  calling process exits.
  """

  use GenServer

  @max_attempts 10
  @tmp_env_vars ~w(TMPDIR TMP TEMP)

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  @doc """
  Requests a random file to be created in the tempfile directory based on the
  provided filename. Files are placed in the environment specified temporary
  directory, or in the local `/tmp` directory otherwise.

  ## Example

      iex> Tempfile.random("temporary.txt")
      {:ok, "./tmp/temporary-12345-456789-3.txt"}
  """
  @spec random(String.t) :: {:ok, String.t} |
                            {:too_many_attempts, String.t, pos_integer}
  def random(filename) do
    GenServer.call(tempfile_server(), {:random, filename})
  end

  # Callbacks

  def init(:ok) do
    tmp = Enum.find_value(@tmp_env_vars, "/tmp", &System.get_env/1)
    dir = Path.join(tmp, "tempfile")

    File.mkdir_p!(dir)

    {:ok, {dir, %{}}}
  end

  def handle_call({:random, filename}, {pid, _ref}, {tmp, map}) do
    {:ok, paths, map} = find_paths(pid, map)
    {:ok, path, map} = open_random_file(filename, tmp, 0, pid, map, paths)

    {:reply, {:ok, path}, {tmp, map}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, {tmp, map} = state) do
    case Map.get(map, pid) do
      nil ->
        {:noreply, state}
      paths ->
        Enum.each(paths, &File.rm/1)
        {:noreply, {tmp, Map.delete(map, pid)}}
    end
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # Helpers

  defp tempfile_server do
    Process.whereis(__MODULE__)
  end

  defp find_paths(pid, map) do
    case Map.get(map, pid) do
      nil ->
        Process.monitor(pid)
        {:ok, [], Map.put(map, pid, [])}
      paths ->
        {:ok, paths, map}
    end
  end

  defp open_random_file(filename, tmp, attempts, pid, map, paths) when attempts < @max_attempts do
    path = unique_path(tmp, filename)

    case File.write(path, "", [:write, :raw, :exclusive, :binary]) do
      :ok ->
        {:ok, path, Map.update(map, pid, nil, &([path|&1]))}
      {:error, reason} when reason in [:eexist, :eaccess] ->
        open_random_file(filename, tmp, attempts + 1, pid, map, paths)
    end
  end
  defp open_random_file(_filename, tmp, attempts, _pid, _map, _paths) do
    {:too_many_attempts, tmp, attempts}
  end

  defp unique_path(tmp, filename) do
    {_mega, sec, micro} = :os.timestamp
    scheduler = :erlang.system_info(:scheduler_id)
    extname   = Path.extname(filename)
    basename  = Path.basename(filename, extname)

    "#{tmp}/#{basename}-#{sec}-#{micro}-#{scheduler}#{extname}"
  end
end
