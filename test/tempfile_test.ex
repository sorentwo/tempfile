defmodule TempfileTest do
  use ExUnit.Case

  test "random/1 is available as a top level function" do
    {:ok, path} = Tempfile.random("testfile.txt")

    assert path
  end
end
