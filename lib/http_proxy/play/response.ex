defmodule HttpProxy.Play.Response do
  @moduledoc false

  @path_pattern "path_pattern"
  @path "path"
  @body "body"
  @body_file "body_file"

  @type response_body :: binary
  @type path :: String.t()
  @type path_pattern :: String.t()
  @type paths :: [binary]
  @type path_patterns :: [binary]

  @request_key_map Enum.into(["method", @path, "port", @path_pattern], MapSet.new())
  @response_key_map Enum.into(
                      [@body, @body_file, "cookies", "headers", "status_code"],
                      MapSet.new()
                    )

  alias HttpProxy.Play.Data
  alias HttpProxy.Utils.File, as: HttpProxyFile

  @spec play?() :: boolean
  def play?, do: Application.get_env(:http_proxy, :play, false)

  @spec play_responses() :: [response_body] | []
  def play_responses do
    case play?() do
      true ->
        gen_response()

      false ->
        []
    end
  end

  defp gen_response do
    HttpProxyFile.get_mapping_path()
    |> HttpProxyFile.json_files!()
    |> Enum.reduce([], fn path, acc ->
      json = validate(HttpProxyFile.read_json_file!(path))
      key = gen_key(json)
      List.keystore(acc, String.to_atom(key), 0, {String.to_atom(key), json})
    end)
  end

  defp gen_key(map) when is_map(map) do
    base =
      String.downcase(map["request"]["method"]) <>
        "_" <> Integer.to_string(map["request"]["port"])

    uri =
      case Map.has_key?(map["request"], @path_pattern) do
        false ->
          map["request"][@path]

        true ->
          map["request"][@path_pattern]
      end

    base <> uri
  end

  @doc """
  Validate JSX decoded json
  """
  @spec validate(JSX) :: :ok
  def validate(json) do
    unless Map.has_key?(json, "request"), do: raise(ArgumentError, "Should have request")

    request_key = json["request"] |> Map.keys() |> Enum.into(MapSet.new())
    request_diff = MapSet.difference(@request_key_map, request_key)

    response_key = json["response"] |> Map.keys() |> Enum.into(MapSet.new())
    response_diff = MapSet.difference(@response_key_map, response_key)

    case member_path?(request_diff, request_diff) do
      {true, true} ->
        raise ArgumentError, format_error_message(request_diff)

      {false, false} ->
        raise ArgumentError, format_error_message(Enum.into([@path, @path_pattern], MapSet.new()))

      {_, _} ->
        :ok
    end

    case member_body?(response_diff, response_diff) do
      {true, true} ->
        raise ArgumentError, format_error_message(response_diff)

      {false, false} ->
        raise ArgumentError, format_error_message(Enum.into([@body, @body_file], MapSet.new()))

      {_, _} ->
        :ok
    end

    json
  end

  defp member_path?(request_diff, request_diff),
    do: {MapSet.member?(request_diff, @path_pattern), MapSet.member?(request_diff, @path)}

  defp member_body?(response_diff, response_diff),
    do: {MapSet.member?(response_diff, @body), MapSet.member?(response_diff, @body_file)}

  defp format_error_message(mapset) do
    message =
      mapset
      |> MapSet.to_list()
      |> Enum.reduce("", fn item, acc ->
        "#{item} #{acc}"
      end)

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
  @spec play_paths(path | path_pattern) :: paths | path_patterns
  def play_paths(@path), do: play_data_responses(Data.responses(), @path)
  def play_paths(@path_pattern), do: play_data_responses(Data.responses(), @path_pattern)
  def play_paths(_), do: play_data_responses(Data.responses(), "")

  defp play_data_responses(nil, _), do: []

  defp play_data_responses(res, key) do
    res
    |> Enum.reduce([], fn res_tuple, acc ->
      case elem(res_tuple, 1)["request"][key] do
        nil ->
          acc

        elem ->
          Enum.into(acc, [elem])
      end
    end)
  end
end
