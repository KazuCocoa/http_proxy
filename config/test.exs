use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://neko.com"}
            ],
  record: true,
  play: false,
  export_path: "example",
  play_path: "test/data/play_samples"
