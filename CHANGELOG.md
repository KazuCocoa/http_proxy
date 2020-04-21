# Changelogs
## 1.5.0
- Drop Elixir 1.7

## 1.4.0: Oct 21, 2018
- Update to Plug 1.7
    - `{:plug_cowboy, "~> 2.0"}`

## 1.3.1: May 20, 2018
- Update to Cowboy2 and Plug 1.5

## 1.3.0: Feb 17, 2018
- Support Elixir 1.6 and drop 1.5 and 1.4
    - Since supervisor stuff

## 1.2.3: Aug 28, 2017
- Update some dependencies

## 1.2.2: Jul 23, 2017
- Set extra_applications and runtime: false

## 1.2.1: Jul 23, 2017
- Update some dependencies
    - Set a limitation for Plug ~> 1.3.0

## 1.2.0: Jun 26, 2017
- Suppoer Elixir1.4.0+ and fix some warnings [here](https://github.com/KazuCocoa/http_proxy/pull/41)

## 1.1.5: Apr 6, 2017
- Update some dependencies

## 1.1.4: Mar 9, 2017
- Update some dependencies
- Remove ExVCR since this library isn't used in this project

## 1.1.3: Dec 1, 2016
- Update Plug to 1.3.0

## 1.1.2: Nov 21, 2016
- remove `export_path` and `play_path` from `%HttpProxy.Utils.File{}`
  - read them directly from `config/config.exs`

## 1.1.1: Nov 19, 2016
- update some dependencies

## 1.1.0: Aug 31, 2016
- Require Elixir ~> 1.3 due to update Plug from 1.1 to 1.2

## 1.0.3: Jul 5, 2016
- fix https://github.com/KazuCocoa/http_proxy/issues/25

## 1.0.2: Apr 14, 2016
- update some dependencies

## 1.0.1: Feb 1, 2016
- update some dependencies

## 1.0.0: Jan 16, 2016
- Lock over Elixir1.2
- Support store play responses in Agent.

## 0.6.0: Jan 7, 2016
- support setting response body from file.
- read README and `body_file`

## 0.5.3: Dec 31, 2015
- Fix getting headers in play mode with Elixir 1.2.0 [#15](https://github.com/KazuCocoa/http_proxy/issues/15)

## 0.5.1 and 0.5.2: Dec 30, 2015
- Add `HttpProxy.stop` and `HttpProxy.start` to stop/start the proxy manually.

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
- update timeout settings

## 0.3.3: Dec 21, 2015
- Support timeout option
- Record every request/response body

## 0.3.2: Dec 18, 2015
- fix define method instead some initial value [#1](https://github.com/KazuCocoa/http_proxy/issues/1)
- fix don't sent request when proxy mode

## 0.3.0: Dec 8, 2015
- Support record/play request for each proxy.

## 0.2.1: Nov 21, 2015
- arrange format like VRC one.

## 0.2.0: Nov 13, 2015
- support record request and export into JSON

## 0.1.0: Nov 8, 2015
- initial release
