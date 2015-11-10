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
- [ ] record/play request
- [ ] use vcr <= a bit...
    - integrate https://github.com/parroty/exvcr

# LICENSE
MIT. Please read LICENSE.
