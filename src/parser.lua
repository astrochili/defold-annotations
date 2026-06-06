--[[
  parser.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local json = require 'libs.json'
local std = require 'rules.std'
local utils = require 'src.utils'

local parser = {}

--
-- Public

---Parse documentation files and create module objects
---@param json_paths string[] json_paths an array of paths to json files
---@return module[] modules Parsed documentation objects
function parser.parse_json(json_paths)
  print('-- Modules Parsing')

  local modules = {}

  for _, json_path in ipairs(json_paths) do
    local body = utils.read_file(json_path)
    local module = json.decode(body)
    module._source_path = json_path

    if module.info.language:lower() == 'lua' then
      local elements = {}

      if not std[module.info.namespace] then
        for _, element in ipairs(module.elements) do
          element._source_path = json_path
          table.insert(elements, element)
        end

        if #elements > 0 or #module.info.namespace > 0 then
          module.elements = elements
          table.insert(modules, module)
        end
      end
    end
  end

  print('-- Modules Parsed Successfully!\n')
  return modules
end

return parser
