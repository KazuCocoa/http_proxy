defmodule HttpProxy.Utils do
  @moduledoc false

  if Mix.env() == :test do
    @compile :export_all
    @compile :nowarn_export_all
  end

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

  defguardp is_length_zero(string, n) when n == 0 and is_bitstring(string)
  defp rand_s(string, n) when is_length_zero(string, n), do: string

  defp rand_s(string, n) when is_bitstring(string) do
    additional =
      @str_list
      |> String.codepoints()
      |> Enum.random()

    string = string <> additional
    rand_s(string, n - 1)
  end
end
