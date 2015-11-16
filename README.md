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
             %{port: 4000,
               to:   "http://google.com"},
             %{port: 4001,
               to:   "http://yahoo.com"}
            ]
  record: true, # true: record requests. false: don't record.
  export_path: "test_example" #
```

# TODO
- [x] record request
    - should able to encode cookies
    - update TODOs
- [ ] refactor
    - file structures
    - test cases
- [ ] play request
- [ ] use vcr <= a bit...
    - integrate https://github.com/parroty/exvcr

# LICENSE
MIT. Please read LICENSE.
