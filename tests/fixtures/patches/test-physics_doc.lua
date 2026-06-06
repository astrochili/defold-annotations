return {
  ["elements.physics.raycast.parameters.options.types.table"] = "{ all?:boolean }",
  ["elements.physics.raycast.returnvalues.result.types.table"] = "[message.physics.ray_cast_response]|message.physics.ray_cast_response",
  ["elements.physics.set_event_listener.parameters.callback.types.function(self, events)"] = "fun(self, events:[message.physics.contact_point_event|message.physics.collision_event|message.physics.trigger_event|message.physics.ray_cast_response|message.physics.ray_cast_missed])",
}
