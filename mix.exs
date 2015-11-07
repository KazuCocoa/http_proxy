defmodule HttpProxy.Mixfile do
  use Mix.Project

  def project do
    [app: :http_proxy,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: aliases]
  end

  def application do
    [
      applications: [:logger, :cowboy, :plug, :hackney],
      mod: {HttpProxy, []}
    ]
  end

  defp aliases do
    [proxy: ["run --no-halt"]]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0.0" },
      {:plug, "~> 1.0.0"},
      {:hackney, "~> 1.3.2"},
      {:ex_parametarized, "~> 1.0.0", only: :test}
    ]

  end
end
