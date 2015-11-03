use Mix.Config

config :http_proxy,
  proxy: %{port: 4000,
           default_to: "http://google.com",
           path: [
               %{from: "", to: "http://yahoo.com"},
               %{from: "neko", to: "http://yahoo.co.jp"}
             ]
           }
