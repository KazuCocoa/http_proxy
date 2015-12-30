ExUnit.start()

defmodule HttpProxy.TestHelper do
  def set_play_mode do
    Application.put_env :http_proxy, :record, false
    Application.put_env :http_proxy, :play, true
  end

  def set_record_mode do
    Application.put_env :http_proxy, :record, true
    Application.put_env :http_proxy, :play, false
  end
end
