defmodule HttpProxy.Utils.File do
  @moduledoc false

  defstruct export_path: Application.get_env(:http_proxy, :export_path) || "default",
            play_path: Application.get_env(:http_proxy, :play_path) || "default",
            response_files: "__files",
            mapping_files: "mappings"

  alias HttpProxy.Utils.File, as: HttpProxyFile

  def get_export_path, do: %HttpProxyFile{}.export_path
  def get_export_path(conn), do: %HttpProxyFile{}.export_path <> "/" <> Integer.to_string(conn.port)
  def get_response_path, do: %HttpProxyFile{}.play_path <> "/" <> %HttpProxyFile{}.response_files
  def get_mapping_path, do: %HttpProxyFile{}.play_path <> "/" <> %HttpProxyFile{}.mapping_files

  def filename(conn) do
    :random.seed(:erlang.now)
    random_st = Integer.to_string(:random.uniform 100_000_000)
    Enum.join(conn.path_info, "-") <> "-" <> random_st <> ".json"
  end

  # TODO: reduce `conn`
  def export(json, file, conn) do
    unless File.exists?(get_export_path(conn)), do: File.mkdir_p get_export_path(conn)
    File.write((get_export_path(conn) <> "/" <> file), json)
  end

  # TODO: read recorded files

  def read_json_file!(path) do
    case read_json_file(path) do
      {:ok, body}       -> body
      {:error, message} -> raise ArgumentError, message
    end
  end
  def read_json_file(path) do
    case File.read(path) do
      {:ok, body}       -> JSX.decode(body)
      {:error, message} -> {:error, message}
    end
  end

  def json_files!(dir) do
    case json_files(dir) do
      {:ok, files}      -> files
      {:error, message} -> raise ArgumentError, message
    end
  end
  def json_files(dir \\ ".") do
    case File.ls(dir) do
      {:ok, files} ->
        files = files
                |> Enum.filter_map(fn file ->
                  Path.extname(file) == ".json"
                end, &(dir <> "/" <> &1))
        {:ok, files}
      {:error, message} -> {:error, message}
    end
  end
end
