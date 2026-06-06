local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

return {
  name = 'meta',
  cases = {
    {
      name = 'emits deterministic known classes and aliases',
      run = function()
        local app = helper.load_app()
        local module = app.meta.make_module()

        assertx.equal(module.info.namespace, 'meta')
        assertx.equal(module.elements[1].name, 'b2d.mass_data')
        assertx.equal(module.elements[#module.elements].name, 'vector')
        assertx.truthy(module.elements[1].fields.mass ~= nil)
        assertx.truthy(module.elements[#module.elements].alias == 'userdata')

        local found_bool = false
        for _, element in ipairs(module.elements) do
          if element.name == 'bool' and element.alias == 'boolean' then
            found_bool = true
            break
          end
        end

        assertx.truthy(found_bool)
      end,
    },
  },
}
