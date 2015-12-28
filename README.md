# HttpProxy

Simple multi HTTP Proxy using Plug.
Base implementation is inspired by https://github.com/josevalim/proxy.

# MY GOAL
- Record/Play proxied requests
    - http_proxy support multi port and multi urls on one execution command `mix proxy`.
- Support VCR

# Quick use as http proxy
## set application and deps

- `mix.exs`

```
def application do
  [applications: [:http_proxy]]
end

...

defp deps do
  [
    {:http_proxy, "~> 0.4.0"}
  ]
end
```

## set configure

- `config/config.exs`

```
use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,  # proxy all request even play or record
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"}
            ]
```

- To manage logger, you should define logger settings like the following.

```
config :logger, :console,
  level: :info
```

## solve deps and run server

```
$ mix deps.get
$ mix run --no-halt # start proxy server
```

If you would like to start production mode, you should run with `MIX_ENV=prod` like the following command.

```
$ MIX_ENV=prod mix run --no-halt
```

## launch browser

Launch browser and open `http://localhost:8080` or `http://localhost:8081`.

# Configuration

- When `:record` and `:play` are `false`, then the http_proxy works just multi port proxy.
- When `:record` is `true`, then the http_proxy works to record request which is proxied.
- When `:play` is `true`, then the http_proxy works to play request between this the http_proxy and clients.

```elixir
use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,  # proxy all request even play or record
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"}
            ]
  timeout: 20_000, # ms
  record: false, # true: record requests. false: don't record.
  play: false,   # true: play stored requests. false: don't play.
  export_path: "test/example",
  play_path: "test/data"
```

## Example

### Record request as the following

```json
{
  "request": {
    "headers": [],
    "method": "GET",
    "options": {
      "aspect": "query_params"
    },
    "remote": "127.0.0.1",
    "request_body": "",
    "url": "http://localhost:8080/hoge/inu?email=neko&pass=123"
  },
  "response": {
    "body_file": "path/to/body_file.json",
    "cookies": {},
    "headers": {
      "Cache-Control": "public, max-age=2592000",
      "Content-Length": "251",
      "Content-Type": "text/html; charset=UTF-8",
      "Date": "Sat, 21 Nov 2015 00:37:38 GMT",
      "Expires": "Mon, 21 Dec 2015 00:37:38 GMT",
      "Location": "http://www.google.com/hoge/inu?email=neko&pass=123",
      "Server": "sffe",
      "X-Content-Type-Options": "nosniff",
      "X-XSS-Protection": "1; mode=block"
    },
    "status_code": 301
  }
}
```
Response body will save in "path/to/body_file.json".

### Play request with the following JSON data

```json
{
  "request": {
    "path": "request/path",
    "port": 8080,
    "method": "GET"
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
```

# TODO
- [x] record request
    - [x] should able to encode cookies: Use JSX to decode into jsons.
    - [x] format to like vrc
- [x] play request
    - [x] implement simple case
    - [x] expand them
    - [x] verify template json format
- [x] refactor
    - [x] file structures
    - [x] append test cases
    - [x] Add `@spec`
    - [x] prepare document
- [ ] use vcr <= a bit...
    - integrate https://github.com/parroty/exvcr
- [ ] support Regex request path.

# LICENSE
MIT. Please read LICENSE.
