defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format
  alias HttpProxy.Utils.File, as: HttpProxyFile

  def record(conn) do
    Format.pretty_json(conn, true)
    |> HttpProxy.Utils.File.export(HttpProxyFile.get_export_path(conn.port), HttpProxy.Utils.File.filename(conn.path_info))

    conn
  end
end
