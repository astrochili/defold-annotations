--[[
  annotations.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

---@class module
---@field info info
---@field elements element[]

---@class info
---@field namespace string
---@field brief string
---@field description? string

---@class element
---@field type string
---@field name string
---@field description string
---@field parameters? parameter[]
---@field returnvalues? returnvalue[]
---@field alias? string
---@field fields? table

---@class parameter
---@field name string
---@field doc string

---@alias returnvalue parameter
