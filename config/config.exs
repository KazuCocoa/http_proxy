use Mix.Config

config :logger, :console,
  format: "\n$date $time [$level] $metadata$message",
  metadata: [:user_id],
  level: :info

config :http_proxy,
  schemes: [:http, :https]


import_config "#{Mix.env}.exs"
