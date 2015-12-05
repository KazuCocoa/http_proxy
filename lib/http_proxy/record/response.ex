defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @record Application.get_env :http_proxy, :record || false

  def record?, do: @record

  def record(conn) do
    Format.pretty_json(conn, true)
    |> HttpProxy.Utils.File.export(HttpProxyFile.get_export_path(conn.port), HttpProxy.Utils.File.filename(conn.path_info))

    conn
  end
end
