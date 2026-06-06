return {
  append = {
    elements = {
      {
        type = "CONSTANT",
        name = "render.CONTEXT_EVENT_CONTEXT_LOST"
      },
      {
        type = "CONSTANT",
        name = "render.CONTEXT_EVENT_CONTEXT_RESTORED"
      },
    },
  },
  ["elements.render.disable_state.parameters.state.types.constant"] = "graphics.STATE",
  ["elements.render.draw.parameters.options.types.table"] = "{ frustum?:matrix4, frustum_planes?:render.FRUSTUM_PLANES, constants?:constant_buffer, sort_order?:render.SORT }",
  ["elements.render.draw_debug3d.parameters.options.types.table"] = "{ frustum?:matrix4, frustum_planes?:render.FRUSTUM_PLANES }",
  ["elements.render.enable_state.parameters.state.types.constant"] = "graphics.STATE",
  ["elements.render.enable_texture.parameters.buffer_type.types"] = "graphics.BUFFER_TYPE",
  ["elements.render.get_render_target_height.parameters.buffer_type.types"] = "graphics.BUFFER_TYPE",
  ["elements.render.get_render_target_width.parameters.buffer_type.types"] = "graphics.BUFFER_TYPE",
  ["elements.render.predicate.parameters.tags.types.table"] = "[string|hash]",
  ["elements.render.clear.parameters.buffers.types.table"] = "[graphics.BUFFER_TYPE]",
  ["elements.render.render_target.parameters.parameters.types.table"] = "table<number, { format:graphics.TEXTURE_FORMAT, width:number, height:number, min_filter?:graphics.TEXTURE_FILTER, mag_filter?:graphics.TEXTURE_FILTER, u_wrap?:graphics.TEXTURE_WRAP, v_wrap?:graphics.TEXTURE_WRAP, flags?:number }>",
  ["elements.render.set_camera.parameters.options.types.table"] = "{ use_frustum?:boolean }",
  ["elements.render.set_blend_func.parameters.destination_factor.types.number"] = "graphics.BLEND_FACTOR",
  ["elements.render.set_blend_func.parameters.source_factor.types.number"] = "graphics.BLEND_FACTOR",
  ["elements.render.set_cull_face.parameters.face_type.types.number"] = "graphics.FACE_TYPE",
  ["elements.render.set_depth_func.parameters.func.types.number"] = "graphics.COMPARE_FUNC",
  ["elements.render.set_listener.parameters.callback.types.function(self, event_type)"] = "fun(self, event_type:render.CONTEXT_EVENT)",
  ["elements.render.set_render_target.parameters.options.types.table"] = "{ transient?:[graphics.BUFFER_TYPE] }",
  ["elements.render.set_stencil_func.parameters.func.types.number"] = "graphics.COMPARE_FUNC",
  ["elements.render.set_stencil_op.parameters.dpfail.types.number"] = "graphics.STENCIL_OP",
  ["elements.render.set_stencil_op.parameters.dppass.types.number"] = "graphics.STENCIL_OP",
  ["elements.render.set_stencil_op.parameters.sfail.types.number"] = "graphics.STENCIL_OP",
}
