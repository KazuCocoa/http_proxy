defmodule  HttpProxy.Play.Paths do
  @moduledoc """
  HttpProxy.Play.Paths is structure for play response mode.
  The structure gets paths as list via HttpProxy.Play.Response.play_paths.
  """

  alias HttpProxy.Play.Paths
  alias HttpProxy.Play.Response

  defstruct paths: Response.play_paths("path"), path_patterns: Response.play_paths("path_pattern")

  @spec paths() :: list
  def paths, do: %Paths{}.paths

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
