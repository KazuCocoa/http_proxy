# HttpProxy

Simple multi HTTP Proxy using Plug.
Base implementation is inspired by https://github.com/josevalim/proxy.

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
             %{port: 4000,
               to:   "http://google.com"},
             %{port: 4001,
               to:   "http://yahoo.com"}
            ]
```

# TODO
- [ ] record/play request <= a bit...
    - the following format is a sample.
```
[
  {
    "request": {
      "body": "",
      "headers": [],
      "method": "get",
      "options": [],
      "request_body": "",
      "url": "http://google.com/"
    },
    "response": {
      "body": "#Reference<0.0.4.17>",
      "headers": {
        "Cache-Control": "private",
        "Content-Type": "text/html; charset=UTF-8",
        "Location": "http://www.google.co.jp/?gfe_rd=cr&ei=EhhCVoy_Gsf98weenYHgCQ",
        "Content-Length": "261",
        "Date": "Tue, 10 Nov 2015 16:15:14 GMT",
        "Server": "GFE/2.0"
      },
      "status_code": 302,
      "type": "ok"
    }
  }
]
```
- [ ] use vcr <= a bit...
    - integrate https://github.com/parroty/exvcr

# LICENSE
MIT. Please read LICENSE.
