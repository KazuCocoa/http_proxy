defmodule HttpProxy.Play.BodyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HttpProxy.Play.Body


  property "get body" do
    check all body <- StreamData.binary(),
              max_runs: 50 do
      value = %{"request" => %{"method" => "GET",
            "path" => "/request/path", "port" => 8080},
            "response" => %{"body" => body, "cookies" => %{},
            "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
              "Server" => "GFE/2.0"}, "status_code" => 200}}
      assert Body.get_body(value) == body
    end
  end

  test "fail to get body" do
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

    assert Body.get_body(value) == expected
  end

  test "fail to get binary from file" do
    value = %{"request" => %{"method" => "GET",
         "path" => "/request/path", "port" => 8080},
       "response" => %{"body_file" => "test/data/__files/fail_example.json", "cookies" => %{},
         "headers" => %{"Content-Type" => "text/html; charset=UTF-8",
           "Server" => "GFE/2.0"}, "status_code" => 200}}

    assert Body.get_body(value) == ""
  end
end
