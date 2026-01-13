package.path = table.concat({
  'tests/vendor/?.lua',
  'tests/?.lua',
  package.path
}, ';')

local luaunit = require 'luaunit'

require 'generator_alias_test'

os.exit(luaunit.LuaUnit.run())
