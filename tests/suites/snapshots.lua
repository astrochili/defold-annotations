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
  name = 'snapshots',
  cases = {
    {
      name = 'matches curated output fragments',
      run = function()
        local function snapshot(name)
          return helper.read_snapshot(name):gsub('%s+$', '')
        end

        local result = helper.run_pipeline({
          name = 'snapshots',
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

        assertx.contains(result.outputs['b2d.body.lua'], snapshot('namespace_fragment.txt'))
        assertx.contains(result.outputs['physics.lua'], snapshot('class_fragment.txt'))
        assertx.contains(result.outputs['physics.lua'], snapshot('message_fragment.txt'))
        assertx.contains(result.outputs['model.lua'], snapshot('patched_function_fragment.txt'))
        assertx.contains(result.outputs['meta.lua'], snapshot('meta_fragment.txt'))
      end,
    },
  },
}
