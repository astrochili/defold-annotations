--[[
  types.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local config = require 'src.config'
local utils = require 'src.utils'

local types = {}

--
-- Public

---Create a helper module with aliases and classes used by other modules
---@return module module
function types.make_module()
  local types_module = {
    info = {
      namespace = 'types',
      brief = 'Known classes and aliases used in the Defold API'
    },
    elements = {}
  }

  local class_names = utils.sorted_keys(config.known_classes)
  for _, class_name in ipairs(class_names) do
    local known_class = config.known_classes[class_name]

    local element = {
      type = 'BASIC_CLASS',
      name = class_name,
      fields = known_class.fields or known_class,
      operators = known_class.operators
    }

    table.insert(types_module.elements, element)
  end

  local alias_names = utils.sorted_keys(config.known_aliases)
  for _, alias_name in ipairs(alias_names) do
    local element = {
      type = 'BASIC_ALIAS',
      name = alias_name,
      alias = config.known_aliases[alias_name]
    }

    table.insert(types_module.elements, element)
  end

  return types_module
end

return types
