local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

local rules = {
  aliases = {
    ['b2d.body'] = 'userdata',
    bool = 'boolean',
    hash = 'userdata',
  },
  classes = {
    vector3 = { x = 'number', y = 'number', z = 'number' },
    vector4 = { x = 'number', y = 'number', z = 'number', w = 'number' },
    url = { socket = 'hash', path = 'hash', fragment = 'hash' },
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
  name = 'generator_patches',
  cases = {
    {
      name = 'combines patches and generated message types',
      run = function()
        local result = helper.run_pipeline({
          name = 'generator-patches',
          docs_dir = 'integration',
          patch_files = {
            'test-sprite_doc.lua',
            'test-sound_doc.lua',
            'test-model_doc.lua',
            'test-physics_doc.lua',
          },
          rules = rules,
        })

        assertx.contains(result.outputs['sprite.lua'], 'fun(self, message_id:hash, message:message.sprite.animation_done, sender:url)')
        assertx.contains(result.outputs['sound.lua'], 'message.sound.sound_done|message.sound.sound_stopped')
        assertx.contains(result.outputs['model.lua'], 'fun(self, message_id:hash, message:message.model.model_animation_done, sender:url)')
        assertx.contains(result.outputs['physics.lua'], '---@return [message.physics.ray_cast_response]|message.physics.ray_cast_response result Raycast result')
        assertx.contains(result.outputs['physics.lua'], 'fun(self, events:[message.physics.contact_point_event|message.physics.collision_event|message.physics.trigger_event|message.physics.ray_cast_response|message.physics.ray_cast_missed])')
      end,
    },
  },
}
