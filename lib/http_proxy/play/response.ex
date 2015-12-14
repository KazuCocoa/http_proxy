defmodule HttpProxy.Play.Response do
  @moduledoc false

  @play Application.get_env(:http_proxy, :play) || false
  @request_key_map Enum.into(["method", "path", "port"], MapSet.new)
  @response_key_map Enum.into(["body", "cookies", "headers", "status_code"], MapSet.new)

  alias HttpProxy.Utils.File, as: HttpProxyFile

  @spec play?() :: boolean
  def play?, do: @play

  @spec play_responses() :: [binary]
  def play_responses do
    case @play do
      true ->
        gen_response
      false ->
        []
    end
  end

  defp gen_response do
    HttpProxyFile.get_mapping_path
    |> HttpProxyFile.json_files!
    |> Enum.reduce([], fn path, acc ->
      json = HttpProxyFile.read_json_file!(path)
             |> verify

      key = ~s(#{String.downcase(json["request"]["method"])}_#{Integer.to_string(json["request"]["port"])}/#{json["request"]["path"]})
      List.keystore(acc, String.to_atom(key), 0, {String.to_atom(key), json})
    end)
  end

  defp verify(json) do
    unless Map.has_key?(json, "request"), do: raise ArgumentError, "Should have request"

    request_key = Map.keys(json["request"]) |> Enum.into(MapSet.new)
    request_diff = MapSet.difference(@request_key_map, request_key)

    response_key = Map.keys(json["response"]) |> Enum.into(MapSet.new)
    response_diff = MapSet.difference(@response_key_map, response_key)

    if MapSet.size(request_diff) > 0, do: raise ArgumentError, format_error_message(request_diff)
    if MapSet.size(response_diff) > 0, do: raise ArgumentError, format_error_message(response_diff)

    json
  end

  defp format_error_message(mapset) do
    message = MapSet.to_list(mapset)
    |> Enum.reduce("", fn item, acc ->
      ~s(#{item} #{acc})
    end)
    |> IO.inspect

    ~s(Response jsons must include arrtibute: #{message})
  end

  # TODO: Match url to given pattern
  # Pattern match conn.url with given pattern
  @spec pattern(binary, %{binary => binary}) :: boolean
  def pattern(conn_url, %{"url_pattern" => regex}), do: String.match? conn_url, regex
end
