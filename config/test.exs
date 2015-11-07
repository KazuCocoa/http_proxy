use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://neko.com"}
            ]
