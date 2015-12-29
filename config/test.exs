use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://neko.com"}
            ],
  timeout: 20_000, # ms
  record: false,
  play: true,
  export_path: "test/example",
  play_path: "test/data"

config :logger, :console,
  format: "\n$date $time [$level] $metadata$message",
  metadata: [:user_id],
  level: :warn
