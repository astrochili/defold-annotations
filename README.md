# Defold Annotations

[![Workflow](https://img.shields.io/github/actions/workflow/status/astrochili/defold-annotations/release.yml)](https://github.com/astrochili/defold-annotations/actions/workflows/release.yml)
[![Release](https://img.shields.io/github/v/release/astrochili/defold-annotations.svg?include_prereleases=&sort=semver&color=blue)](https://github.com/astrochili/defold-annotations/releases)
[![License](https://img.shields.io/badge/License-MIT-blue)](https://github.com/astrochili/defold-annotations/blob/master/LICENSE)
[![Website](https://img.shields.io/badge/website-gray.svg?&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxOCIgaGVpZ2h0PSIxNiIgZmlsbD0ibm9uZSIgdmlld0JveD0iMCAwIDE4IDE2Ij48Y2lyY2xlIGN4PSIzLjY2IiBjeT0iMTQuNzUiIHI9IjEuMjUiIGZpbGw9InVybCgjYSkiLz48Y2lyY2xlIGN4PSI4LjY2IiBjeT0iMTQuNzUiIHI9IjEuMjUiIGZpbGw9InVybCgjYikiLz48Y2lyY2xlIGN4PSIxMy42NSIgY3k9IjE0Ljc1IiByPSIxLjI1IiBmaWxsPSJ1cmwoI2MpIi8+PHBhdGggZmlsbD0idXJsKCNkKSIgZmlsbC1ydWxlPSJldmVub2RkIiBkPSJNNy42MyAxLjQ4Yy41LS43IDEuNTUtLjcgMi4wNSAwbDYuMjIgOC44MWMuNTguODMtLjAxIDEuOTctMS4wMyAxLjk3SDIuNDRhMS4yNSAxLjI1IDAgMCAxLTEuMDItMS45N2w2LjIxLTguODFaIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiLz48ZGVmcz48bGluZWFyR3JhZGllbnQgaWQ9ImEiIHgxPSIyLjQxIiB4Mj0iMi40MSIgeTE9IjEzLjUiIHkyPSIxNiIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPjxzdG9wIHN0b3AtY29sb3I9IiNGRDhENDIiLz48c3RvcCBvZmZzZXQ9IjEiIHN0b3AtY29sb3I9IiNGOTU0MUYiLz48L2xpbmVhckdyYWRpZW50PjxsaW5lYXJHcmFkaWVudCBpZD0iYiIgeDE9IjcuNDEiIHgyPSI3LjQxIiB5MT0iMTMuNSIgeTI9IjE2IiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHN0b3Agc3RvcC1jb2xvcj0iI0ZEOEQ0MiIvPjxzdG9wIG9mZnNldD0iMSIgc3RvcC1jb2xvcj0iI0Y5NTQxRiIvPjwvbGluZWFyR3JhZGllbnQ+PGxpbmVhckdyYWRpZW50IGlkPSJjIiB4MT0iMTIuNCIgeDI9IjEyLjQiIHkxPSIxMy41IiB5Mj0iMTYiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj48c3RvcCBzdG9wLWNvbG9yPSIjRkQ4RDQyIi8+PHN0b3Agb2Zmc2V0PSIxIiBzdG9wLWNvbG9yPSIjRjk1NDFGIi8+PC9saW5lYXJHcmFkaWVudD48bGluZWFyR3JhZGllbnQgaWQ9ImQiIHgxPSIuMDMiIHgyPSIuMDMiIHkxPSIuMDMiIHkyPSIxMi4yNiIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPjxzdG9wIHN0b3AtY29sb3I9IiNGRkU2NUUiLz48c3RvcCBvZmZzZXQ9IjEiIHN0b3AtY29sb3I9IiNGRkM4MzAiLz48L2xpbmVhckdyYWRpZW50PjwvZGVmcz48L3N2Zz4=)](https://astronachos.com/)
[![Mastodon](https://img.shields.io/badge/mastodon-gray?&logo=mastodon)](https://mastodon.gamedev.place/@astronachos)
[![Twitter](https://img.shields.io/badge/twitter-gray?&logo=twitter)](https://twitter.com/astronachos)
[![Telegram](https://img.shields.io/badge/telegram-gray?&logo=telegram)](https://t.me/astronachos)
[![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-gray?&logo=buy%20me%20a%20coffee)](https://buymeacoffee.com/astrochili)

A set of Lua scripts for parsing [Defold](https://defold.com) documentation and generating annotation files compatible with [Lua Language Server](https://github.com/LuaLS/lua-language-server) and [EmmyLua](https://emmylua.github.io/).

By design, it can be run on Windows, macOS and Linux. Only Lua needs to be installed. The Lua language was chosen because it allows all Defold users to contribute to this project.

Generated annotations are available on the [Releases](https://github.com/astrochili/defold-annotations/releases) page.

## Use case

These annotations are used by [Defold Kit](https://github.com/astrochili/vscode-defold), a Visual Studio Code extension for developing games with Defold.

## Automatic Releases

This repository has an [action workflow](https://github.com/astrochili/defold-annotations/actions/workflows/release.yml) that checks the latest version of Defold daily and automatically generates and releases the new version of annotations if required.

But if something goes wrong and edits are needed, there will be an additional manual update in the release.

## Manual Generation

Install [Lua](https://www.lua.org/) and run the `main.lua` script.

```sh
$ lua main.lua
```

By default it generates the annotations for the latest version of Defold. But you can also specify the Defold version as an argument.

```sh
$ lua main.lua '1.5.0'
```

As a result, you will see the `api` folder with `.lua` files. These are the annotations.

## Contribution

### Issues

If you find a typo in the annotations or outdated meta information, please first look for it in [Defold source code](https://github.com/defold/defold/tree/master/engine) and craete a pull request there as it's the main source of documentation.

Otherwise, on parsing and generation problems, open issues here.

### Debug

There is a launch config for [tomblind/local-lua-debugger-vscode](https://github.com/tomblind/local-lua-debugger-vscode) to debug with breakpoints.

It's also useful to turn the `config.clean_traces` to `true` in [`config.lua`](https://github.com/astrochili/defold-annotations/blob/639fa58f60687f0a40e702bc56196d0c0c73b5d5/src/config.lua#L15) file to avoid deleting temporary files.

## Third-party

- [json.lua](https://github.com/rxi/json.lua) by rxi
- [htmlEntities-for-lua](https://github.com/TiagoDanin/htmlEntities-for-lua) by Tiago Danin

## Alternatives

- [defold-api-emmylua](https://github.com/d954mas/defold-api-emmylua/) (Java) by Dmitry Popov
- [defold-lua-annotations](https://github.com/mikatuo/defold-lua-annotations/) (C#) by Dennis Shendrik