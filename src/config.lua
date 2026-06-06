--[[
  config.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local utils = require 'src.utils'
local aliases = require 'rules.aliases'
local classes = require 'rules.classes'
local disabled_diagnostics = require 'rules.disabled_diagnostics'
local generics = require 'rules.generics'
local replacements = require 'rules.replacements'

local config = {}

---Folder separator
config.folder_separator = package.config:sub(1, 1)

---Name of the temporary folder
config.temp_folder = 'tmp'

function config.temp_path(filename)
  return utils.path(config.temp_folder, filename)
end

---Url of this project on github
config.generator_url = 'github.com/astrochili/defold-annotations'

---Url to find out the latest version of Defold
function config.info_url()
  return 'https://d.defold.com/stable/info.json'
end

---Temporary path to the info about the letest version
config.info_json = config.temp_path('info.json')

---Url to find out the documentation archive
function config.doc_url(version)
  return 'https://github.com/defold/defold/releases/download/' .. version .. '/ref-doc.zip'
end

---Temporary path to the documentation archive
config.doc_zip = config.temp_path('ref-doc.zip')

---Name of the unpacked doc folder
config.doc_folder = config.temp_path('doc')

---Json extension
config.json_extension = 'json'

---Name of a temporary text file with paths to json files
config.json_list_txt = config.temp_path('json_list.txt')

---Name of the output folder
config.api_folder = config.temp_path('defold_api')

---Ignored functions
---Possible to use suffix `*`
config.ignored_funcs = {
  'init',
  'update',
  'fixed_update',
  'on_input',
  'on_message',
  'on_reload',
  'final',
  'client:*',
  'server:*',
  'master:*',
  'connected:*',
  'unconnected:*'
}

---Default type for unknown types
config.unknown_type = 'unknown'

---Known types
config.known_types = {
  'nil',
  'any',
  'boolean',
  'number',
  'integer',
  'string',
  'userdata',
  'function',
  'thread',
  'table'
}

config.global_type_replacements = replacements
config.generics = generics
config.known_classes = classes
config.known_aliases = aliases
config.disabled_diagnostics = disabled_diagnostics

return config
