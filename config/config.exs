use Mix.Config

config :http_proxy,
  proxy: %{port: 4000,
           path: [
             %{from: "", to: "http://yahoo.com"}
             ]
           }
