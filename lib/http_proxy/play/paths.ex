defmodule HttpProxy.Play.Paths do
  @moduledoc """
  HttpProxy.Play.Paths is structure for play response mode.
  The structure gets paths as list via HttpProxy.Play.Response.play_paths.
  """

  alias HttpProxy.Agent, as: ProxyAgent
  alias HttpProxy.Play.Response

  @type path :: binary
  @type paths :: [path]

  @paths :play_paths
  @patterns :play_path_patterns

  @doc ~S"""
  Return `paths` stored in Agent.

  ## Example

      iex> HttpProxy.Play.Paths.paths
      ["/request/path", "/request/path"]
  """
  @spec paths() :: paths
  def paths, do: paths(ProxyAgent.get(@paths))

  defp paths(nil) do
    ProxyAgent.put(@paths, Response.play_paths("path"))
    paths()
  end

  defp paths(val), do: val

  @spec clear_paths() :: :ok
  def clear_paths, do: ProxyAgent.put(@paths, nil)

  @doc ~S"""
  Return `path_patterns` stored in Agent.

  ## Example

      iex> HttpProxy.Play.Paths.path_patterns
      ["\\A/request.*neko\\z"]
  """
  @spec path_patterns() :: paths
  def path_patterns, do: path_patterns(ProxyAgent.get(@patterns))

  defp path_patterns(nil) do
    ProxyAgent.put(@patterns, Response.play_paths("path_pattern"))
    path_patterns()
  end

  defp path_patterns(val), do: val

  @spec clear_path_patterns() :: :ok
  def clear_path_patterns, do: ProxyAgent.put(@patterns, nil)

  @spec path?(path) :: path | nil
  def path?(path) do
    case Enum.member?(paths(), path) do
      false ->
        nil

      true ->
        path
    end
  end

  @spec path_pattern?(path) :: path | nil
  def path_pattern?(path) do
    Enum.find(path_patterns(), nil, fn pattern ->
      Regex.match?(Regex.compile!(pattern), path)
    end)
  end
end
