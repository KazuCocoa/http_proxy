# HttpProxy

Simple HTTP Proxy. Forward to other URL via each port.

# How to work

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

# LICENSE
MIT. Please read LICENSE.
