use Mix.Config

config :http_proxy,
  proxy: [
    %{port: 4000, to: "http://yahoo.com"},
    %{port: 4001, to: "http://cookpad.com"}
  ]
