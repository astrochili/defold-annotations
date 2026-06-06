--[[
  patcher.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local utils = require 'src.utils'

local patcher = {}

--
-- Local

---Check whether a table behaves like an array.
---@param value table?
---@return boolean
local function is_array(value)
  return type(value) == 'table' and value[1] ~= nil
end

---Split a dotted path into segments.
---Supports escaping literal dots and backslashes with `\.` and `\\`.
---@param path string
---@return string[]
local function split_path(path)
  local segments = {}
  local segment = {}
  local escaped = false

  for i = 1, #path do
    local char = path:sub(i, i)

    if escaped then
      table.insert(segment, char)
      escaped = false
    elseif char == '\\' then
      escaped = true
    elseif char == '.' then
      table.insert(segments, table.concat(segment))
      segment = {}
    else
      table.insert(segment, char)
    end
  end

  if escaped then
    table.insert(segment, '\\')
  end

  table.insert(segments, table.concat(segment))

  return segments
end

---Resolve a dotted path to its parent node and key.
---@param node table|string|number|boolean|nil
---@param segments string[]
---@param index integer
---@param parent table|nil
---@param key string|number|nil
---@return table|nil resolved_parent
---@return string|number|nil resolved_key
---@return any resolved_node
local function resolve_ref(node, segments, index, parent, key)
  if index > #segments then
    return parent, key, node
  end

  if type(node) ~= 'table' then
    return nil
  end

  local segment = segments[index]

  local child = node[segment]

  if child ~= nil then
    local resolved_parent, resolved_key, resolved_node = resolve_ref(child, segments, index + 1, node, segment)

    if resolved_parent ~= nil then
      return resolved_parent, resolved_key, resolved_node
    end
  end

  if is_array(node) then
    for end_index = #segments, index, -1 do
      local candidate = table.concat(segments, '.', index, end_index)

      for child_index, item in ipairs(node) do
        if type(item) == 'table' then
          if item.name == candidate then
            local resolved_parent, resolved_key, resolved_node = resolve_ref(item, segments, end_index + 1, node, child_index)

            if resolved_parent ~= nil then
              return resolved_parent, resolved_key, resolved_node
            end
          end
        elseif type(item) == 'string' and item == candidate and end_index == #segments then
          return node, child_index, item
        end
      end
    end
  end

  return nil
end

---Load a patch table for a specific module if one exists.
---@param source_path string?
---@return table?
local function load_patch(source_path)
  if not source_path then
    return nil
  end

  local patch_file = source_path:match('([^/\\]+)$')

  if not patch_file then
    return nil
  end

  patch_file = patch_file:gsub('%.json$', '') .. '.lua'
  local patch_path = utils.path('patches', patch_file)

  if not utils.exists(patch_path) then
    return nil
  end

  local patch = dofile(patch_path)
  assert(type(patch) == 'table', 'Patch file "' .. patch_path .. '" must return a table')

  return patch
end

---Apply a flat path patch map to a parsed module.
---@param target table
---@param patch table
---@param source_path string?
local function apply_patch_map(target, patch, source_path)
  local paths = {}

  for path in pairs(patch) do
    if path ~= 'append' then
      table.insert(paths, path)
    end
  end

  table.sort(paths)

  for _, path in ipairs(paths) do
    local value = patch[path]
    local segments = split_path(path)
    local parent, key = resolve_ref(target, segments, 1, nil, nil)

    if parent == nil and #segments > 1 then
      local parent_segments = {}
      for i = 1, #segments - 1 do
        parent_segments[i] = segments[i]
      end

      local _, _, parent_node = resolve_ref(target, parent_segments, 1, nil, nil)
      if type(parent_node) == 'table' then
        parent = parent_node
        key = segments[#segments]
      end
    end

    assert(parent ~= nil, 'Patch path "' .. path .. '" could not be resolved in "' .. tostring(source_path) .. '"')
    local existing_value = parent[key]

    if is_array(existing_value) and type(value) ~= 'table' then
      parent[key] = { value }
    else
      parent[key] = value
    end
  end
end

---Append items to an existing array node resolved by path.
---@param target table
---@param append_map table<string, table>
---@param source_path string?
local function apply_append_map(target, append_map, source_path)
  local paths = {}

  for path in pairs(append_map) do
    table.insert(paths, path)
  end

  table.sort(paths)

  for _, path in ipairs(paths) do
    local values = append_map[path]
    assert(type(values) == 'table' and values[1] ~= nil, 'Append path "' .. path .. '" in "' .. tostring(source_path) .. '" must contain an array of items')

    local segments = split_path(path)
    local _, _, resolved_node = resolve_ref(target, segments, 1, nil, nil)

    assert(resolved_node ~= nil, 'Append path "' .. path .. '" could not be resolved in "' .. tostring(source_path) .. '"')
    assert(is_array(resolved_node), 'Append path "' .. path .. '" in "' .. tostring(source_path) .. '" must resolve to an array')

    for _, value in ipairs(values) do
      table.insert(resolved_node, value)
    end
  end
end

---Apply a patch to a parsed module.
---@param module module
local function apply_module_patch(module)
  local patch = load_patch(module._source_path)

  if not patch then
    return
  end

  apply_patch_map(module, patch, module._source_path)

  if patch.append ~= nil then
    assert(type(patch.append) == 'table', 'Patch field "append" in "' .. tostring(module._source_path) .. '" must be a table')
    apply_append_map(module, patch.append, module._source_path)
  end
end

--
-- Public

---Apply module patches loaded from patches/<doc-file>.lua
---@param modules module[]
function patcher.patch_modules(modules)
  print('-- Modules Patching')

  for _, module in ipairs(modules) do
    apply_module_patch(module)
  end

  print('-- Modules Patched Successfully!\n')
end

return patcher
