defmodule HttpProxy.Data do
  defstruct request: [:url, :remote, :method, :headers, :request_body, :options],
            response: [:body, :cookies, :status_code, :headers]
end

defmodule HttpProxy.Play.Response do
  defstruct responses: HttpProxy.Handle.play_responses
end
