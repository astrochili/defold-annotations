return {
  {
    info = {
      namespace = 'render',
      language = 'Lua',
      brief = 'Render API',
      description = 'Enum module',
    },
    elements = {
      {
        type = 'CONSTANT',
        name = 'render.CONTEXT_EVENT_LOST',
        description = 'Lost context',
        constant_type = 'string',
        parameters = {},
        returnvalues = {},
      },
      {
        type = 'CONSTANT',
        name = 'render.CONTEXT_EVENT_RESTORED',
        description = 'Restored context',
        constant_type = 'string',
        parameters = {},
        returnvalues = {},
      },
      {
        type = 'FUNCTION',
        name = 'render.handle_context',
        description = 'Handle context event',
        parameters = {
          {
            name = 'event',
            doc = 'Event type',
            types = { 'render.CONTEXT_EVENT_LOST' },
            is_optional = 'False',
          },
        },
        returnvalues = {},
      },
    },
  },
}
