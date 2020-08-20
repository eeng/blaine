defmodule WatchLater.MixProject do
  use Mix.Project

  def project do
    [
      app: :watch_later,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WatchLater.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3.0"},
      {:jason, "~> 1.2"},
      {:hackney, "~> 1.10"},
      {:exconstructor, "~> 1.1"}
    ]
  end
end
