# HttpProxy

Simple HTTP Proxy.
Forward to other URL via each port.

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
             %{port: 4000, # wait port
               default_to: "http://google.com", # forward to other site
               # forward to other site if anyone access to particular paths
               path: [
                 %{from: "", to: "http://yahoo.com"},
                 %{from: "neko", to: "http://yahoo.co.jp"}
               ]
             },
             %{port: 4001,
               default_to: "http://google.com",
               path: [
                 %{from: "", to: "http://yahoo.com"},
                 %{from: "neko", to: "http://yahoo.co.jp"}
               ]
             }
            ]
```

# LICENSE
MIT. Please read LICENSE.
