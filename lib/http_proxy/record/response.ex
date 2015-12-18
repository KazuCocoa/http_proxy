defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @type t :: %Plug.Conn{}

  @spec record?() :: boolean
  def record?, do: Application.get_env :http_proxy, :record, false

  @spec record(t) :: t
  def record(conn) do
    export = HttpProxyFile.get_export_path(conn.port)
    filename = HttpProxyFile.filename(conn.path_info)

    Format.pretty_json(conn, true)
    |> HttpProxyFile.export(export, filename)

    conn
  end
end
