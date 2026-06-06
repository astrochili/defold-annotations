local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

local rules = {
  {
    name = 'render.CONTEXT_EVENT',
    members = {
      'render.CONTEXT_EVENT_LOST',
      'render.CONTEXT_EVENT_RESTORED',
    },
  },
}

return {
  name = 'enums',
  cases = {
    {
      name = 'builds registry and injects aliases',
      run = function()
        local app = helper.load_app({ enums = rules })
        local modules = helper.load_fixture_module('enum_modules.lua')

        app.diagnostics.reset()
        local registry = app.enums.build_registry(modules)
        app.enums.inject_aliases(modules, registry)

        assertx.equal(registry.aliases['render.CONTEXT_EVENT'].value_type, 'string')
        assertx.equal(registry.member_to_alias['render.CONTEXT_EVENT_LOST'], 'render.CONTEXT_EVENT')
        assertx.equal(modules[1].elements[1].type, 'ALIAS')
        assertx.contains(modules[1].elements[1].alias, 'render.CONTEXT_EVENT_LOST')
      end,
    },
  },
}
