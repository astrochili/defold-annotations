local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

local rules = {
  aliases = {
    ['b2d.body'] = 'userdata',
  },
  classes = {
    vector3 = { x = 'number', y = 'number', z = 'number' },
    url = { socket = 'hash', path = 'hash', fragment = 'hash' },
  },
  disabled_diagnostics = {},
  enums = {
    { name = 'go.PLAYBACK', members = { 'go.PLAYBACK_LOOP_FORWARD', 'go.PLAYBACK_ONCE_FORWARD' } },
    { name = 'physics.SHAPE_TYPE', members = { 'physics.SHAPE_TYPE_BOX', 'physics.SHAPE_TYPE_SPHERE' } },
    { name = 'b2d.body.B2', members = { 'b2d.body.B2_DYNAMIC_BODY', 'b2d.body.B2_STATIC_BODY' } },
  },
  generics = {},
  ignored_funcs = {},
  known_types = { 'nil', 'boolean', 'number', 'integer', 'string', 'hash', 'userdata', 'table' },
  replacements = {},
}

return {
  name = 'regressions',
  cases = {
    {
      name = 'guards historical output shape regressions',
      run = function()
        local result = helper.run_pipeline({
          name = 'regressions',
          docs_dir = 'integration',
          patch_files = {
            'test-sprite_doc.lua',
            'test-sound_doc.lua',
            'test-model_doc.lua',
            'test-physics_doc.lua',
          },
          rules = rules,
        })

        assertx.truthy(result.outputs['messages.lua'] == nil, 'messages.lua should not be generated')
        assertx.not_contains(result.outputs['sprite.lua'], 'sprite.message.')
        assertx.not_contains(result.outputs['physics.lua'], 'message = {}')
        assertx.not_contains(result.outputs['physics.lua'], 'defold_api.message')
        assertx.truthy(result.outputs['physics.lua']:find('---@class message.physics.ray_cast_response', 1, true) < result.outputs['physics.lua']:find('function physics.raycast', 1, true))
      end,
    },
  },
}
