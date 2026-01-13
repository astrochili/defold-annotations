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

local namespace_constants = {}
local namespace_aliases = {}

--
-- Local

---Apply a list of inline tag rules, replacing html tags with their corresponding markdown syntax
---@param s string
---@param inline_rules table
---@return string
local function apply_inline_rules(s, inline_rules)
  for tag, rule in pairs(inline_rules) do
    local markdown = rule
    local wrap_both_sides = true

    if type(rule) == 'table' then
      markdown = rule.markdown
      wrap_both_sides = rule.wrap_both_sides
    end

    s = s:gsub('<' .. tag .. '>(.-)</' .. tag .. '>', function(inner)
      return wrap_both_sides and (markdown .. inner .. markdown) or (markdown .. inner)
    end)
  end

  return s
end

---Decode text to get rid of unnecessary html tags and entities
---@param text string
---@return string
local function decode_text(text)
  local result = text or ''

  local inline_tags = {
    code = '`',
    strong = '**',
    b = '**',
    em = '*',
    i = '*',
    li = { markdown = '- ', wrap_both_sides = false },
  }

  result = apply_inline_rules(result, inline_tags)

  -- Strip any remaining html tags
  result = result:gsub('%b<>', '')

  local decoded_result = html_entities.decode(result)

  if type(decoded_result) == 'string' then
    result = decoded_result
  end

  return result
end

---Make an annotatable comment
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

---Make an annotatable module header
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

---Make annotatable diagnostic disable flags
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

---Compose the namespace-level `---@field` entries for collected constants
---@param namespace string
---@return string
local function make_constant_fields(namespace)
  local constants = namespace_constants[namespace]

  if not constants then
    return ''
  end

  local parts = {}

  for _, short_name in ipairs(constants.order) do
    local element = constants.items[short_name]

    if element.description and element.description ~= '' then
      table.insert(parts, make_comment(element.description))
    end

    local type_hint = element.constant_type or 'integer'
    table.insert(parts, '---@field ' .. short_name .. ' ' .. type_hint)
  end

  local text = table.concat(parts, '\n')
  return #text > 0 and (text .. '\n') or ''
end

---Wrap the class body to an annotatable namespace
---@param name string
---@param body string
---@return string
local function make_namespace(name, body)
  local result = ''

  result = result .. '---@class defold_api.' .. name .. '\n'
  result = result .. make_constant_fields(name)
  result = result .. name .. ' = {}\n\n'
  result = result .. body .. '\n\n'
  result = result .. 'return ' .. name

  return result
end

---Constants are emitted as namespace fields and skipped here
---@param element element
---@return string
local function make_const(element)
  return nil
end

---Split `namespace.CONSTANT` into `namespace`, `CONSTANT`
---For multi-level namespaces like `b2d.body.B2_STATIC_BODY`, extracts the last component as the constant name
---@param name string
---@return string?, string?
local function extract_namespace(name)
  if not name then
    return nil, nil
  end

  -- Find the last dot to split namespace from constant name
  local last_dot = name:match('^.*()%.')
  if not last_dot then
    return nil, nil
  end
  
  local namespace = name:sub(1, last_dot - 1)
  local constant_name = name:sub(last_dot + 1)
  
  return namespace, constant_name
end

---Record a constant so it can be rendered once per namespace
---@param namespace string
---@param short_name string
---@param element element
local function register_constant(namespace, short_name, element)
  if not namespace or not short_name then
    return
  end

  namespace_constants[namespace] = namespace_constants[namespace] or { order = {}, items = {} }
  local constants = namespace_constants[namespace]

  if not constants.items[short_name] then
    constants.items[short_name] = element
    table.insert(constants.order, short_name)
  end
end

---Remember the type a constant should expose when rendered
---@param full_name string
---@param type_name string
local function set_constant_type(full_name, type_name)
  local namespace, short_name = extract_namespace(full_name)

  if not namespace or not short_name then
    return
  end

  local constants = namespace_constants[namespace]

  if not constants then
    return
  end

  local element = constants.items[short_name]

  if element then
    element.constant_type = type_name
  end
end

---Return true if an alias was already registered for the given type
---@param type string
---@return boolean
local function alias_is_registered(type)
  local namespace, alias_name = extract_namespace(type)

  if not namespace or not alias_name then
    return false
  end

  local aliases = namespace_aliases[namespace]
  return aliases and aliases[alias_name] ~= nil
