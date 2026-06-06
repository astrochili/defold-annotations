--[[
  generator.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local html_entities = require 'libs.html_entities'
local config = require 'src.config'
local diagnostics = require 'src.diagnostics'
local utils = require 'src.utils'
local terminal = require 'src.terminal'

local generator = {}

local namespace_constants = {}
local active_enum_registry = {
  alias_names = {},
  member_to_alias = {},
  aliases = {},
}
local active_generated_type_names = {}

local function trim(s)
  return (s or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

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

---Build a merge key for elements that should dedupe across doc sources.
---Elements are considered duplicates if type, name, parameter types, and optional flags match.
---@param element table
---@return string?
local function make_merge_key(element)
  if type(element) ~= "table" or not element.type or not element.name then
    return nil
  end

  local parts = { element.type, element.name }
  local parameters = element.parameters or {}

  for _, parameter in ipairs(parameters) do
    local types = parameter.types or {}
    table.insert(parts, table.concat(types, "|"))
    table.insert(parts, tostring(parameter.is_optional))
  end

  return table.concat(parts, "\0")
end

---@param elements table[]
---@param merge_key string
---@return integer?
local function find_element_index_by_merge_key(elements, merge_key)
  for index, element in ipairs(elements) do
    if make_merge_key(element) == merge_key then
      return index
    end
  end

  return nil
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

---Extract the free-form text that appears before an html definition list.
---@param text string
---@return string
local function extract_doc_summary(text)
  local summary = text or ''
  local dl_start = summary:find('<dl>', 1, true)

  if dl_start then
    summary = summary:sub(1, dl_start - 1)
  end

  return trim(decode_text(summary))
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
  local ordered_names = {}

  for _, short_name in ipairs(constants.order) do
    table.insert(ordered_names, short_name)
  end

  table.sort(ordered_names)

  for _, short_name in ipairs(ordered_names) do
    local element = constants.items[short_name]

    if element.description and element.description ~= '' then
      table.insert(parts, make_comment(element.description))
    end

    local full_name = namespace .. '.' .. short_name
    local enum_alias = active_enum_registry.member_to_alias[full_name]
    local enum_info = enum_alias and active_enum_registry.aliases[enum_alias]
    local type_hint = (enum_info and enum_info.value_type) or element.constant_type or 'integer'
    table.insert(parts, '---@field ' .. short_name .. ' ' .. type_hint)
  end

  local text = table.concat(parts, '\n')
  return #text > 0 and (text .. '\n') or ''
end

---Make an annotatable namespace declaration.
---@param name string
---@return string
local function make_namespace(element)
  local name = element.name
  local result = ''

  result = result .. '---@class defold_api.' .. name .. '\n'
  result = result .. make_constant_fields(name)
  result = result .. name .. ' = {}'

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
    if element.constant_type == 'string' or element.constant_type == 'hash' then
      return
    end

    if type_name == 'integer' and element.constant_type ~= nil and element.constant_type ~= 'integer' then
      return
    end

    element.constant_type = type_name
  end
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
  local original_types = {}
  local fallback_is_string = false
  local fallback_is_hash = false

  local function make_type_context(subject_type, subject_name, unresolved_type)
    local module_name = element._module_namespace or '<unknown module>'
    local source_path = element._source_path and (' from "' .. element._source_path .. '"') or ''
    local target_name = element.name or '<unknown element>'

    return subject_type
      .. ' "' .. subject_name .. '" in "' .. target_name .. '"'
      .. ' (module "' .. module_name .. '")'
      .. source_path
      .. ' uses type "' .. unresolved_type .. '"'
  end

  ---Return true if a type string already looks like an annotation type expression.
  ---@param type string
  ---@return boolean
  local function is_annotation_type_expression(type)
    return type:sub(1, 9) == 'function('
      or type:sub(1, 1) == '{'
      or type:sub(1, 1) == '['
      or type:sub(1, 4) == 'fun('
      or type:find('[|<>%,%?]') ~= nil
      or type:find('%s') ~= nil
  end

  for index, type in ipairs(types) do
    if type:sub(1, 5) == 'type:' then
      type = type:sub(6)
      types[index] = type
    end

    original_types[index] = type

    if type == 'string' then
      fallback_is_string = true
    elseif type == 'hash' then
      fallback_is_hash = true
    end
  end

  ---Lookup a registered constant for a namespace.
  ---@param namespace string?
  ---@param short_name string?
  ---@return element?
  local function get_constant(namespace, short_name)
    local constants = namespace_constants[namespace]
    return constants and constants.items[short_name]
  end

  ---Return the primitive type for a known constant reference.
  ---@param full_name string
  ---@return string?
  local function get_constant_reference_type(full_name)
    local namespace, short_name = extract_namespace(full_name)

    if namespace and short_name then
      local constant = get_constant(namespace, short_name)
      if constant then
        return constant.constant_type or 'integer'
      end
    end

    return nil
  end

  ---Return the annotation type for an enum alias, including its primitive fallback.
  ---@param alias_name string
  ---@return string
  local function get_enum_annotation_type(alias_name)
    return alias_name
  end

  local fallback_type = 'integer'

  if fallback_is_string then
    fallback_type = 'string'
  elseif fallback_is_hash then
    fallback_type = 'hash'
  end

  for index, type in ipairs(original_types) do
    if type == 'constant' then
      types[index] = fallback_type
    elseif active_enum_registry.alias_names[type] then
      types[index] = get_enum_annotation_type(type)
    else
      local enum_alias = active_enum_registry.member_to_alias[type]
      if enum_alias then
        types[index] = get_enum_annotation_type(enum_alias)
      else
        local constant_reference_type = get_constant_reference_type(type)
        if constant_reference_type then
          diagnostics.report_error(
            'missing-enum-alias',
            'Constant type reference "' .. type .. '" is not mapped to an enum alias',
            {
              context = make_type_context(is_return and 'Return value' or 'Parameter', name, type),
              hint = 'Add an enum rule to rules/enums.lua, or add an explicit type replacement if this should stay primitive.',
            }
          )
          types[index] = constant_reference_type
        else
          types[index] = type
        end
      end
    end
  end

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

    is_known = is_known or active_generated_type_names[type] == true

    local known_aliases = utils.sorted_keys(config.known_aliases)
    for _, known_alias in ipairs(known_aliases) do
      is_known = is_known or type == known_alias
    end

    is_known = is_known or active_enum_registry.alias_names[type] == true

    if not is_known and is_annotation_type_expression(type) then
      is_known = true
    end

    if not is_known then
      types[index] = config.unknown_type
      diagnostics.report_error(
        'unknown-type',
        'Unknown type "' .. type .. '" was replaced with "' .. config.unknown_type .. '"',
        {
          context = make_type_context(is_return and 'Return value' or 'Parameter', name, type),
          hint = 'Add an entry to rules/replacements.lua, rules/aliases.lua, rules/classes.lua, or rules/enums.lua.',
        }
      )
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

---Parse html definition list entries like `<dt><code>id</code></dt><dd><span class="type">hash</span> ...</dd>`.
---@param text string
---@return table[] fields
local function parse_doc_fields(text)
  local fields = {}
  local source = text or ''

  for raw_name, raw_type, raw_description in source:gmatch('<dt><code>(.-)</code></dt>%s*<dd><span class="type">(.-)</span>%s*(.-)</dd>') do
    table.insert(fields, {
      name = trim(decode_text(raw_name)),
      type = trim(decode_text(raw_type)),
      description = trim(decode_text(raw_description)),
      raw_description = raw_description,
    })
  end

  return fields
end

---@param field_name string
---@param type_name string
---@param description string
---@param element element
---@param known_generated_names table<string, boolean>?
---@return string
local function make_class_field_type(field_name, type_name, description, element, known_generated_names)
  local field_type = type_name

  if not (known_generated_names and known_generated_names[type_name]) then
    field_type = make_param_types(field_name, { type_name }, false, element, description)
  end

  local field_description = trim(description)

  if field_description ~= '' then
    return field_type .. ' ' .. field_description
  end

  return field_type
end

---Create synthetic classes for message payloads so they can be reused from callbacks and return values.
---@param module module
---@return element[]
local function make_message_classes(module)
  local classes = {}
  local module_namespace = module.info.namespace

  for _, message in ipairs(module.elements) do
    if message.type == 'MESSAGE' and message.parameters and #message.parameters > 0 then
      local class_name = 'message.' .. module_namespace .. '.' .. message.name
      local fields = {}
      local helper_classes = {}
      local generated_type_names = {
        [class_name] = true,
      }

      for _, parameter in ipairs(message.parameters) do
        local raw_type = parameter.types and parameter.types[1]

        if raw_type == 'table' and #parse_doc_fields(parameter.doc) > 0 then
          local helper_field_name = parameter.name:gsub('%.', '_'):gsub('-', '_')
          generated_type_names[class_name .. '.' .. helper_field_name] = true
        end
      end

      for _, parameter in ipairs(message.parameters) do
        local field_name = parameter.name
        if field_name:sub(-3) == '...' then
          field_name = '...'
        end
        field_name = field_name:gsub('-', '_')
        local raw_type = parameter.types and parameter.types[1]
        local nested_fields = raw_type == 'table' and parse_doc_fields(parameter.doc) or {}
        local is_optional = parameter.is_optional == 'True'
        local output_field_name = is_optional and (field_name .. '?') or field_name
        local description = extract_doc_summary(parameter.doc)

        if #nested_fields > 0 then
          local helper_class_name = class_name .. '.' .. field_name
          local helper_class_fields = {}

          for _, nested_field in ipairs(nested_fields) do
            helper_class_fields[nested_field.name] = make_class_field_type(
              nested_field.name,
              nested_field.type,
              nested_field.description,
              message,
              generated_type_names
            )
          end

          table.insert(helper_classes, {
            type = 'CLASS',
            name = helper_class_name,
            description = description,
            fields = helper_class_fields,
          })

          fields[output_field_name] = make_class_field_type(field_name, helper_class_name, description, message, generated_type_names)
        else
          fields[output_field_name] = make_class_field_type(
            field_name,
            table.concat(parameter.types or { config.unknown_type }, '|'),
            description,
            message,
            generated_type_names
          )
        end
      end

      table.insert(classes, {
        type = 'CLASS',
        name = class_name,
        brief = message.brief,
        description = message.description,
        fields = fields,
      })

      for _, helper_class in ipairs(helper_classes) do
        table.insert(classes, helper_class)
      end
    end
  end

  return classes
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
  if element.alias:sub(1, 1) == '\n' then
    return '---@alias ' .. element.name .. element.alias
  end

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
  local description = element.description or element.brief

  if description and description ~= '' then
    result = result .. make_comment(description) .. '\n'
  end

  result = result .. '---@class ' .. name .. '\n'

  local field_names = utils.sorted_keys(fields)
  for index, field_name in ipairs(field_names) do
    local field = fields[field_name]
    local field_type = field

    if type(field) == 'table' then
      field_type = field.type

      if field.description and field.description ~= '' then
        field_type = field_type .. ' ' .. field.description
      end
    end

    result = result .. '---@field ' .. field_name .. ' ' .. field_type

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

---Return all namespace prefixes for a full public name.
---@param name string
---@return string[]
local function get_namespace_prefixes(name)
  local prefixes = {}
  local current = ''

  for segment in name:gmatch('[^%.]+') do
    current = current == '' and segment or (current .. '.' .. segment)
    table.insert(prefixes, current)
  end

  table.remove(prefixes)

  return prefixes
end

---Create namespace elements inferred from public names in a module.
---@param module module
---@param root_namespaces table<string, boolean>
---@return element[]
local function make_namespace_elements(module, root_namespaces)
  local namespace_names = {}
  local root_namespace = module.info.namespace
  local has_root_namespace_content = false
  local declared_names = {}

  for _, element in ipairs(module.elements) do
    declared_names[element.name] = true
  end

  for _, element in ipairs(module.elements) do
    local prefixes = get_namespace_prefixes(element.name)

    for _, prefix in ipairs(prefixes) do
      if prefix == root_namespace then
        has_root_namespace_content = true
      end

      local is_message_namespace = prefix == 'message' or prefix:match('^message%.') ~= nil

      if not is_message_namespace and prefix ~= root_namespace and not declared_names[prefix] then
        local root_prefix = prefix:match('^[^%.]+')
        if not (prefix == root_prefix and root_namespaces[root_prefix]) then
          namespace_names[prefix] = true
        end
      end
    end
  end

  if root_namespace ~= '' and has_root_namespace_content then
    namespace_names[root_namespace] = true
  end

  local names = utils.sorted_keys(namespace_names)
  table.sort(names, function(a, b)
    local a_depth = select(2, a:gsub('%.', ''))
    local b_depth = select(2, b:gsub('%.', ''))

    if a_depth == b_depth then
      return a < b
    end

    return a_depth < b_depth
  end)

  local namespace_elements = {}
  for _, name in ipairs(names) do
    table.insert(namespace_elements, {
      type = 'NAMESPACE',
      name = name,
    })
  end

  return namespace_elements
end

---Generate API module with creating a .lua file
---@param module module
---@param root_namespaces table<string, boolean>
---@param defold_version string like '1.0.0'
local function generate_api(module, root_namespaces, defold_version)
  local elements = {}

  for _, element in ipairs(module.elements) do
    table.insert(elements, element)
  end

  for _, element in ipairs(make_message_classes(module)) do
    table.insert(elements, element)
  end

  for _, element in ipairs(elements) do
    element._module_namespace = module.info.namespace
  end

  active_generated_type_names = {}
  for _, element in ipairs(elements) do
    if element.type == 'CLASS' or element.type == 'ALIAS' or element.type == 'BASIC_CLASS' or element.type == 'BASIC_ALIAS' then
      active_generated_type_names[element.name] = true
    end
  end

  module = {
    info = module.info,
    elements = elements,
  }

  local content = make_header(defold_version, module.info.brief, module.info.description)
  content = content .. '\n\n'

  local makers = {
    NAMESPACE = make_namespace,
    FUNCTION = make_func,
    VARIABLE = make_var,
    CONSTANT = make_const,
    CLASS = make_class,
    ALIAS = make_alias,
    BASIC_CLASS = make_class,
    BASIC_ALIAS = make_alias,
  }

  local namespace_elements = make_namespace_elements(module, root_namespaces)
  local elements = {}

  for _, element in ipairs(module.elements) do
    if makers[element.type] ~= nil then
      table.insert(elements, element)
    end
  end

  table.sort(elements, function(a, b)
    local a_is_alias = a.type == 'ALIAS' or a.type == 'BASIC_ALIAS'
    local b_is_alias = b.type == 'ALIAS' or b.type == 'BASIC_ALIAS'
    local a_is_class = a.type == 'CLASS' or a.type == 'BASIC_CLASS'
    local b_is_class = b.type == 'CLASS' or b.type == 'BASIC_CLASS'

    if a_is_alias ~= b_is_alias then
      return a_is_alias
    end

    if a_is_class ~= b_is_class then
      return a_is_class
    end

    if a.name ~= b.name then
      return a.name < b.name
    end

    return a.type < b.type
  end)

  if #namespace_elements == 0 and #elements == 0 then
    print('[-] The module "' .. module.info.namespace .. '" is skipped because there are no known elements')
    return
  end

  local namespace_body = ''
  local regular_body = ''

  for index, element in ipairs(namespace_elements) do
    local maker = makers[element.type]
    local text = maker(element)

    if text then
      namespace_body = namespace_body .. text

      if index < #namespace_elements then
        namespace_body = namespace_body .. '\n\n'
      end
    end
  end

  for index, element in ipairs(elements) do
    local maker = makers[element.type]
    local text = maker(element)

    if text then
      regular_body = regular_body .. text

      if index < #elements then
        local newline = element.type == 'BASIC_ALIAS' and '\n' or '\n\n'
        regular_body = regular_body .. newline
      end
    end
  end

  local body = ''

  if #namespace_body > 0 and #regular_body > 0 then
    body = namespace_body .. '\n\n' .. regular_body
  else
    body = namespace_body .. regular_body
  end

  body = body:gsub('%s+$', '')

  content = content .. make_disabled_diagnostics(config.disabled_diagnostics) .. '\n\n'
  content = content .. body

  local api_path = utils.path(config.api_folder, module.info.namespace .. '.lua')
  utils.save_file(content, api_path)
end

---Reset cached constant tables
local function reset_namespace_data()
  namespace_constants = {}
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

--
-- Public

---Generate API modules with creating .lua files
---@param modules module[]
---@param defold_version string like '1.0.0'
function generator.generate_api(modules, defold_version, enum_registry)
  print('-- Annotations Generation')

  reset_namespace_data()
  active_enum_registry = enum_registry or {
    alias_names = {},
    member_to_alias = {},
    aliases = {},
  }
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
        local key = make_merge_key(element)
        local existing_index = key and find_element_index_by_merge_key(merged_module.elements, key) or nil

        if existing_index then
          merged_module.elements[existing_index] = element
        else
          table.insert(merged_module.elements, element)
        end
      end

      if module.info.description ~= module.info.brief then
        merged_module.info.description = module.info.description
      end
    else
      merged_modules[namespace] = module
    end
  end

  collect_constants(merged_modules)

  local root_namespaces = {}
  for namespace in pairs(merged_modules) do
    root_namespaces[namespace] = true
  end

  local namespaces = utils.sorted_keys(merged_modules)
  for index = #namespaces, 1, -1 do
    generate_api(merged_modules[namespaces[index]], root_namespaces, defold_version)
  end

  print('-- Annotations Generated Successfully!\n')
end

return generator
