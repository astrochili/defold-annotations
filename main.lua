--[[
  main.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local config = require 'src.config'
local terminal = require 'src.terminal'
local fetcher = require 'src.fetcher'
local parser = require 'src.parser'
local patcher = require 'src.patcher'
local enums = require 'src.enums'
local meta = require 'src.meta'
local generator = require 'src.generator'
local diagnostics = require 'src.diagnostics'

local function check_defold_version(version)
  local major, minor, patch = version:match('^(%d+)%.(%d+)%.(%d+)')
  major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)

  if major and (major > 1 or (major == 1 and (minor > 13 or (minor == 13 and patch > 1)))) then
    error(
      'Defold ' .. version .. ' is not supported. This generator supports Defold up to 1.13.1. ' ..
      'For Defold 1.13.2 and newer, use the official Lua annotations included in the editor ' ..
      'or the ref-doc.zip release asset at https://github.com/defold/defold/releases.',
      0
    )
  end
end

local function run()
  diagnostics.reset()

  -- Resolve and check the version before deleting previously generated annotations
  local defold_version = arg[1]
  if not defold_version then
    terminal.create_folder(config.temp_folder)
    defold_version = fetcher.fetch_version()
  end
  check_defold_version(defold_version)

  -- Prepare a temporary folder
  terminal.delete_folder(config.temp_folder)
  terminal.create_folder(config.temp_folder)

  -- Fetch docs from the Github release
  local json_paths = fetcher.fetch_docs(defold_version)

  -- Parse .json files to namespace modules
  local modules = parser.parse_json(json_paths)

  -- Apply module patches loaded from patches/
  patcher.patch_modules(modules)

  -- Build enum aliases from patched CONSTANT elements
  local enum_registry = enums.build_registry(modules)
  enums.inject_aliases(modules, enum_registry)
  diagnostics.fail_if_any('Enum validation failed')

  -- Append the known types and aliases module
  table.insert(modules, meta.make_module())

  -- Generate the API folder with .lua files
  generator.generate_api(modules, defold_version, enum_registry)
  diagnostics.fail_if_any('Annotation generation failed')
end

local ok, err = xpcall(run, debug.traceback)

if not ok then
  io.stderr:write(err .. '\n')
  os.exit(1)
end
