use Mix.Config

import_config "#{Mix.env}.exs"

config :dogma,
  rule_set: Dogma.RuleSet.All,
  override: %{
    LineLength => [ max_length: 128 ]
  }
