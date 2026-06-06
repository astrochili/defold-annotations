local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

return {
  name = 'parser',
  cases = {
    {
      name = 'parses synthetic doc shapes',
      run = function()
        local app = helper.load_app()
        local modules = app.parser.parse_json(helper.list_json_fixtures('parser'))
        local module = modules[1]

        assertx.equal(#modules, 1)
        assertx.equal(module.info.namespace, 'sample')
        assertx.equal(module.info.brief, 'Sample API')
        assertx.equal(#module.elements, 4)
        assertx.equal(module.elements[1].type, 'FUNCTION')
        assertx.equal(module.elements[2].type, 'VARIABLE')
        assertx.equal(module.elements[3].type, 'CONSTANT')
        assertx.equal(module.elements[4].type, 'MESSAGE')
        assertx.equal(module.elements[1].parameters[2].is_optional, 'True')
        assertx.equal(module.elements[1].returnvalues[2].types[2], 'number')
        assertx.contains(module.elements[4].parameters[2].doc, '<dl>')
      end,
    },
  },
}
