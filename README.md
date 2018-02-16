# HttpProxy

[![Build Status](https://travis-ci.org/KazuCocoa/http_proxy.svg?branch=master)](https://travis-ci.org/KazuCocoa/http_proxy)
[![](https://img.shields.io/hexpm/v/http_proxy.svg?style=flat)](https://hex.pm/packages/http_proxy)

[![codecov](https://codecov.io/gh/KazuCocoa/http_proxy/branch/master/graph/badge.svg)](https://codecov.io/gh/KazuCocoa/http_proxy)

Simple multi HTTP Proxy using Plug. And support record/play requests.

# MY GOAL
- Record/Play proxied requests
    - http_proxy support multi port and multi urls on one execution command `mix proxy`.
- Support VCR

# architecture

```
           http_proxy
Client  (server  client)  proxied_server
  |            |            |
  | 1.request  |            |
  |  ------>   | 2.request  |
  |            |  ------>   |
  |            |            |
  |            | 3.response |
  | 4.response |  <------   |
  |  <------   |            |
  |            |            |
```

1. The client sends request to http_proxy, then the http_proxy works as a proxy server.
2. When the http_proxy receives request from the client, then the http_proxy sends request to proxied server, e.g. http://google.com, as client.
3. The http_proxy receives responses from the proxied_server, then the http_proxy sets the response into its response to the client.
4. The Client receives responses from the http_proxy.

# Quick use as http proxy
## requirement
- Elixir over 1.3

## set application and deps

- `mix.exs`
    - `:logger` is option.
    - `:http_proxy` is not need if you run http_proxy with `HttpProxy.start/0` or `HttpProxy.stop/0` manually.

```elixir
def application do
  [applications: [:logger, :http_proxy]]
end

...

defp deps do
  [
    {:http_proxy, "~> 1.3.0"}
  ]
end
```

## set configuration

- `config/config.exs`

```
use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
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
$ mix clean
$ mix run --no-halt # start proxy server
```

If you would like to start production mode, you should run with `MIX_ENV=prod` like the following command.

```
$ MIX_ENV=prod mix run --no-halt
```

## launch browser

Launch browser and open `http://localhost:8080` or `http://localhost:8081`.
Then, `http://localhost:8080` redirect to `http://google.com` and `http://localhost:8081` do to `http://yahoo.com`.

# Configuration
## Customize proxy port

- You can customize proxy port. For example, if you change waiting port from `8080` to `4000`, then you can access to `http://google.com` via `http://localhost:4000`.

```
use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 4000,
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"}
            ]
```

## Add proxy

- You can increase waiting port to add configuration. You can add them up to much resources. For example, the following setting allow you to access to `http://apple.com` via `http://localhost:8082` in addition.

```
use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"},
             %{port: 8082,
               to:   "http://apple.com"}
            ]
```

## Play and Record mode

- When `:record` and `:play` are `false`, then the http_proxy works just multi port proxy.
- When `:record` is `true`, then the http_proxy works to record request which is proxied.
- When `:play` is `true`, then the http_proxy works to play request between this the http_proxy and clients.
    - You should set JSON files under `mappings` in `play_path`.
    - `config.proxies.to` must be available URL to succeed generating http client.
        - https://github.com/KazuCocoa/http_proxy/blob/master/lib/http_proxy/handle.ex#L49

```elixir
use Mix.Config

config :http_proxy,
  proxies: [                   # MUST
             %{port: 8080,     # proxy all request even play or record
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"}
            ]
  timeout: 20_000,             # Option, ms to wait http request.
  record: false,               # Option, true: record requests. false: don't record.
  play: false,                 # Option, true: play stored requests. false: don't play.
  export_path: "test/example", # Option, path to export recorded files.
  play_path: "test/data"       # Option, path to read json files as response to.
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

- Example is https://github.com/KazuCocoa/http_proxy/tree/master/test/data/mappings
- You can set `path` or `path_pattern` as attribute under `request`.
    - If `path`, the http_proxy check requests are matched completely.
    - If `path_pattern`, the http_proxy check requests are matched with Regex.
- You can set `body` or `body_file` as attribute under `response`.
    - If `body`, the http_proxy send the body string.
    - If `body_file`, the http_proxy send the body_file binary as response.

#### `path` and `body` case

```json
{
  "request": {
    "path": "/request/path",
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

#### `path_pattern` and `body_file` case

- Pattern match with `Regex.match?(Regex.compile!("\A/request.*neko\z"), request_path)`
- `File.read/2` via `file/to/path.json` and respond the binary

```json
{
  "request": {
    "path_pattern": "\A/request.*neko\z",
    "port": 8080,
    "method": "GET"
  },
  "response": {
    "body_file": "file/to/path.json",
    "cookies": {},
    "headers": {
      "Content-Type": "text/html; charset=UTF-8",
      "Server": "GFE/2.0"
    },
    "status_code": 200
  }
}
```

## dependencies

```
$ mix xref graph
lib/http_proxy.ex
└── lib/http_proxy/supervisor.ex
    ├── lib/http_proxy/agent.ex
    │   ├── lib/http_proxy/play/data.ex
    │   │   ├── lib/http_proxy/agent.ex
    │   │   └── lib/http_proxy/play/response.ex
    │   │       ├── lib/http_proxy/play/data.ex
    │   │       └── lib/http_proxy/utils/file.ex
    │   └── lib/http_proxy/play/paths.ex
    │       ├── lib/http_proxy/agent.ex
    │       └── lib/http_proxy/play/response.ex
    └── lib/http_proxy/handle.ex
        ├── lib/http_proxy/play/body.ex
        ├── lib/http_proxy/play/data.ex
        ├── lib/http_proxy/play/paths.ex
        ├── lib/http_proxy/play/response.ex
        └── lib/http_proxy/record/response.ex
            ├── lib/http_proxy/format.ex
            │   └── lib/http_proxy/data.ex (compile)
            └── lib/http_proxy/utils/file.ex
```

# TODO
- [x] record request
- [x] play request
- [x] refactor
- [x] support Regex request path.
- [x] start/stop http_proxy manually
- [ ] ~~use vcr~~
    - integrate https://github.com/parroty/exvcr

# styleguide

http://elixir.community/styleguide

# LICENSE
MIT. Please read LICENSE.
