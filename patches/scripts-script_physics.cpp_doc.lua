return {
  ["elements.physics.create_joint.parameters.joint_type.types.number"] = "physics.JOINT_TYPE",
  ["elements.physics.get_joint_properties.returnvalues.properties.types.table"] = "{ collide_connected?:boolean }",
  ["elements.physics.get_shape.returnvalues.table.types.table"] = "{ type?:physics.SHAPE_TYPE, diameter?:number, dimensions?:vector3, height?:number }",
  ["elements.physics.raycast.parameters.options.types.table"] = "{ all?:boolean }",
  ["elements.physics.raycast.returnvalues.result.types.table"] = "[physics.raycast_response]|physics.raycast_response",
  ["elements.physics.set_event_listener.parameters.callback.types.function(self, events)"] = "fun(self, events:[table])",
  ["elements.physics.set_shape.parameters.table.types.table"] = "{ type?:physics.SHAPE_TYPE, diameter?:number, dimensions?:vector3, height?:number }",
}
