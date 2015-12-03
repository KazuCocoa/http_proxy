defmodule HttpProxy.Record.Response do
  @moduledoc false

  alias HttpProxy.Format

  def record(conn) do
    filename = HttpProxy.Utils.File.filename conn
    Format.pretty_json(conn, true)
    |> HttpProxy.Utils.File.export(filename, conn)

    conn
  end
end
