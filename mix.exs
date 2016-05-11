defmodule Tempfile.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :tempfile,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,

     description: description,
     package: package,

     deps: deps,

     name: "Tempfile",
     source_url: "https://github.com/sorentwo/tempfile",
     docs: [source_ref: "v#{@version}",
            extras: ["README.md"],
            main: "Tempfile"]]
  end

  def application do
    [applications: [:logger],
     mod: {Tempfile, []}]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev},
     {:earmark, "~> 0.2", only: :dev},
     {:credo, "~> 0.3", only: :dev}]
  end

  defp description do
    """
    Auto cleaning and randomly named temporary files
    """
  end

  defp package do
    [maintainers: ["Parker Selbert"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sorentwo/tempfile"},
     files: ~w(lib priv mix.exs README.md CHANGELOG.md)]
  end
end
