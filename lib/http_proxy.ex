defmodule HttpProxy do
  @moduledoc """
  HttpProxy is a simple http proxy.

  If you access to particular URL like `http://localhost:8080`, then the http_proxy forward the request to other URL based on configuration.

  # example
  1. Set configuration as the following in `config/config.exs`.

      use Mix.Config

      config :http_proxy,
        proxies: [
                   %{port: 4000,
                     to:   "http://google.com"},
                   %{port: 4001,
                     to:   "http://yahoo.com"}
                  ]
        record: false,
        play: true,
        export_path: "test/example",
        play_path: "test/data"
  2. Access to `http://localhost:4000` via Web Browser.
  3. The http_proxy forward to **http://google.com** .
  """

  use Application

  def start(_type, _args) do
    HttpProxy.Supervisor.start_link
  end
end
