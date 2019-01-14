defmodule HttpProxy do
  @moduledoc """
  HttpProxy is a simple http proxy.

  If you access to particular URL like `http://localhost:8080`, then the http_proxy forward the request to other URL
  based on configuration.

  HttpProxy supports two features.

  1. HttpProxy supports a multi-port proxy.
  2. HttpProxy supports play/record proxied requests.

  Multiport proxy means that the proxy receives request with particular port and the proxy send request to other address.
  And you can set the feature against several mulatiple port.

  # Multiport proxy

  For example, you set configuratio like the followings in your project and do `mix proxy`. Then the proxy send request to
  "http://google.com" if anyone snds to "http://localhost:4000". And the proxy send request to "http://yahoo.com" if anyone
  send request to "http://localhost:4001".

  ## example
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
      - or access to  `http://localhost:4001`.
  3. The http_proxy forward to **http://google.com** .
      - or forward to  **http://yahoo.com**

  # Play/Record proxied request.

  If you set `record: true` in the configuration, the proxy export request into local file as JSON.
  You can export requests in particular path which is set as `export_path: "test/example"`. Default is "default".

  If you set `play: true` in the configuration, the proxy read mapping files and reply them when anyone accesses
  to the proxy via particular ports.

  Please read `test/data/mappings/*.json` if you would like to know the format of playing the reqponse.
  """

  use Application
  alias HttpProxy.Supervisor, as: HttpProxySup

  @spec start(:normal, []) :: {:ok, pid}
  def start(_type, _args) do
    HttpProxySup.start_link()
  end

  @doc """
  Stopt http_proxy.
  """
  @spec stop :: :ok | {:error, term}
  def stop do
    Application.stop(:ranch)
    Application.stop(:cowlib)
    Application.stop(:cowboy)
    Application.stop(:idna)
    Application.stop(:mimerl)
    Application.stop(:certifi)
    Application.stop(:hackney)
    Application.stop(:plug)
    Application.stop(:http_proxy)
  end

  @doc """
  Start http_proxy.
  If the proxy is already running, return `{:error, {:already_started, :http_proxy}}`
  """
  @spec start() :: :ok | {:error, term}
  def start do
    Application.start(:ranch)
    Application.start(:cowlib)
    Application.start(:cowboy)
    Application.start(:idna)
    Application.start(:mimerl)
    Application.start(:certifi)
    Application.start(:hackney)
    Application.start(:plug)
    Application.start(:http_proxy)
  end
end
