defmodule HttpProxy.Utils.File do
  @moduledoc false

  defstruct export_path: Application.get_env(:http_proxy, :export_path) || "default",
            response_files: "__files",
            mapping_files: "mappings"
            
  alias HttpProxy.Utils.File, as: HttpProxyFile

  def gen_export_path, do: %HttpProxyFile{}.export_path
  def gen_export_path(conn), do: %HttpProxyFile{}.export_path <> "/" <> Integer.to_string(conn.port)
  def response_path, do: %HttpProxyFile{}.response_files
  def mapping_path, do: %HttpProxyFile{}.mapping_files

  def filename(conn) do
    :random.seed(:erlang.now)
    random_st = Integer.to_string(:random.uniform 100_000_000)
    Enum.join(conn.path_info, "-") <> "-" <> random_st <> ".json"
  end

  # TODO: reduce `conn`
  def export(json, file, conn) do
    unless File.exists?(gen_export_path(conn)), do: File.mkdir_p gen_export_path(conn)
    File.write((gen_export_path(conn) <> "/" <> file), json)
  end

  # TODO: read recorded files
  def read_from(file) do
    unless File.exists?(gen_export_path), do: raise(ArgumentError, "no mapping files")
    case File.read (gen_export_path <> "/" <> file) do
      {:ok, body} ->
        JSX.decode body
      {:error, message} ->
        {:error, message}
    end
  end
end
