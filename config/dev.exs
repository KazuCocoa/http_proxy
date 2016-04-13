use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               to:   "https://www.google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"}
            ],
  timeout: 20_000, # ms
  record: false,
  play: false,
  export_path: "test/example",
  play_path: "test/data"

config :logger, :console,
  format: "\n$date $time [$level] $metadata$message",
  metadata: [:user_id],
  level: :debug