end

---Register an alias for a namespace along with the constants it references
---@param namespace string
---@param alias_name string
---@param full_names string[]
local function register_alias(namespace, alias_name, full_names)
  namespace_aliases[namespace] = namespace_aliases[namespace] or {}
  local aliases = namespace_aliases[namespace]
  aliases[alias_name] = aliases[alias_name] or { order = {}, items = {} }
  local alias = aliases[alias_name]

  for _, full_name in ipairs(full_names) do
    if not alias.items[full_name] then
      alias.items[full_name] = true
      table.insert(alias.order, full_name)
    end
  end
end

---Render `---@alias` blocks for a namespace
---@param namespace string
---@return string
local function make_alias_lines(namespace)
  local aliases = namespace_aliases[namespace]

  if not aliases then
    return ''
  end

  local alias_names = utils.sorted_keys(aliases)
  local parts = {}

  for index, alias_name in ipairs(alias_names) do
    local alias = aliases[alias_name]
    table.insert(parts, '---@alias ' .. namespace .. '.' .. alias_name)

    local constants = {}

    for _, full_name in ipairs(alias.order) do
      table.insert(constants, full_name)
    end

    table.sort(constants)

    for _, full_name in ipairs(constants) do
      table.insert(parts, '---| `' .. full_name .. '`')
    end

    if index < #alias_names then
      table.insert(parts, '')
    end
  end

  local text = table.concat(parts, '\n')
  return #text > 0 and text or ''
end

---Make an annotatable variable
---@param element element
---@return string
local function make_var(element)
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

