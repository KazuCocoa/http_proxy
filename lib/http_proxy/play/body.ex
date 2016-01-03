defmodule HttpProxy.Play.Body do
  @moduledoc """
  Get files against play
  """

  alias HttpProxy.Play.Data

  @spec get_body(binary) :: binary
  def get_body(hash_value), do: hash_value["response"]["body"]

  @spec get_body_file(binary) :: Path.t
  def get_body_file(hash_value), do: hash_value["response"]["body_file"]

  @spec get_binay_from!(Path.t) :: binary | no_return
  def get_binay_from!(file_path), do: File.read!(file_path)
end
