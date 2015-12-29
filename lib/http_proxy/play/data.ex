defmodule HttpProxy.Play.Data do
  @moduledoc """
  HttpProxy.Play.Data is structure for play response mode.
  The structure gets data via HttpProxy.Play.Response.play_responses.
  """


  alias HttpProxy.Play.Data

  @doc ~S"""
  Structure associated with responses used play response mode.

  ## Example

      iex> HttpProxy.Play.Data.__struct__
      %HttpProxy.Play.Data{responses: ["get_8080/request/path": %{"request" => %{"method" => "GET",
                 "path" => "/request/path", "port" => 8080},
               "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                 "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}},
             "get_8080\\A/request.*neko\\z": %{"request" => %{"method" => "GET", "path_pattern" => "\\A/request.*neko\\z", "port" => 8080},
               "response" => %{"body" => "<html>hello world2</html>", "cookies" => %{},
                 "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}},
             "post_8081/request/path": %{"request" => %{"method" => "POST", "path" => "/request/path", "port" => 8081},
               "response" => %{"body" => "<html>hello world 3</html>", "cookies" => %{},
                 "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}}]}
  """
  defstruct responses: HttpProxy.Play.Response.play_responses

  @doc ~S"""
  Return `responses` attribute in `HttpProxy.Play.Data.__struct__`

  ## Example

      iex> HttpProxy.Play.Data.responses
      ["get_8080/request/path": %{"request" => %{"method" => "GET",
           "path" => "/request/path", "port" => 8080},
         "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
           "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
             "Server" => "GFE/2.0"}, "status_code" => 200}},
       "get_8080\\A/request.*neko\\z": %{"request" => %{"method" => "GET",
           "path_pattern" => "\\A/request.*neko\\z", "port" => 8080},
         "response" => %{"body" => "<html>hello world2</html>", "cookies" => %{},
           "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
             "Server" => "GFE/2.0"}, "status_code" => 200}},
       "post_8081/request/path": %{"request" => %{"method" => "POST",
           "path" => "/request/path", "port" => 8081},
         "response" => %{"body" => "<html>hello world 3</html>", "cookies" => %{},
           "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
             "Server" => "GFE/2.0"}, "status_code" => 200}}]
  """
  @spec responses :: binary
  def responses, do: %Data{}.responses
end
