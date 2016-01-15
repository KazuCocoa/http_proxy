defmodule  HttpProxy.Play.Paths do
  @moduledoc """
  HttpProxy.Play.Paths is structure for play response mode.
  The structure gets paths as list via HttpProxy.Play.Response.play_paths.
  """

  alias HttpProxy.Play.Response
  alias HttpProxy.Agent, as: ProxyAgent

  @paths :play_paths
  @patterns :play_path_patterns


  @doc ~S"""
  Return `paths` attribute in `HttpProxy.Play.Paths.__struct__`

  ## Example

      iex> HttpProxy.Play.Paths.paths
      ["/request/path", "/request/path"]
  """
  @spec paths() :: binary
  def paths do
    case ProxyAgent.get(@paths) do
      nil ->
        ProxyAgent.put @paths, Response.play_paths("path")
        paths
      paths_val ->
        paths_val
    end
  end

  @doc ~S"""
  Return `path_patterns` attribute in `HttpProxy.Play.Paths.__struct__`

  ## Example

      iex> HttpProxy.Play.Paths.path_patterns
      ["\\A/request.*neko\\z"]
  """
  @spec path_patterns() :: binary
  def path_patterns do
    case ProxyAgent.get(@patterns) do
      nil ->
        ProxyAgent.put @patterns, Response.play_paths("path_pattern")
        path_patterns
      paths_pattern_val ->
        paths_pattern_val
    end
  end

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
