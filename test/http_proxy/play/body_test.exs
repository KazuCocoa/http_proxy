defmodule HttpProxy.Play.BodyTest do
  use ExUnit.Case, async: true

  alias HttpProxy.Play.Body

  test "get body" do
    value = %{"request" => %{"method" => "GET",
         "path" => "/request/path", "port" => 8080},
       "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
         "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
           "Server" => "GFE/2.0"}, "status_code" => 200}}
    assert Body.get_body(value) == "<html>hello world</html>"
    assert Body.get_body_file(value) == nil
  end

  test "fail to get body" do
    value = %{"request" => %{"method" => "GET",
         "path" => "/request/path", "port" => 8080},
       "response" => %{"body_file" => "file/to/path.json", "cookies" => %{},
         "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
           "Server" => "GFE/2.0"}, "status_code" => 200}}
    assert Body.get_body(value) == nil
    assert Body.get_body_file(value) == "file/to/path.json"
  end

  test "get binary from file" do
    value = %{"request" => %{"method" => "GET",
         "path" => "/request/path", "port" => 8080},
       "response" => %{"body_file" => "test/data/__files/example.json", "cookies" => %{},
         "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
           "Server" => "GFE/2.0"}, "status_code" => 200}}
     expected = """
     {
       "example": "data"
     }
     """

     assert Body.get_binay_from!(Body.get_body_file(value)) == expected
  end

  test "fail to get binary from file" do
    value = %{"request" => %{"method" => "GET",
         "path" => "/request/path", "port" => 8080},
       "response" => %{"body_file" => "test/data/__files/fail_example.json", "cookies" => %{},
         "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
           "Server" => "GFE/2.0"}, "status_code" => 200}}

     assert_raise File.Error, fn ->
       Body.get_binay_from!(Body.get_body_file(value))
     end
  end
end
