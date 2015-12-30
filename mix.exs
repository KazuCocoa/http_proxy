defmodule HttpProxy.Mixfile do
  use Mix.Project

  def project do
    [app: :http_proxy,
     version: "0.5.2",
     elixir: "~> 1.1",
     name: "ExHttpProxy",
     source_url: "https://github.com/KazuCocoa/http_proxy",
     description: "Multi port HTTP Proxy and support record/play request.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package,
     aliases: aliases,
     test_coverage: [tool: Coverex.Task],
     preferred_cli_env: [
          vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
        ]
    ]
  end

  def application do
    [
      applications: [:logger, :cowboy, :plug, :hackney],
      mod: {HttpProxy, []}
    ]
  end

  defp aliases do
    [
      proxy: ["run --no-halt"],
      test: ["test --cover"]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0.0" },
      {:plug, "~> 1.0.0"},
      {:hackney, "~> 1.4.4"},
      {:exjsx, "~> 3.2"},
      {:ex_parameterized, "~> 1.0", only: :test},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev},
      {:exvcr, "~> 0.6", only: :test},
      {:coverex, "~> 1.4.7", only: :test}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Kazuaki Matsuo"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/KazuCocoa/http_proxy"}
    ]
  end
end
