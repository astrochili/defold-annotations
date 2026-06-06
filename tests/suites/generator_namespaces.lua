local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

return {
  name = 'generator_namespaces',
  cases = {
    {
      name = 'generates namespace tables and keeps alias ordering',
      run = function()
        local app = helper.load_app()
        local modules = helper.load_fixture_module('namespace_module.lua')
        local result = {}

        app.diagnostics.reset()
        helper.with_temp_config(app.config, 'generator-namespaces', function()
          app.generator.generate_api(modules, 'test-version', {
            aliases = {},
            alias_names = {},
            member_to_alias = {},
            ordered_names = {},
          })
          result = helper.read_generated(app.config.api_folder)
        end)

        local output = result['demo.lua']
        assertx.contains(output, '---@class defold_api.demo')
        assertx.contains(output, '---@class defold_api.demo.tools')
        assertx.contains(output, '---@field FLAG integer')
        assertx.truthy(output:find('---@alias demo%.Mode integer', 1, false) < output:find('---@class demo%.Record', 1, false))
        assertx.truthy(output:find('---@class demo%.Record', 1, false) < output:find('function demo%.run', 1, false))
      end,
    },
  },
}
