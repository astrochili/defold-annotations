# Defold Annotations

[![workflow](https://img.shields.io/github/actions/workflow/status/astrochili/defold-annotations/release.yml)](https://github.com/astrochili/defold-annotations/actions/workflows/release.yml) [![defold-annoptations](https://img.shields.io/github/v/release/astrochili/defold-annotations.svg?include_prereleases=&sort=semver&color=blue)](https://github.com/astrochili/defold-annotations/releases) [![mit-licence](https://img.shields.io/badge/License-MIT-blue)](https://github.com/astrochili/defold-annotations/blob/master/LICENCE)

A set of Lua scripts for parsing [Defold](https://defold.com) documentation and generating annotation files compatible with [Lua Language Server](https://github.com/LuaLS/lua-language-server) and [EmmyLua](https://emmylua.github.io/).

By design, it can be run on Windows, macOS and Linux. Only Lua needs to be installed. The Lua language was chosen because it allows all Defold users to contribute to this project.

Generated annotations are available on the [Releases](https://github.com/astrochili/defold-annotations/releases) page. 

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