---Make annotatable param types, deriving alias unions when constants are referenced
---@param name string
---@param types table
---@param is_return boolean
---@param element element
---@param description string?
---@return string concated_string
local function make_param_types(name, types, is_return, element, description)
  local local_replacements = config.local_type_replacements[element.name] or {}
  local original_types = {}
  local includes_constant_placeholder = false
  local fallback_is_string = false
  local fallback_is_hash = false

  for index, type in ipairs(types) do
    if type:sub(1, 5) == 'type:' then
      type = type:sub(6)
      types[index] = type
    end

    original_types[index] = type

    if type == 'constant' then
      includes_constant_placeholder = true
    elseif type == 'string' then
      fallback_is_string = true
    elseif type == 'hash' then
      fallback_is_hash = true
    end
  end

  ---Lookup a registered constant for a namespace
  ---@param namespace string?
  ---@param short_name string?
  ---@return element?
  local function get_constant(namespace, short_name)
    local constants = namespace_constants[namespace]
    return constants and constants.items[short_name]
  end

  ---Compute the common underscore-separated prefix for a batch of constant names
  ---@param short_names string[]
  ---@return string?
  local function get_common_prefix(short_names)
    if #short_names == 0 then
      return nil
    end

    local prefix_tokens

    for _, short_name in ipairs(short_names) do
      local tokens = {}

      for token in short_name:gmatch('[^_]+') do
        table.insert(tokens, token)
      end

      if not prefix_tokens then
        prefix_tokens = tokens
      else
        local new_prefix = {}

        for index = 1, math.min(#prefix_tokens, #tokens) do
          if prefix_tokens[index] == tokens[index] then
            table.insert(new_prefix, prefix_tokens[index])
          else
            break
          end
        end

        prefix_tokens = new_prefix
      end

      if not prefix_tokens or #prefix_tokens == 0 then
        break
      end
    end

    if prefix_tokens and #prefix_tokens > 0 then
      return table.concat(prefix_tokens, '_')
    end

    return nil
  end

  local constant_map = {}

  ---Register that a constant was referenced by a parameter/return description
  ---@param full_name string
  ---@return boolean
  local function add_constant_usage(full_name)
    local namespace, short_name = extract_namespace(full_name)

    if namespace and short_name and get_constant(namespace, short_name) then
      constant_map[namespace] = constant_map[namespace] or { shorts = {}, short_lookup = {}, fulls = {} }
      local entry = constant_map[namespace]

      if not entry.short_lookup[short_name] then
        table.insert(entry.shorts, short_name)
        entry.short_lookup[short_name] = true
      end

      entry.fulls[full_name] = short_name
      return true
    end

    return false
  end

  for _, type in ipairs(original_types) do
    local namespace, short_name = extract_namespace(type)

    if type ~= 'constant' and namespace and short_name then
      add_constant_usage(type)
    end
  end

  if includes_constant_placeholder and description then
    for namespace, raw_short_name in description:gmatch('([%w_]+)%.([%w_%*]+)') do
      if raw_short_name:find('%*') then
        local prefix = raw_short_name:gsub('%*', '')
        local constants = namespace_constants[namespace]

        if constants then
          for short_name in pairs(constants.items) do
            if short_name:sub(1, #prefix) == prefix then
              add_constant_usage(namespace .. '.' .. short_name)
            end
          end
        end
      else
        add_constant_usage(namespace .. '.' .. raw_short_name)
      end
    end
  end

  local constant_aliases = {}
  local has_constant = false
  local pending_aliases = {}
  local pending_alias_order = {}
  local constants_to_mark = {}
  local constants_to_mark_lookup = {}

  for namespace, data in pairs(constant_map) do
    local alias_name = get_common_prefix(data.shorts)

    if alias_name and #data.shorts >= 2 then
      local alias_full_name = namespace .. '.' .. alias_name
      if not pending_aliases[alias_full_name] then
        pending_aliases[alias_full_name] = true
        table.insert(pending_alias_order, alias_full_name)
      end
      local full_names = {}

      for full_name in pairs(data.fulls) do
        table.insert(full_names, full_name)
        constant_aliases[full_name] = alias_full_name

        if not constants_to_mark_lookup[full_name] then
          table.insert(constants_to_mark, full_name)
          constants_to_mark_lookup[full_name] = true
        end
      end

      register_alias(namespace, alias_name, full_names)
      has_constant = true
    end
  end

  local processed_types = {}
  local alias_added = {}

  for _, type in ipairs(original_types) do
    if type == 'constant' then
      if not has_constant then
        table.insert(processed_types, type)
      end
    else
      local alias_name = constant_aliases[type]

      if alias_name then
        if not alias_added[alias_name] then
          table.insert(processed_types, alias_name)
          alias_added[alias_name] = true
        end
      else
        table.insert(processed_types, type)
      end
    end
  end

  for _, alias_name in ipairs(pending_alias_order) do
    if not alias_added[alias_name] then
      table.insert(processed_types, alias_name)
      alias_added[alias_name] = true
    end
  end

  if has_constant then
    local fallback_type = 'integer'

    if fallback_is_string then
      fallback_type = 'string'
    elseif fallback_is_hash then
      fallback_type = 'hash'
    end

    table.insert(processed_types, fallback_type)

    for _, full_name in ipairs(constants_to_mark) do
      set_constant_type(full_name, fallback_type)
    end
  end

  types = processed_types

  for index = 1, #types do
    local type = types[index]
    if type:sub(1, 5) == 'type:' then
      type = type:sub(6)
    end
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

    if not is_known and alias_is_registered(type) then
      is_known = true
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

---Make an annotatable param description
---@param description string
---@return string
local function make_param_description(description)
  local result = decode_text(description)
  result = result:gsub('^%s+', '')
  result = result:gsub('\n', '\n---')
  return result
end

---Make annotatable param line
---@param parameter table
---@param element element
---@return string
local function make_param(parameter, element)
  local name = make_param_name(parameter, false, element)
  local is_optional = parameter.is_optional == 'True'
  local joined_types = make_param_types(name, parameter.types, false, element, parameter.doc)
  local description = make_param_description(parameter.doc)

  return '---@param ' .. name .. (is_optional and '? ' or ' ') .. joined_types .. ' ' .. description
end

---Make an annotatable return line
---@param returnvalue table
---@param element element
---@return string
local function make_return(returnvalue, element)
  local name = make_param_name(returnvalue, true, element)
  local types = make_param_types(name, returnvalue.types, true, element, returnvalue.doc)
  local description = make_param_description(returnvalue.doc)

  return '---@return ' .. types .. ' ' .. name .. ' ' .. description
end

---Make annotatable func lines
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

---Make an annotatable alias
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
    VARIABLE = make_var,
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

  local aliases = make_alias_lines(module.info.namespace)

  if #aliases > 0 then
    if #body > 0 then
      body = aliases .. '\n\n' .. body
    else
      body = aliases
    end
  end

  body = body:gsub('%s+$', '')

  content = content .. make_disabled_diagnostics(config.disabled_diagnostics) .. '\n\n'

  if namespace_is_required then
    content = content .. make_namespace(module.info.namespace, body)
  else
    content = content .. body
  end

  local api_path = config.api_folder .. config.folder_separator .. module.info.namespace .. '.lua'
  utils.save_file(content, api_path)
end

---Reset cached constant and alias tables
local function reset_namespace_data()
  namespace_constants = {}
  namespace_aliases = {}
end

---Scan all modules for constants so namespace fields can be emitted before generation
---@param modules table<string, module>
local function collect_constants(modules)
  for _, module in pairs(modules) do
    for _, element in ipairs(module.elements) do
      if element.type == 'CONSTANT' then
        local namespace, short_name = extract_namespace(element.name)
        register_constant(namespace, short_name, element)
      end
    end
  end
end

---Pre-generate aliases for constant groups with common prefixes
local function generate_constant_aliases()
  for namespace, constants in pairs(namespace_constants) do
    -- Collect all possible prefixes and their matching constants
    local prefix_to_constants = {}
    
    for _, short_name in ipairs(constants.order) do
      local tokens = {}
      for token in short_name:gmatch('[^_]+') do
        table.insert(tokens, token)
      end
      
      -- Generate all possible prefixes (1 to n-1 tokens)
      for len = 1, #tokens - 1 do
        local prefix_tokens = {}
        for i = 1, len do
          prefix_tokens[i] = tokens[i]
        end
        local prefix = table.concat(prefix_tokens, '_')
        
        -- Check if constant actually starts with this prefix followed by underscore
        if short_name:sub(1, #prefix + 1) == prefix .. '_' then
          if not prefix_to_constants[prefix] then
            prefix_to_constants[prefix] = {}
          end
          
          -- Add if not already present
          local found = false
          for _, existing in ipairs(prefix_to_constants[prefix]) do
            if existing == short_name then
              found = true
              break
            end
          end
          
          if not found then
            table.insert(prefix_to_constants[prefix], short_name)
          end
        end
      end
    end
    
    -- Sort prefixes by token count (prefer shorter = more general)
    local sorted_prefixes = {}
    for prefix, matching_constants in pairs(prefix_to_constants) do
      if #matching_constants >= 2 then
        table.insert(sorted_prefixes, {
          prefix = prefix,
          constants = matching_constants,
          token_count = select(2, prefix:gsub('_', '')) + 1
        })
      end
    end
    
    table.sort(sorted_prefixes, function(a, b)
      return a.token_count > b.token_count  -- Prefer longer (more specific) prefixes
    end)
    
    -- Register aliases, marking constants as used
    local used_constants = {}
    for _, entry in ipairs(sorted_prefixes) do
      local available = {}
      for _, short_name in ipairs(entry.constants) do
        if not used_constants[short_name] then
          table.insert(available, short_name)
        end
      end
      
      if #available >= 2 then
        local full_names = {}
        for _, short_name in ipairs(available) do
          table.insert(full_names, namespace .. '.' .. short_name)
          used_constants[short_name] = true
        end
        
        register_alias(namespace, entry.prefix, full_names)
      end
    end
  end
end

--
-- Public

---Generate API modules with creating .lua files
---@param modules module[]
---@param defold_version string like '1.0.0'
function generator.generate_api(modules, defold_version)
  print('-- Annotations Generation')

  reset_namespace_data()
  terminal.delete_folder(config.api_folder)
  terminal.create_folder(config.api_folder)

  local merged_modules = {}

  for _, module in ipairs(modules) do
    local namespace = module.info.namespace

    -- The `font` module doesn't have any meta values
    if #namespace == 0 and #module.elements > 0 then
      namespace = module.elements[1].name:match('([^%.]+)')
      module.info.namespace = namespace
    end

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

  collect_constants(merged_modules)
  generate_constant_aliases()

  for _, module in pairs(merged_modules) do
    generate_api(module, defold_version)
  end

  print('-- Annotations Generated Successfully!\n')
end

return generator
