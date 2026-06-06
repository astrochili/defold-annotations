return {
  info = {
    namespace = 'sprite',
    language = 'Lua',
    brief = 'Sprite API',
    description = 'Patch target',
  },
  elements = {
    {
      type = 'FUNCTION',
      name = 'sprite.play_flipbook',
      description = 'Play a sprite animation',
      parameters = {
        {
          name = 'complete_function',
          doc = 'Completion callback',
          types = { 'function(self, message_id, message, sender)' },
          is_optional = 'True',
        },
        {
          name = 'play_properties',
          doc = 'Playback settings',
          types = { 'table' },
          is_optional = 'True',
        },
      },
      returnvalues = {},
    },
  },
}
