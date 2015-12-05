defmodule HttpProxy.Utils.File do
  @moduledoc """
  This module provides several paths associated with HttpProxy and file operation.
  """

  @doc ~S"""
  Structure associated with file paths.

  ## Example

      iex> HttpProxy.Utils.File.__struct__
      %HttpProxy.Utils.File{export_path: "test/example", mapping_files: "mappings",
        play_path: "test/data", response_files: "__files"}
  """
  defstruct export_path: Application.get_env(:http_proxy, :export_path) || "default",
            play_path: Application.get_env(:http_proxy, :play_path) || "default",
            response_files: "__files",
            mapping_files: "mappings"

  alias HttpProxy.Utils.File, as: HttpProxyFile

  @doc ~S"""

  Get paths defined on `config/"#{Mix.env}.exs"`

  ## Exmaple
      iex> HttpProxy.Utils.File.get_export_path
      "test/example"

      iex> HttpProxy.Utils.File.get_export_path(8080)
      "test/example/8080"

      iex> HttpProxy.Utils.File.get_export_path("8080")
      "test/example/8080"

      iex> HttpProxy.Utils.File.get_response_path
      "test/data/__files"

      iex> HttpProxy.Utils.File.get_mapping_path
      "test/data/mappings"
  """
  def get_export_path, do: %HttpProxyFile{}.export_path
  def get_export_path(port) when is_integer(port), do: ~s(#{%HttpProxyFile{}.export_path}/#{Integer.to_string(port)})
  def get_export_path(port) when is_bitstring(port), do: ~s(#{%HttpProxyFile{}.export_path}/#{port})
  def get_response_path, do: %HttpProxyFile{}.play_path <> "/" <> %HttpProxyFile{}.response_files
  def get_mapping_path, do: %HttpProxyFile{}.play_path <> "/" <> %HttpProxyFile{}.mapping_files

  @doc ~S"""
  Generate json file name with `:rand.uniform`

  ## Example
      iex> HttpProxy.Utils.File.filename(["path-info-path"]) |> String.match?(~r(\Apath-info-path.*\.json\z))
      true

      iex> HttpProxy.Utils.File.filename("path-info-path") |> String.match?(~r(\Apath-info-path.*\.json\z))
      true
  """
  def filename(path_info) when is_list(path_info) do
    random_st = Integer.to_string(:rand.uniform 100_000_000)
    ~s(#{Enum.join(path_info, "-")}-#{random_st}.json)
  end
  def filename(path_info) when is_bitstring(path_info) do
    random_st = Integer.to_string(:rand.uniform 100_000_000)
    ~s(#{path_info}-#{random_st}.json)
  end

  @doc """
  Export json data into `path/file`.
  """
  def export(json, path, file) do
    unless File.exists?(path), do: File.mkdir_p path
    File.write(~s(#{path}/#{file}), json)
  end

  @doc ~S"""

  Get decoded map data by `JSX.decode/2`

  ## Example

      iex> HttpProxy.Utils.File.read_json_file!("test/data/mappings/sample.json")
      %{"request" => %{"method" => "GET", "path" => "request/path", "port" => 8080},
             "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
               "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}}

      iex> HttpProxy.Utils.File.read_json_file("test/data/mappings/sample.json")
      {:ok,
            %{"request" => %{"method" => "GET", "path" => "request/path", "port" => 8080},
              "response" => %{"body" => "<html>hello world</html>", "cookies" => %{},
                "headers" => %{"Content-Type" => "text/html; charset=UTF-8", "Server" => "GFE/2.0"}, "status_code" => 200}}}
  """
  def read_json_file!(path) do
    case read_json_file(path) do
      {:ok, body}       -> body
      {:error, message} -> raise ArgumentError, message
    end
  end
  def read_json_file(path) do
    case File.read(path) do
      {:ok, body}       -> JSX.decode(body)
      {:error, message} -> {:error, message}
    end
  end

  @doc ~S"""

  Get paths in particular directory as list.

  ## Example

      iex> HttpProxy.Utils.File.json_files!("test/data/mappings")
      ["test/data/mappings/sample.json", "test/data/mappings/sample2.json", "test/data/mappings/sample3.json"]

      iex> HttpProxy.Utils.File.json_files("test/data/mappings")
      {:ok, ["test/data/mappings/sample.json", "test/data/mappings/sample2.json", "test/data/mappings/sample3.json"]}
  """
  def json_files!(dir) do
    case json_files(dir) do
      {:ok, files}      -> files
      {:error, message} -> raise ArgumentError, message
    end
  end
  def json_files(dir \\ ".") do
    case File.ls(dir) do
      {:ok, files} ->
        files = files
                |> Enum.filter_map(fn file ->
                  Path.extname(file) == ".json"
                end, &(dir <> "/" <> &1))
        {:ok, files}
      {:error, message} -> {:error, message}
    end
  end
end
