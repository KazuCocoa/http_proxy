defmodule HttpProxy.Data do
  @moduledoc false

  defstruct request: [:url, :remote, :method, :headers, :request_body, :options],
            response: [:body, :cookies, :status_code, :headers]
end
