--[[
  enums.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local enum_rules = require 'rules.enums'
local diagnostics = require 'src.diagnostics'
local enums = {}

--
-- Local

---Split `namespace.CONSTANT` into `namespace`, `CONSTANT`.
---@param name string
---@return string?, string?
local function extract_namespace(name)
  if not name then
    return nil, nil
  end

  local last_dot = name:match('^.*()%.')
  if not last_dot then
    return nil, nil
  end

  return name:sub(1, last_dot - 1), name:sub(last_dot + 1)
end

---Collect constants from patched modules.
---@param modules module[]
---@return table<string, { order:string[], items:table<string, element> }>
local function collect_constants(modules)
  local constants_by_namespace = {}

  for _, module in ipairs(modules) do
    for _, element in ipairs(module.elements) do
      if element.type == 'CONSTANT' then
        local namespace, short_name = extract_namespace(element.name)

        if namespace and short_name then
          constants_by_namespace[namespace] = constants_by_namespace[namespace] or {
            order = {},
            items = {},
          }

          local namespace_constants = constants_by_namespace[namespace]

          if not namespace_constants.items[short_name] then
            namespace_constants.items[short_name] = element
            table.insert(namespace_constants.order, short_name)
          end
        end
      end
    end
  end

  return constants_by_namespace
end

---Return a primitive type for a constant element.
---@param constant element
---@return string
local function get_constant_type(constant)
  return constant.constant_type or 'integer'
end

---Infer enum members from a strict alias-name prefix.
---@param alias_name string
---@param constants_by_namespace table<string, { order:string[], items:table<string, element> }>
---@return string[] members
local function collect_auto_members(alias_name, constants_by_namespace)
  local namespace, short_alias_name = extract_namespace(alias_name)
  if not namespace or not short_alias_name then
    diagnostics.report_error(
      'invalid-enum-rule',
      'Enum rule "' .. tostring(alias_name) .. '" must use a fully-qualified alias name',
      { hint = 'Update rules/enums.lua so the alias looks like "namespace.ENUM_NAME"' }
    )
    return {}
  end

  local namespace_constants = constants_by_namespace[namespace]
  local members = {}
  local member_prefix = short_alias_name .. '_'

  if namespace_constants then
    for _, short_name in ipairs(namespace_constants.order) do
      if short_name:sub(1, #member_prefix) == member_prefix then
        table.insert(members, namespace .. '.' .. short_name)
      end
    end
  end

  table.sort(members)

  if #members == 0 then
    diagnostics.report_error(
      'missing-enum-members',
      'Enum rule "' .. alias_name .. '" has no matching constants in the current Defold docs',
      { hint = 'Defold likely changed constant names or added a new enum family. Update rules/enums.lua.' }
    )
  end

  return members
end

---Resolve enum members for a rule.
---@param rule string|table
---@param constants_by_namespace table<string, { order:string[], items:table<string, element> }>
---@return table
local function resolve_rule(rule, constants_by_namespace)
  if type(rule) == 'string' then
    return {
      name = rule,
      members = collect_auto_members(rule, constants_by_namespace),
    }
  end

  assert(type(rule) == 'table', 'Enum rule must be a string or table')
  assert(type(rule.name) == 'string', 'Enum rule table must contain `name`')

  local members
  if rule.members ~= nil then
    assert(type(rule.members) == 'table' and #rule.members > 0, 'Enum rule "' .. rule.name .. '" must contain non-empty `members`')
    members = {}
    for _, member in ipairs(rule.members) do
      table.insert(members, member)
    end
  else
    members = collect_auto_members(rule.name, constants_by_namespace)
  end

  return {
    name = rule.name,
    members = members,
    value_type = rule.value_type,
  }
end

---Infer the underlying primitive type for enum members.
---@param alias_name string
---@param members string[]
---@param constants_by_namespace table<string, { order:string[], items:table<string, element> }>
---@return string
local function validate_members(alias_name, members, constants_by_namespace)
  for _, member_name in ipairs(members) do
    local namespace, short_name = extract_namespace(member_name)
    local namespace_constants = namespace and constants_by_namespace[namespace]
    local constant = namespace_constants and namespace_constants.items[short_name]

    if not constant then
      diagnostics.report_error(
        'missing-enum-constant',
        'Enum rule "' .. alias_name .. '" references missing constant "' .. member_name .. '"',
        { hint = 'Update rules/enums.lua to match the constants shipped by the new Defold release.' }
      )
    end
  end
end

---Infer the underlying primitive type for enum members.
---@param alias_name string
---@param members string[]
---@param constants_by_namespace table<string, { order:string[], items:table<string, element> }>
---@return string
local function infer_value_type(alias_name, members, constants_by_namespace)
  local inferred_type

  for _, member_name in ipairs(members) do
    local namespace, short_name = extract_namespace(member_name)
    local namespace_constants = namespace and constants_by_namespace[namespace]
    local constant = namespace_constants and namespace_constants.items[short_name]
    if not constant then
      return inferred_type or 'integer'
    end

    local constant_type = get_constant_type(constant)
    if inferred_type == nil then
      inferred_type = constant_type
    else
      if inferred_type ~= constant_type then
        diagnostics.report_error(
          'mixed-enum-types',
          'Enum rule "' .. alias_name .. '" mixes constant types "' .. inferred_type .. '" and "' .. constant_type .. '"',
          { hint = 'Split the enum into separate aliases or override value_type explicitly in rules/enums.lua.' }
        )
      end
    end
  end

  return inferred_type or 'integer'
end

---Build an alias body for annotations output.
---@param value_type string
---@param members string[]
---@return string
local function make_alias_union(value_type, members)
  local lines = {}
  local result = value_type

  for _, member in ipairs(members) do
    table.insert(lines, '---| `' .. member .. '`')
  end

  return result .. '\n' .. table.concat(lines, '\n')
end

--
-- Public

---Build enum registry from patched modules and configured rules.
---@param modules module[]
---@return table
function enums.build_registry(modules)
  local constants_by_namespace = collect_constants(modules)
  local registry = {
    aliases = {},
    alias_names = {},
    member_to_alias = {},
    ordered_names = {},
  }

  for _, rule in ipairs(enum_rules) do
    local resolved_rule = resolve_rule(rule, constants_by_namespace)
    local alias_name = resolved_rule.name
    local members = resolved_rule.members
    validate_members(alias_name, members, constants_by_namespace)
    if #members > 0 then
      local value_type = resolved_rule.value_type or infer_value_type(alias_name, members, constants_by_namespace)

      registry.aliases[alias_name] = {
        name = alias_name,
        members = members,
        value_type = value_type,
      }
      registry.alias_names[alias_name] = true
      table.insert(registry.ordered_names, alias_name)

      for _, member in ipairs(members) do
        local existing_alias = registry.member_to_alias[member]
        if existing_alias ~= nil and existing_alias ~= alias_name then
          diagnostics.report_error(
            'duplicate-enum-member',
            'Constant "' .. member .. '" is assigned to multiple enum aliases: "' .. existing_alias .. '" and "' .. alias_name .. '"',
            { hint = 'Remove the duplicate mapping in rules/enums.lua.' }
          )
        else
          registry.member_to_alias[member] = alias_name
        end
      end
    end
  end

  return registry
end

---Inject generated enum alias elements into namespace modules.
---@param modules module[]
---@param registry table
function enums.inject_aliases(modules, registry)
  local first_module_by_namespace = {}
  local alias_elements_by_namespace = {}

  for _, module in ipairs(modules) do
    local namespace = module.info.namespace

    if namespace ~= '' and first_module_by_namespace[namespace] == nil then
      first_module_by_namespace[namespace] = module
    end
  end

  for _, alias_name in ipairs(registry.ordered_names) do
    local namespace = extract_namespace(alias_name)
    local alias = registry.aliases[alias_name]

    alias_elements_by_namespace[namespace] = alias_elements_by_namespace[namespace] or {}
    table.insert(alias_elements_by_namespace[namespace], {
      type = 'ALIAS',
      name = alias_name,
      alias = make_alias_union(alias.value_type, alias.members),
    })
  end

  for namespace, alias_elements in pairs(alias_elements_by_namespace) do
    local module = first_module_by_namespace[namespace]
    if not module then
      diagnostics.report_error(
        'missing-enum-namespace',
        'Generated enum alias namespace "' .. namespace .. '" has no target module in the current Defold docs',
        { hint = 'Check whether the module name changed in Defold or the enum rule points to the wrong namespace.' }
      )
    else
      local elements = {}
      for _, alias_element in ipairs(alias_elements) do
        table.insert(elements, alias_element)
      end
      for _, element in ipairs(module.elements) do
        table.insert(elements, element)
      end

      module.elements = elements
    end
  end
end

return enums
