# Changelogs

## 0.5.3: Dec 31, 2015
Fix getting headers in play mode with Elixir 1.2.0 [#15](https://github.com/KazuCocoa/http_proxy/issues/15)

## 0.5.1 and 0.5.2: Dec 30, 2015
Add `HttpProxy.stop` and `HttpProxy.start` to stop/start the proxy manually.

## 0.5.0: Dec 29, 2015
- Support regex path matching in play mode.

You can specify request path with Regex like the following `path_pattern`.

```
{
  "request": {
    "path_pattern": "\A/request.*neko\z",
    "port": 8080,
    "method": "GET"
  },
  ...
}
```

And some refactors.

## 0.4.1: Dec 25, 2015
record timeout into jsons when request timeout [#3](https://github.com/KazuCocoa/http_proxy/issues/3)

## 0.4.0: Dec 23, 2015
Export file into `mappings` / `__files` with recording mode

e.g.

1. When record a request and a response
2. Then two files are saved into following files
    - `test/example/8080/mappings/request_file.json`
    - `test/example/8080/__files/request_file.json`

## 0.3.4: Dec 23, 2015
update timeout settings

## 0.3.3: Dec 21, 2015
Support timeout option
Record every request/response body

## 0.3.2: Dec 18, 2015
fix define method instead some initial value [#1](https://github.com/KazuCocoa/http_proxy/issues/1)
fix don't sent request when proxy mode

## 0.3.0: Dec 8, 2015
Support record/play request for each proxy.

## 0.2.1: Nov 21, 2015
arrange format like VRC one.

## 0.2.0: Nov 13, 2015
support record request and export into JSON

## 0.1.0: Nov 8, 2015
initial release
