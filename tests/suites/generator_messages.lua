local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

return {
  name = 'generator_messages',
  cases = {
    {
      name = 'generates top-level and helper message classes only',
      run = function()
        local result = helper.run_pipeline({
          name = 'generator-messages',
          docs_dir = 'messages',
          skip_enums = true,
        })

        local output = result.outputs['sprite.lua']
        assertx.contains(output, '---@class message.sprite.animation_done')
        assertx.contains(output, '---@class message.sprite.animation_done.payload')
        assertx.contains(output, '---@field payload? message.sprite.animation_done.payload Optional payload')
        assertx.not_contains(output, 'message = {}')
        assertx.not_contains(output, 'message.sprite = {}')
        assertx.not_contains(output, 'defold_api.message')
      end,
    },
  },
}
