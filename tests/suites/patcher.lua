local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

local function module_copy(name, source_path)
  local module = helper.load_fixture_module(name)
  module._source_path = source_path
  return { module }
end

return {
  name = 'patcher',
  cases = {
    {
      name = 'applies callback patch without distorting type text',
      run = function()
        local app = helper.load_app()

        helper.with_staged_patches({ 'test-sprite_doc.lua' }, function()
          local modules = module_copy('patch_target.lua', helper.fixture_path('docs', 'integration', 'test-sprite_doc.json'))
          app.patcher.patch_modules(modules)
          local parameter = modules[1].elements[1].parameters[1]
          assertx.equal(parameter.types[1], 'fun(self, message_id:hash, message:message.sprite.animation_done, sender:url)')
        end)
      end,
    },
    {
      name = 'leaves modules without patches unchanged',
      run = function()
        local app = helper.load_app()
        local modules = module_copy('patch_target.lua', helper.fixture_path('docs', 'integration', 'no-patch_doc.json'))
        app.patcher.patch_modules(modules)
        assertx.equal(modules[1].elements[1].parameters[1].types[1], 'function(self, message_id, message, sender)')
      end,
    },
    {
      name = 'fails on unresolved patch path',
      run = function()
        local app = helper.load_app()

        helper.with_staged_patches({ 'test-invalid_doc.lua' }, function()
          local modules = module_copy('patch_target.lua', helper.fixture_path('docs', 'integration', 'test-invalid_doc.json'))
          assertx.raises(function()
            app.patcher.patch_modules(modules)
          end, 'could not be resolved')
        end)
      end,
    },
  },
}
