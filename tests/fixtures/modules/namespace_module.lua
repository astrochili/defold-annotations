return {
  {
    info = {
      namespace = 'demo',
      language = 'Lua',
      brief = 'Demo API',
      description = 'Namespace module',
    },
    elements = {
      {
        type = 'ALIAS',
        name = 'demo.Mode',
        alias = 'integer',
        description = 'Mode alias',
      },
      {
        type = 'CLASS',
        name = 'demo.Record',
        description = 'Structured record',
        fields = {
          id = 'hash',
        },
      },
      {
        type = 'CONSTANT',
        name = 'demo.FLAG',
        description = 'Flag constant',
        constant_type = 'integer',
        parameters = {},
        returnvalues = {},
      },
      {
        type = 'FUNCTION',
        name = 'demo.run',
        description = 'Run the module',
        parameters = {},
        returnvalues = {},
      },
      {
        type = 'FUNCTION',
        name = 'demo.tools.inspect',
        description = 'Inspect values',
        parameters = {},
        returnvalues = {},
      },
    },
  },
}
