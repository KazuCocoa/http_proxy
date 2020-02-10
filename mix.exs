defmodule HttpProxy.Mixfile do
  use Mix.Project

  def project do
    [app: :http_proxy,
     version: "1.4.0",
     elixir: "~> 1.6",
     name: "ExHttpProxy",
     source_url: "https://github.com/KazuCocoa/http_proxy",
     description: "Multi port HTTP Proxy and support record/play request.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HttpProxy, []}
    ]
  end

  defp aliases do
    [
      proxy: ["run --no-halt"]
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:hackney, "1.15.2"},
      {:exjsx, "~> 4.0.0", runtime: false},
      {:earmark, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.13", only: :dev, runtime: false},
      {:ex_parameterized, "~> 1.0", only: :test, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.3", only: :dev, runtime: false},
      {:stream_data, "~> 0.1", only: :test}
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

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "README.md"
      ]
    ]
  end
end
