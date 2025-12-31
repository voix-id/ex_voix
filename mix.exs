defmodule ExVoix.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_voix,
      version: "0.2.6",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "ExVOIX: VOIX framework implementation using Phoenix.LiveView.",
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Iskandar Rizki"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/onprem-vip/ex_voix",
        # "Docs" => "hexdocs.pm"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:anubis_mcp, "~> 0.17.0"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
