local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

local rules = {
  aliases = {
    ['b2d.body'] = 'userdata',
    bool = 'boolean',
  },
  classes = {
    vector3 = { x = 'number', y = 'number', z = 'number' },
    url = { socket = 'hash', path = 'hash', fragment = 'hash' },
    ['resource.entry'] = {
      id = 'hash',
    },
  },
  disabled_diagnostics = {},
  enums = {
    { name = 'go.PLAYBACK', members = { 'go.PLAYBACK_LOOP_FORWARD', 'go.PLAYBACK_ONCE_FORWARD' } },
    { name = 'physics.JOINT_TYPE', members = { 'physics.JOINT_TYPE_FIXED', 'physics.JOINT_TYPE_SPRING' } },
    { name = 'physics.SHAPE_TYPE', members = { 'physics.SHAPE_TYPE_BOX', 'physics.SHAPE_TYPE_SPHERE' } },
    { name = 'b2d.body.B2', members = { 'b2d.body.B2_DYNAMIC_BODY', 'b2d.body.B2_STATIC_BODY' } },
  },
  generics = {},
  ignored_funcs = {},
  known_types = { 'nil', 'boolean', 'number', 'integer', 'string', 'hash', 'userdata', 'table' },
  replacements = {},
}

return {
  name = 'integration',
  cases = {
    {
      name = 'runs the miniature pipeline end to end',
      run = function()
        local result = helper.run_pipeline({
          name = 'integration',
          docs_dir = 'integration',
          patch_files = {
            'test-sprite_doc.lua',
            'test-sound_doc.lua',
            'test-model_doc.lua',
            'test-physics_doc.lua',
          },
          rules = rules,
          include_meta = true,
        })

        assertx.same_keys(result.outputs, {
          'b2d.body.lua',
          'go.lua',
          'meta.lua',
          'model.lua',
          'physics.lua',
          'sound.lua',
          'sprite.lua',
        })
        assertx.contains(result.outputs['go.lua'], '---@alias go.PLAYBACK integer')
        assertx.contains(result.outputs['physics.lua'], '---@class message.physics.ray_cast_response')
        assertx.contains(result.outputs['meta.lua'], '---@class vector3')
        assertx.equal(#result.errors, 0)
      end,
    },
  },
}
