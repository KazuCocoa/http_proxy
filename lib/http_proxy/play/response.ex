defmodule HttpProxy.Play.Response do
  @moduledoc false

  @path_pattern "path_pattern"
  @path "path"

  @request_key_map Enum.into(["method", @path, "port", @path_pattern], MapSet.new)
  @response_key_map Enum.into(["body", "cookies", "headers", "status_code"], MapSet.new)

  alias HttpProxy.Utils.File, as: HttpProxyFile
  alias HttpProxy.Play.Data

  @spec play?() :: boolean
  def play?, do: Application.get_env :http_proxy, :play, false

  @spec play_responses() :: [binary]
  def play_responses do
    case play? do
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
             |> validate
      key = json |> gen_key
      List.keystore(acc, String.to_atom(key), 0, {String.to_atom(key), json})
    end)
  end

  defp gen_key(map) when is_map(map) do
    base = String.downcase(map["request"]["method"]) <> "_" <> Integer.to_string(map["request"]["port"])
    uri = case Map.has_key?(map["request"], @path_pattern) do
            false ->
              map["request"][@path]
            true ->
              map["request"][@path_pattern]
          end
    base <> uri
  end

  defp validate(json) do
    unless Map.has_key?(json, "request"), do: raise ArgumentError, "Should have request"

    request_key = Map.keys(json["request"]) |> Enum.into(MapSet.new)
    request_diff = MapSet.difference(@request_key_map, request_key)

    response_key = Map.keys(json["response"]) |> Enum.into(MapSet.new)
    response_diff = MapSet.difference(@response_key_map, response_key)

    case {MapSet.member?(request_diff, @path_pattern), MapSet.member?(request_diff, @path)} do
      {true, true} ->
        raise ArgumentError, format_error_message(request_diff)
      {false, false} ->
        raise ArgumentError, format_error_message(Enum.into(["port", @path_pattern], MapSet.new))
      {_, _} ->
        # ok
    end

    if MapSet.size(response_diff) > 0, do: raise ArgumentError, format_error_message(response_diff)

    json
  end

  defp format_error_message(mapset) do
    message = MapSet.to_list(mapset)
    |> Enum.reduce("", fn item, acc ->
      "#{item} #{acc}"
    end)
    |> IO.inspect

    "Response jsons must include arrtibute: #{message}"
  end

  @doc ~S"""
  Return list of paths associated with `path` and `path_pattern`.

  ## Example

      iex> HttpProxy.Play.Response.play_paths("path")
      ["/request/path", "/request/path"]

      iex> HttpProxy.Play.Response.play_paths("path_pattern")
      ["\\A/request.*neko\\z"]

      iex> HttpProxy.Play.Response.play_paths("no_pattern")
      []
  """
  @spec play_paths(binary) :: [binary]
  def play_paths(key), do: play_data_responses Data.responses, key

  defp play_data_responses(nil, _), do: []
  defp play_data_responses(res, key) do
    res
    |> Enum.reduce([], fn res_tuple, acc ->
      case elem(res_tuple, 1)["request"][key] do
        nil ->
          acc
        elem ->
          Enum.into acc, [elem]
      end
    end)
  end
end
