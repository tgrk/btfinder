defmodule BTFinder.MixProject do
  use Mix.Project

  def project do
    [
      app: :btfinder,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crypto, :logger],
      mod: {BTFinder.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex2ms, "~> 1.5"}]
  end
end
