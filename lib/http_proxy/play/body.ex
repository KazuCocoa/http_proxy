defmodule HttpProxy.Play.Body do
  @moduledoc """
  Get files against play
  """

  @spec get_body(binary) :: binary
  def get_body(%{"response" => %{"body" => body}}), do: body
  def get_body(%{"response" => %{"body_file" => body_file}}) do
    case get_binay_from body_file do
      {:ok, result} ->
        result
      {:error, _} ->
        ""
    end
  end

  defp get_binay_from(file_path), do: File.read(file_path)
end
