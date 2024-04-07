--[[
  utils.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local utils = {}

--
-- Public

---Save the content to the file
---@param content string content of the file
---@param path string path to the file
---@return boolean? result
function utils.save_file(content, path)
  local file = io.open(path, 'w')

  if file == nil then
    assert(file, 'Can\'t save a file at path: "' .. path .. '"')
    return false
  end

  assert(file:write(content), 'Error during writing to the file "' .. path .. '"')
  print('The file "' .. path .. '" has been successfully created')

  return file:close()
end

---Read the content from the file
---@param path string path to the file
---@return string content content of the file
function utils.read_file(path)
  local file = io.open(path, 'r')
  assert(file, 'File doesn\'t exist: "' .. path .. '"')

  local content = file:read('*a')
  print('The file "' .. path .. '" has been successfully read')
  file:close()

  return content
end

---Get array of lines from the string
---@param content string
---@return string[] lines
function utils.get_lines(content)
  local lines = {}

  for line in content:gmatch '[^\r\n]+' do
    table.insert(lines, line)
  end

  return lines
end

---Get sorted keys of the table
---@param dictionary table
---@return string[]
function utils.sorted_keys(dictionary)
  local keys = {}

  for key in pairs(dictionary) do
    table.insert(keys, key)
  end

  table.sort(keys)

  return keys
end

---Check if an item is present in the black list, including by the `*` suffix rule.
---@param list string[]
---@param item string
---@return boolean is_blacklisted
function utils.is_blacklisted(list, item)
  for _, list_element in ipairs(list) do
    if list_element:sub(-1) == '*' then
      local list_prefix = list_element:sub(1, #list_element - 1)

      if item:sub(1, #list_prefix) == list_prefix then
        return true
      end
    elseif item == list_element then
      return true
    end
  end

  return false
end

return utils
