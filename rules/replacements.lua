--[[
  replacements.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

return {
  quat = 'quaternion',
  resource = 'resource_data',
  buffer = 'buffer_data',
  bufferstream = 'buffer_stream',
  handle = 'number',
  texture = 'number',
  predicate = 'render_predicate',
  client = 'socket_client',
  master = 'socket_master',
  unconnected = 'socket_unconnected',
  ['vmath.vector3'] = 'vector3',
  ['vmath.vector4'] = 'vector4',
  vecto4 = 'vector4',
  schema = 'editor.schema',
  component = 'editor.component',
  tiles = 'editor.tiles',
  transaction_step = 'editor.transaction_step',
  command = 'editor.command',
  response = 'http.response',
  route = 'http.route',
  message = 'editor.message',
  b2World = 'b2d.world',
  b2Body = 'b2d.body',
  b2BodyType = 'b2d.body.B2',
  b2Joint = 'b2d.joint',
  b2Chain = 'b2d.chain',
  b2Shape = 'b2d.shape',
  b2ContactEdge = 'b2d.contact_edge',
  b2MassData = 'b2d.mass_data',
  b2Transform = 'b2d.transform',
  image = 'editor.image'
}
