defmodule HttpProxy.File do
  @moduledoc false

  @export_path Application.get_env(:http_proxy, :export_path) || "default/__files"
  @mapping_path Application.get_env(:http_proxy, :mapping_path) || "default/mappings"

  def filename(conn) do
    random_st = Integer.to_string(:random.uniform 100_00_00_00)
    Enum.join(conn.path_info, "-") <> "-" <> random_st <> ".json"
  end

  def export(json, file) do
    unless File.exists?(@export_path), do: File.mkdir_p @export_path
    File.write((@export_path <> "/" <> file), json)
  end

  def read_from(file) do
    unless File.exists?(@mapping_path), do: raise ArgumentError, "no mapping files"
    case File.read (@mapping_path <> "/" <> file) do
      {:ok, body} ->
        Poison.decode body
      {:error, message} ->
        {:error, message}
    end
  end
end
