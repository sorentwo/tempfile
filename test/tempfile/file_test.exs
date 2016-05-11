defmodule Tempfile.FileTest do
  use ExUnit.Case

  alias Tempfile.File, as: Temp

  test "random files are returned and removed on exit" do
    parent = self()

    {pid, ref} = spawn_monitor fn ->
      {:ok, path} = Temp.random("testfile.png")
      send parent, {:path, path}
      File.open!(path)
    end

    path = receive do
      {:path, path} -> path
    after
      1_000 -> flunk "didn't get a path"
    end

    assert path =~ ~r/testfile.*\.png$/

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} ->
        {:ok, _} = Temp.random("testfile.png")
        refute File.exists?(path)
    end
  end
end
