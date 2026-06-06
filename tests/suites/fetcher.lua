local assertx = require 'tests.helpers.assert'
local helper = require 'tests.helpers.pipeline'

return {
  name = 'fetcher',
  cases = {
    {
      name = 'reads local fixture directory',
      run = function()
        local app = helper.load_app()

        helper.with_temp_config(app.config, 'fetcher', function()
          local json_paths = app.fetcher.fetch_docs(helper.fixture_path('docs', 'fetcher'))
          assertx.equal(#json_paths, 2)
          local names = {}
          for _, path in ipairs(json_paths) do
            assertx.contains(path, app.config.doc_folder .. app.config.folder_separator)
            names[path:match('([^/\\]+)$')] = true
          end
          assertx.truthy(names['alpha.json'])
          assertx.truthy(names['beta.json'])
        end)
      end,
    },
  },
}
