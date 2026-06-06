--[[
  aliases.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

return {
  bool = 'boolean',
  float = 'number',
  array = 'table',

  quaternion = 'vector4',
  hash = 'userdata',
  node = 'userdata',
  constant = 'number',
  vector = 'userdata',

  resource_data = 'userdata',
  constant_buffer = 'userdata',
  render_target = 'string|userdata',
  render_predicate = 'userdata',
  buffer_stream = 'userdata',
  buffer_data = 'userdata',

  ['b2d.world'] = 'userdata',
  ['b2d.body'] = 'userdata',
  ['b2d.joint'] = 'userdata',
  ['b2d.chain'] = 'userdata',
  ['b2d.shape'] = 'userdata',
  ['b2d.contact_edge'] = 'userdata',

  socket_client = 'userdata',
  socket_master = 'userdata',
  socket_unconnected = 'userdata',

  ['editor.schema'] = 'userdata',
  ['editor.component'] = 'userdata',
  ['editor.transaction_step'] = 'userdata',
  ['editor.tiles'] = 'userdata',
  ['editor.image'] = 'userdata',
  ['editor.command'] = 'userdata',
  ['editor.message'] = 'userdata',
  ['http.response'] = 'userdata',
  ['http.route'] = 'userdata'
}
