defmodule HttpProxyVerTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use Plug.Test

  # test "get request" do
  #   use_cassette "httpoison_get" do
  #     conn(:get, "http://localhost:8080/")
  #     |> HttpProxy.Handle.dispatch([])
  #   end
  # end

end
