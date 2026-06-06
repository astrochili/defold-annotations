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

local function run()
  diagnostics.reset()

  -- Prepare a temporary folder
  terminal.delete_folder(config.temp_folder)
  terminal.create_folder(config.temp_folder)

  -- Fetch the Defold version
  local defold_version = arg[1] or fetcher.fetch_version()

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
