# HttpProxy

Simple multi HTTP Proxy using Plug.
Base implementation is inspired by https://github.com/josevalim/proxy.

# MY GOAL
- Record/Play proxied requests
    - http_proxy support multi port and multi urls on one execution command `mix proxy`.
- Support VCR

# How to use

```
$ mix deps.get
$ mix proxy # start proxy server
```

# Configuration

```
use Mix.Config

config :http_proxy,
  proxies: [
             %{port: 8080,
               to:   "http://google.com"},
             %{port: 8081,
               to:   "http://yahoo.com"}
            ]
  record: false, # true: record requests. false: don't record.
  play: true,    # true: play stored requests. false: don't play.
  export_path: "test/example",
  play_path: "test/data"
```

## Example

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
    "body": "<HTML><HEAD><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">\n<TITLE>301 Moved</TITLE></HEAD><BODY>\n<H1>301 Moved</H1>\nThe document has moved\n<A HREF=\"http://www.google.com/hoge/inu?email=neko&amp;pass=123\">here</A>.\r\n</BODY></HTML>\r\n",
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

# TODO
- [x] record request
    - [x] should able to encode cookies: Use JSX to decode into jsons.
    - [x] format to like vrc
- [ ] play request
    - [x] implement simple case
    - [x] expand them
    - [ ] verify template json format
- [ ] refactor
    - [ ] file structures
    - [ ] append test cases
    - [ ] prepare document
- [ ] use vcr <= a bit...
    - integrate https://github.com/parroty/exvcr

# LICENSE
MIT. Please read LICENSE.
