defmodule  HttpProxy.Play.Paths do
  @moduledoc """
  HttpProxy.Play.Paths is structure for play response mode.
  The structure gets paths as list via HttpProxy.Play.Response.play_paths.
  """

  alias HttpProxy.Play.Paths
  alias HttpProxy.Play.Response

  defstruct paths: Response.play_paths("path"), path_patterns: Response.play_paths("path_pattern")

  def paths, do: %Paths{}.paths
  def path_patterns, do: %Paths{}.path_patterns
end
