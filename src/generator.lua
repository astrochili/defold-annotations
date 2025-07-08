--[[
  generator.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local html_entities = require 'libs.html_entities'
local config = require 'src.config'
local utils = require 'src.utils'
local terminal = require 'src.terminal'

local generator = {}

--
-- Local

---Decode text to get rid of html tags and entities
---@param text string
---@return string
local function decode_text(text)
  local result = text:gsub('%b<>', '')
  local decoded_result = html_entities.decode(result)

  if type(decoded_result) == 'string' then
    result = decoded_result
  end

  return result
end

---Make an annotable comment
---@param text string
---@param tab? string Indent string, default is '---'
---@return string
local function make_comment(text, tab)
  local tab = tab or '---'
  local text = decode_text(text or '')

  local lines = text == '' and { text } or utils.get_lines(text)
  local result = ''

  for index, line in ipairs(lines) do
    result = result .. tab .. line

    if index < #lines then
      result = result .. '\n'
    end
  end

  return result
end

---Make an annotable module header
---@param defold_version string
---@param title string
---@param description string
---@return string
local function make_header(defold_version, title, description)
  local result = ''

  result = result .. '--[[\n'
  result = result .. '  Generated with ' .. config.generator_url .. '\n'
  result = result .. '  Defold ' .. defold_version .. '\n\n'
  result = result .. '  ' .. decode_text(title) .. '\n'

  if description and description ~= title then
    result = result .. '\n'
    result = result .. make_comment(description, '  ') .. '\n'
  end

  result = result .. '--]]'

  return result
end

---Make annotable diagnostic disable flags
---@param disabled_diagnostics string[] list of diagnostic disabel flags
---@return string
local function make_disabled_diagnostics(disabled_diagnostics)
  local result = ''

  result = result .. '---@meta\n'

  for index, disabled_diagnostic in ipairs(disabled_diagnostics) do
    result = result .. '---@diagnostic disable: ' .. disabled_diagnostic

    if index < #config.disabled_diagnostics then
      result = result .. '\n'
    end
  end

  return result
end

---Wrap the class body to an annotable namespace
---@param name string
---@param body string
---@return string
local function make_namespace(name, body)
  local result = ''

  result = result .. '---@class defold_api.' .. name .. '\n'
  result = result .. name .. ' = {}\n\n'
  result = result .. body .. '\n\n'
  result = result .. 'return ' .. name

  return result
end

---Make an annotatable constant
---@param element element
---@return string
local function make_const(element)
  local result = ''

  result = result .. make_comment(element.description) .. '\n'
  result = result .. element.name .. ' = nil'

  return result
end

---Make an annotatable param name
---@param parameter table
---@param is_return boolean
---@param element element
---@return string name
local function make_param_name(parameter, is_return, element)
  local name = parameter.name
  name = config.global_name_replacements[name] or name

  local local_replacements = config.local_name_replacements[element.name] or {}
  name = local_replacements[(is_return and 'return_' or 'param_') .. name] or name

  if name:sub(-3) == '...' then
    name = '...'
  end

  name = name:gsub('-', '_')

  return name
end

---Make annotatable param types
---@param name string
---@param types table
---@param is_return boolean
---@param element element
---@return string concated_string
local function make_param_types(name, types, is_return, element)
  local local_replacements = config.local_type_replacements[element.name] or {}

  for index = 1, #types do
    local type = types[index]
    local is_known = false
    local replacement

    for key, value in pairs(config.global_type_replacements) do
      if utils.match(type, key) then
        replacement = value
      end
    end

    replacement = local_replacements[(is_return and 'return_' or 'param_') .. type .. '_' .. name] or replacement

    if replacement then
      type = replacement
      is_known = true
    end

    for _, known_type in ipairs(config.known_types) do
      is_known = is_known or type == known_type
    end

    local known_classes = utils.sorted_keys(config.known_classes)
    for _, known_class in ipairs(known_classes) do
      is_known = is_known or type == known_class
    end

    local known_aliases = utils.sorted_keys(config.known_aliases)
    for _, known_alias in ipairs(known_aliases) do
      is_known = is_known or type == known_alias
    end

    is_known = is_known or type:sub(1, 9) == 'function('

    if not is_known then
      types[index] = config.unknown_type

      if os.getenv('LOCAL_LUA_DEBUGGER_VSCODE') == '1' then
        assert(nil, 'Unknown type `' .. type .. '`')
      else
        print('!!! WARNING: Unknown type `' .. type .. '` has been replaced with `' .. config.unknown_type .. '`')
      end
    else
      type = type:gsub('function%(%)', 'function')

      if type:sub(1, 9) == 'function(' then
        type = 'fun' .. type:sub(9)
      end

      types[index] = type
    end
  end

  local result = table.concat(utils.unique(types), '|')
  result = #result > 0 and result or config.unknown_type

  return result
end

---Make an annotable param description
---@param description string
---@return string
local function make_param_description(description)
  local result = decode_text(description)
  result = result:gsub('^%s+', '')
  result = result:gsub('\n', '\n---')
  return result
end

---Make annotable param line
---@param parameter table
---@param element element
---@return string
local function make_param(parameter, element)
  local name = make_param_name(parameter, false, element)
  local is_optional = parameter.is_optional == 'True'
  local joined_types = make_param_types(name, parameter.types, false, element)
  local description = make_param_description(parameter.doc)

  return '---@param ' .. name .. (is_optional and '? ' or ' ') .. joined_types .. ' ' .. description
end

---Make an annotable return line
---@param returnvalue table
---@param element element
---@return string
local function make_return(returnvalue, element)
  local name = make_param_name(returnvalue, true, element)
  local types = make_param_types(name, returnvalue.types, true, element)
  local description = make_param_description(returnvalue.doc)

  return '---@return ' .. types .. ' ' .. name .. ' ' .. description
end

---Make annotable func lines
---@param element element
---@return string?
local function make_func(element)
  if utils.is_blacklisted(config.ignored_funcs, element.name) then
    return
  end

  local comment = make_comment(element.description) .. '\n'

  local generic = config.generics[element.name]
  local generic_occuriences = 0

  local params = ''
  for _, parameter in ipairs(element.parameters) do
    local param = make_param(parameter, element)
    local count = 0

    if generic then
      param, count = param:gsub(' ' .. generic .. ' ', ' T ')
      generic_occuriences = generic_occuriences + count
    end

    params = params .. param .. '\n'
  end

  local returns = ''
  for _, returnvalue in ipairs(element.returnvalues) do
    local return_ = make_return(returnvalue, element)
    local count = 0

    if generic then
      return_, count = return_:gsub(' ' .. generic .. ' ', ' T ')
      generic_occuriences = generic_occuriences + count
    end

    returns = returns .. return_ .. '\n'
  end

  if generic_occuriences >= 2 then
    generic = ('---@generic T: ' .. generic .. '\n')
  else
    generic = ''
  end

  local func_params = {}

  for _, parameter in ipairs(element.parameters) do
    local name = make_param_name(parameter, false, element)
    table.insert(func_params, name)
  end

  local func = 'function ' .. element.name .. '(' .. table.concat(func_params, ', ') .. ') end'
  local result = comment .. generic .. params .. returns .. func

  return result
end

---Make an annotable alias
---@param element element
---@return string
local function make_alias(element)
  return '---@alias ' .. element.name .. ' ' .. element.alias
end

---Make an annnotable class declaration
---@param element element
---@return string
local function make_class(element)
  local name = element.name
  local fields = element.fields
  assert(fields)

  local result = ''
  result = result .. '---@class ' .. name .. '\n'

  if fields.is_global == true then
    fields.is_global = nil
    result = result .. name .. ' = {}'
  end

  local field_names = utils.sorted_keys(fields)
  for index, field_name in ipairs(field_names) do
    local type = fields[field_name]

    result = result .. '---@field ' .. field_name .. ' ' .. type

    if index < #field_names then
      result = result .. '\n'
    end
  end

  local operators = element.operators

  if operators then
    local operator_names = utils.sorted_keys(operators)

    result = result .. '\n'

    for index, operator_name in ipairs(operator_names) do
      local operator = operators[operator_name]

      if operator.param then
        result = result .. '---@operator ' .. operator_name .. '(' .. operator.param .. '): ' .. operator.result
      else
        result = result .. '---@operator ' .. operator_name .. ': ' .. operator.result
      end

      if index < #operator_names then
        result = result .. '\n'
      end
    end
  end

  return result
end

---Generate API module with creating a .lua file
---@param module module
---@param defold_version string like '1.0.0'
local function generate_api(module, defold_version)
  local content = make_header(defold_version, module.info.brief, module.info.description)
  content = content .. '\n\n'

  local makers = {
    FUNCTION = make_func,
    VARIABLE = make_const,
    CONSTANT = make_const,
    BASIC_CLASS = make_class,
    BASIC_ALIAS = make_alias
  }

  local elements = {}
  local namespace_is_required = false

  for _, element in ipairs(module.elements) do
    if makers[element.type] ~= nil then
      table.insert(elements, element)
    end

    if not namespace_is_required then
      local element_has_namespace = element.name:sub(1, #module.info.namespace) == module.info.namespace
      namespace_is_required = element_has_namespace
    end
  end

  if #elements == 0 then
    print('[-] The module "' .. module.info.namespace .. '" is skipped because there are no known elements')
    return
  end

  table.sort(elements, function(a, b)
    if a.type == b.type then
      return a.name < b.name
    else
      return a.type > b.type
    end
  end)

  local body = ''

  for index, element in ipairs(elements) do
    local maker = makers[element.type]
    local text = maker(element)

    if text then
      body = body .. text

      if index < #elements then
        local newline = element.type == 'BASIC_ALIAS' and '\n' or '\n\n'
        body = body .. newline
      end
    end
  end

  content = content .. make_disabled_diagnostics(config.disabled_diagnostics) .. '\n\n'

  if namespace_is_required then
    content = content .. make_namespace(module.info.namespace, body)
  else
    content = content .. body
  end

  local api_path = config.api_folder .. config.folder_separator .. module.info.namespace .. '.lua'
  utils.save_file(content, api_path)
end

--
-- Public

---Generate API modules with creating .lua files
---@param modules module[]
---@param defold_version string like '1.0.0'
function generator.generate_api(modules, defold_version)
  print('-- Annotations Generation')

  terminal.delete_folder(config.api_folder)
  terminal.create_folder(config.api_folder)

  local merged_modules = {}

  for _, module in ipairs(modules) do
    local namespace = module.info.namespace
    local merged_module = merged_modules[namespace]

    if merged_module then
      for _, element in ipairs(module.elements) do
        table.insert(merged_module.elements, element)
      end

      if module.info.description ~= module.info.brief then
        merged_module.info.description = module.info.description
      end
    else
      merged_modules[namespace] = module
    end
  end

  for _, module in pairs(merged_modules) do
    generate_api(module, defold_version)
  end

  print('-- Annotations Generated Successfully!\n')
end

return generator
