defmodule HttpProxy.Utils do
  @moduledoc false

  @str_list "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

  @doc ~S"""

  Get paths defined on `config/"#{Mix.env}.exs"`

  ## Exmaple

      iex> HttpProxy.Utils.rand_st(0) |> String.length
      0

      iex> HttpProxy.Utils.rand_st(5) |> String.length
      5
  """
  def rand_st(n) do
    rand_s("", n)
  end

  defp rand_s(string, n) when n == 0 and is_bitstring(string), do: string
  defp rand_s(string, n) when is_bitstring(string) do
    additional = @str_list
                 |> String.codepoints
                 |> Enum.random
    string = string <> additional
    rand_s(string, n-1)
  end
end
