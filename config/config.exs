use Mix.Config

config :logger, :console,
  format: "\n$date $time [$level] $metadata$message",
  metadata: [:user_id],
  level: :info

import_config "#{Mix.env}.exs"
