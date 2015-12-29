defmodule  HttpProxy.Play.Paths do
  @moduledoc """
  HttpProxy.Play.Paths is structure for play response mode.
  The structure gets paths as list via HttpProxy.Play.Response.play_paths.
  """

  alias HttpProxy.Play.Paths
  alias HttpProxy.Play.Response

  @doc ~S"""
  Structure associated with response paths used play response mode.
  The `http_proxy` returns response when the http_proxy receives http request and its path matchs `path` or `path_pattern`.

  ## Example

      iex> HttpProxy.Play.Paths.__struct__
      %HttpProxy.Play.Paths{path_patterns: ["\\A/request.*neko\\z"],
          paths: ["/request/path", "/request/path"]}
  """
  defstruct paths: Response.play_paths("path"), path_patterns: Response.play_paths("path_pattern")

  @doc ~S"""
  Return `paths` attribute in `HttpProxy.Play.Paths.__struct__`

  ## Example

      iex> HttpProxy.Play.Paths.paths
      ["/request/path", "/request/path"]
  """
  @spec paths() :: list
  def paths, do: %Paths{}.paths

  @doc ~S"""
  Return `path_patterns` attribute in `HttpProxy.Play.Paths.__struct__`

  ## Example

      iex> HttpProxy.Play.Paths.path_patterns
      ["\\A/request.*neko\\z"]
  """
  @spec path_patterns() :: list
  def path_patterns, do: %Paths{}.path_patterns

  @spec has_path?(binary) :: binary | nil
  def has_path?(path) do
    case Enum.member? paths, path do
      false ->
        nil
      true ->
        path
    end
  end

  @spec has_path_pattern?(binary) :: binary | nil
  def has_path_pattern?(path) do
    Enum.find path_patterns, nil, fn pattern ->
      Regex.match?(Regex.compile!(pattern), path)
    end
  end
end
