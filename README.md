# Defold Annotations

A set of Lua scripts for parsing [Defold](https://defold.com) documentation and generating annotation files for [Lua Language Server](https://github.com/LuaLS/lua-language-server). The Lua language was chosen because it allows all Defold users to contribute to this project.

By design, it can be run on Windows, macOS and Linux. Only Lua needs to be installed.

## Quick Start

Install [Lua](https://www.lua.org/) and run the `main.lua` script.

```sh
$ lua main.lua
```

By default it generates the annotations for the latest version of Defold. But you can also specify the Defold version as an argument.

```sh
$ lua main.lua '1.5.0'
```

As a result, you will see the `api` folder with `.lua` files. These are the annotations.

## Automatic Releases

This repository has an [action workflow](https://github.com/astrochili/defold-annotations/actions/workflows/release.yml) that checks the latest version of Defold daily and automatically generates and releases the new version of annotations if required.

But if something goes wrong and edits are needed, there will be an additional manual release.

## Third-party

- [json.lua](https://github.com/rxi/json.lua) by rxi
- [htmlEntities-for-lua](https://github.com/TiagoDanin/htmlEntities-for-lua) by Tiago Danin

## Alternatives

- [defold-api-emmylua](https://github.com/d954mas/defold-api-emmylua/) (Java) by Dmitry Popov 
- [defold-lua-annotations](https://github.com/mikatuo/defold-lua-annotations/) (C#) by Dennis Shendrik