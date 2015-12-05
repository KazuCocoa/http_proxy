defmodule HttpProxy.Play.Response do
  @moduledoc false

  alias HttpProxy.Utils.File, as: HttpProxyFile

  def play_responses do
    HttpProxyFile.get_mapping_path
    |> HttpProxyFile.json_files!
    |> Enum.reduce([], fn path, acc ->
      json = HttpProxyFile.read_json_file!(path)
             |> verify

      key = ~s(#{String.downcase(json["request"]["method"])}_#{Integer.to_string(json["request"]["port"])}/#{json["request"]["path"]})
      List.keystore(acc, String.to_atom(key), 0, {String.to_atom(key), json})
    end)
  end

  # TODO: improve verification logic
  defp verify(json) do
    unless Map.has_key?(json, "request"), do: raise ArgumentError, "Should have request"
    request = json["request"]
    unless Map.has_key?(request, "method"), do: raise ArgumentError, "Should have method"
    unless Map.has_key?(request, "path"), do: raise ArgumentError, "Should have path"
    unless Map.has_key?(request, "port"), do: raise ArgumentError, "Should have port"

    unless Map.has_key?(json, "response"), do: raise ArgumentError, "Should have response"
    response = json["response"]
    unless Map.has_key?(response, "body"), do: raise ArgumentError, "Should have body"
    unless Map.has_key?(response, "cookies"), do: raise ArgumentError, "Should have cookies"
    unless Map.has_key?(response, "headers"), do: raise ArgumentError, "Should have headers"
    unless Map.has_key?(response, "status_code"), do: raise ArgumentError, "Should have status_code"

    json
  end
end
