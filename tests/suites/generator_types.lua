local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

local rules = {
  aliases = {
    bool = 'boolean',
    quat = 'vector4',
  },
  classes = {
    vector3 = { x = 'number', y = 'number', z = 'number' },
    vector4 = { x = 'number', y = 'number', z = 'number', w = 'number' },
    url = { socket = 'hash', path = 'hash', fragment = 'hash' },
  },
  disabled_diagnostics = {},
  enums = {},
  generics = {
    ['mathx.mix'] = 'number|vector3',
  },
  ignored_funcs = {},
  known_types = { 'nil', 'boolean', 'number', 'integer', 'string', 'hash', 'userdata', 'table' },
  replacements = {
    quat = 'vector4',
  },
}

return {
  name = 'generator_types',
  cases = {
    {
      name = 'covers replacements generics unions callbacks and unknown fallback',
      run = function()
        local app = helper.load_app(rules)
        local modules = helper.load_fixture_module('type_module.lua')
        local outputs = {}

        app.diagnostics.reset()
        helper.with_temp_config(app.config, 'generator-types', function()
          app.generator.generate_api(modules, 'test-version', {
            aliases = {},
            alias_names = {},
            member_to_alias = {},
            ordered_names = {},
          })
          outputs = helper.read_generated(app.config.api_folder)
        end)

        local output = outputs['mathx.lua']
        assertx.contains(output, '---@generic T: number|vector3')
        assertx.contains(output, '---@param rotation vector4 Quaternion')
        assertx.contains(output, '---@param data { id:hash } Inline table')
        assertx.contains(output, '---@param callback fun(value:number):string Callback')
        assertx.contains(output, '---@param either mathx.LocalAlias Alias union')
        assertx.contains(output, '---@param items [hash] Array items')
        assertx.contains(output, '---@return mathx.LocalClass record Generated class')
        assertx.contains(output, '---@return unknown mystery Unknown type')
      end,
    },
  },
}
