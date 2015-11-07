defmodule HttpProxy do
  use Application

  def start(_type, _args) do
    HttpProxy.Supervisor.start_link
  end
end