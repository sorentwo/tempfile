defmodule Tempfile do
  use Application

  def start(_, _) do
    import Supervisor.Spec

    children = [
      worker(Tempfile.File, [])
    ]

    options = [strategy: :one_for_one, name: Tempfile.Supervisor]

    Supervisor.start_link(children, options)
  end

  defdelegate random(filename), to: Tempfile.File
end
