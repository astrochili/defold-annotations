require 'tests.annotations'

local suites = require 'tests.suites'

local total = 0
local failed = 0

for suite_index = 1, #suites do
  local suite = suites[suite_index]

  for case_index = 1, #(suite.cases or {}) do
    local case = suite.cases[case_index]
    total = total + 1
    local ok, err = pcall(case.run)

    if ok then
      print('PASS ' .. suite.name .. ' :: ' .. case.name)
    else
      failed = failed + 1
      print('FAIL ' .. suite.name .. ' :: ' .. case.name)
      print(err)
    end
  end
end

print(string.format('TOTAL %d  PASS %d  FAIL %d', total, total - failed, failed))

if failed > 0 then
  os.exit(1)
end
