local M = {}

local function render(value)
  if type(value) == 'string' then
    return string.format('%q', value)
  end

  return tostring(value)
end

local function fail(message, level)
  error(message, (level or 1) + 1)
end

function M.equal(actual, expected, message)
  if actual ~= expected then
    fail((message or 'Values are not equal') .. ': expected ' .. render(expected) .. ', got ' .. render(actual), 2)
  end
end

function M.truthy(value, message)
  if not value then
    fail(message or 'Expected value to be truthy', 2)
  end
end

function M.contains(haystack, needle, message)
  if not haystack:find(needle, 1, true) then
    fail((message or 'Expected string to contain fragment') .. ': ' .. render(needle), 2)
  end
end

function M.not_contains(haystack, needle, message)
  if haystack:find(needle, 1, true) then
    fail((message or 'Expected string to not contain fragment') .. ': ' .. render(needle), 2)
  end
end

function M.same_keys(actual, expected, message)
  local function join(values)
    table.sort(values)
    return table.concat(values, ', ')
  end

  local actual_keys = {}
  for key in pairs(actual) do
    table.insert(actual_keys, key)
  end

  local expected_keys = {}
  for _, key in ipairs(expected) do
    table.insert(expected_keys, key)
  end

  if #actual_keys ~= #expected_keys or join(actual_keys) ~= join(expected_keys) then
    fail((message or 'Expected key sets to match') .. ': expected [' .. join(expected_keys) .. '], got [' .. join(actual_keys) .. ']', 2)
  end
end

function M.raises(fn, needle, message)
  local ok, err = pcall(fn)
  if ok then
    fail(message or 'Expected function to fail', 2)
  end

  if needle and not tostring(err):find(needle, 1, true) then
    fail((message or 'Unexpected error') .. ': ' .. tostring(err), 2)
  end

  return err
end

return M
