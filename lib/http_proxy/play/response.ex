defmodule HttpProxy.Play.Response do
  @moduledoc false

  alias HttpProxy.Utils.File, as: HttpProxyFile

  # TODO: should remove `json_test_dir`
  def play_responses() do
    HttpProxyFile.get_mapping_path
    |> HttpProxyFile.json_files!
    |> Enum.reduce([], fn path, acc ->
      json = HttpProxyFile.read_json_file!(path)
      key = Integer.to_string(json["request"]["port"]) <> "/" <> json["request"]["path"]
      List.keystore(acc, :"#{key}", 0, {:"#{key}", json})
    end)
  end
end
