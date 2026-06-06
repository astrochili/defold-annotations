--[[
  diagnostics.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local diagnostics = {}

local issues = {}
local issue_keys = {}

local function escape_annotation(value)
  return tostring(value)
    :gsub('%%', '%%25')
    :gsub('\r', '%%0D')
    :gsub('\n', '%%0A')
    :gsub(':', '%%3A')
    :gsub(',', '%%2C')
end

local function normalize_text(value)
  if value == nil or value == '' then
    return nil
  end

  return tostring(value)
end

local function make_issue_key(code, message, context)
  return table.concat({
    tostring(code or ''),
    tostring(message or ''),
    tostring(context or ''),
  }, '\0')
end

function diagnostics.reset()
  issues = {}
  issue_keys = {}
end

---@param code string
---@param message string
---@param opts? { context?: string, hint?: string }
function diagnostics.report_error(code, message, opts)
  local context = opts and normalize_text(opts.context) or nil
  local hint = opts and normalize_text(opts.hint) or nil
  local key = make_issue_key(code, message, context)

  if issue_keys[key] then
    return
  end

  issue_keys[key] = true
  table.insert(issues, {
    code = code,
    message = message,
    context = context,
    hint = hint,
  })
end

function diagnostics.has_errors()
  return #issues > 0
end

function diagnostics.count()
  return #issues
end

---@return table[]
function diagnostics.get_errors()
  return issues
end

---@param summary? string
function diagnostics.fail_if_any(summary)
  if #issues == 0 then
    return
  end

  print('')
  print('-- Validation Errors')

  for index, issue in ipairs(issues) do
    print(string.format('%d. [%s] %s', index, issue.code, issue.message))

    if issue.context then
      print('   Context: ' .. issue.context)
    end

    if issue.hint then
      print('   Hint: ' .. issue.hint)
    end

    if os.getenv('GITHUB_ACTIONS') == 'true' then
      local annotation = issue.message

      if issue.context then
        annotation = annotation .. '\nContext: ' .. issue.context
      end

      if issue.hint then
        annotation = annotation .. '\nHint: ' .. issue.hint
      end

      print('::error title=' .. escape_annotation(issue.code) .. '::' .. escape_annotation(annotation))
    end
  end

  error(summary or ('Validation failed with ' .. #issues .. ' error(s)'), 0)
end

return diagnostics
