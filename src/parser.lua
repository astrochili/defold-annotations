--[[
  parser.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local json = require 'libs.json'
local config = require 'src.config'
local utils = require 'src.utils'
local terminal = require 'src.terminal'

local parser = {}

--
-- Local

---Parse documentation file and create module object
---@param json_path string paths to the json file
---@return module? module Parsed documentation object
local function parse_path(json_path)
  local filename = json_path

  filename = filename:sub(#config.doc_folder + 2)
  filename = filename:sub(1, #filename - (1 + #config.json_extension)) or filename

  if utils.is_blacklisted(config.ignored_docs, filename) then
    print('[-] The file "' .. json_path .. '" is skipped because it\'s on the ignore list')
    return nil
  else
    local body = utils.read_file(json_path)
    return json.decode(body)
  end
end

--
-- Public

---Parse documentation files and create module objects
---@param json_paths string[] json_paths an array of paths to json files
---@return module[] modules Parsed documentation objects
function parser.parse_json(json_paths)
  print('-- Modules Parsing')

  local modules = {}

  for _, json_path in ipairs(json_paths) do
    local module = parse_path(json_path)

    if module then
      table.insert(modules, module)
    end
  end

  if config.clean_traces then
    terminal.delete_folder(config.doc_folder)
  end

  print('-- Modules Parsed Successfully!\n')
  return modules
end

return parser
