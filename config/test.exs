use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               default_to: "http://google.com",
               path: [
                 %{from: "", to: "http://yahoo.com"},
                 %{from: "neko", to: "http://yahoo.co.jp"}
               ]
             },
             %{port: 8081,
               default_to: "http://neko.com",
               path: [
                 %{from: "", to: "http://yahoo.com"},
                 %{from: "neko", to: "http://yahoo.co.jp"}
               ]
             }
            ]
