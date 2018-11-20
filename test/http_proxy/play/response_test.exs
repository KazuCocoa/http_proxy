defmodule HttpProxy.Play.ResponseTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  alias HttpProxy.Play.Response, as: Response
  alias JSX

  doctest Response

  test "tewrong diff in request" do
    json = ~s"""
    {
      "request": {
        "port": 8080,
      },
      "response": {
        "body": "<html>hello world</html>",
        "cookies": {},
        "headers": {
          "Content-Type": "text/html; charset=UTF-8",
          "Server": "GFE/2.0"
        },
        "status_code": 200
      }
    }
    """

    assert_raise ArgumentError, "Response jsons must include arrtibute: path_pattern path method ", fn ->
      json |> JSX.decode! |> Response.validate
    end
  end

  test "wrong diff in response" do
    json = ~s"""
    {
      "request": {
        "path": "/request/path",
        "port": 8080,
        "method": "GET"
    },
      "response": {
        "cookies": {},
        "headers": {
          "Content-Type": "text/html; charset=UTF-8",
          "Server": "GFE/2.0"
        },
        "status_code": 200
      }
    }
    """

    assert_raise ArgumentError, "Response jsons must include arrtibute: body_file body ", fn ->
      json |> JSX.decode! |> Response.validate
    end
  end

  test "request has path_pattern and path" do
    json = ~s"""
    {
      "request": {
        "path_pattern": "path_pattern",
        "path": "path",
        "port": 8080,
        "method": "GET"
    },
      "response": {
        "cookies": {},
        "headers": {
          "Content-Type": "text/html; charset=UTF-8",
          "Server": "GFE/2.0"
        },
        "status_code": 200
      }
    }
    """

    assert_raise ArgumentError, "Response jsons must include arrtibute: path_pattern path ", fn ->
      json |> JSX.decode! |> Response.validate
    end
  end

  test "response has body and body_files" do
    json = ~s"""
    {
      "request": {
        "path": "path",
        "port": 8080,
        "method": "GET"
    },
      "response": {
        "body": "<html>hello world</html>",
        "body_file": "path/to/body",
        "cookies": {},
        "headers": {
          "Content-Type": "text/html; charset=UTF-8",
          "Server": "GFE/2.0"
        },
        "status_code": 200
      }
    }
    """

    assert_raise ArgumentError, "Response jsons must include arrtibute: body_file body ", fn ->
      json |> JSX.decode! |> Response.validate
    end
  end
end
