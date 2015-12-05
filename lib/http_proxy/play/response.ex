defmodule HttpProxy.Play.Response do
  @moduledoc false

  alias HttpProxy.Utils.File, as: HttpProxyFile

  def play_responses do
    HttpProxyFile.get_mapping_path
    |> HttpProxyFile.json_files!
    |> Enum.reduce([], fn path, acc ->
      json = HttpProxyFile.read_json_file!(path)
      key = String.downcase(json["request"]["method"]) <> "_" <> Integer.to_string(json["request"]["port"]) <> "/" <> json["request"]["path"]
      List.keystore(acc, String.to_atom(key), 0, {String.to_atom(key), json})
    end)
  end
end
