--[[
  config.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local config = {}

---Folder separator
config.folder_separator = package.config:sub(1, 1)

---Clean temporary files after completion
config.clean_traces = true

---Url of this project on github
config.generator_url = 'github.com/astrochili/defold-annotations'

---Url to find out the latest version of Defold
function config.info_url()
  return 'https://d.defold.com/stable/' .. config.info_json
end

---File name of the info about the letest version
config.info_json = 'info.json'

---Url to find out the documentation archive
function config.doc_url(version)
  return 'https://github.com/defold/defold/releases/download/' .. version .. '/' .. config.doc_zip
end

---File name of the documentation archive
config.doc_zip = 'ref-doc.zip'

---Name of the unpacked doc folder
config.doc_folder = 'doc'

---Json extension
config.json_extension = 'json'

---Name of a temporary text file with paths to json files
config.json_list_txt = 'json_list.txt'

---Name of the output folder
config.api_folder = 'api'

---Ignored docs
---Possible to use suffix `*`
config.ignored_docs = {
  -- Starting from 1.10.2
  'dmsdk-*',
  'lua_*',

  -- Before 1.10.2
  'dm*',
  'debug_doc',
  'coroutine_doc',
  'math_doc',
  'package_doc',
  'string_doc',
  'table_doc',
  'engine_doc',
  'base_doc',
  'os_doc',
  'io_doc'
}

---Ignored functions
---Possible to use suffix `*`
config.ignored_funcs = {
  'init',
  'update',
  'fixed_update',
  'on_input',
  'on_message',
  'on_reload',
  'final',
  'client:*',
  'server:*',
  'master:*',
  'connected:*',
  'unconnected:*'
}

--- Global replacements for param names
config.global_name_replacements = {
  ['repeat'] = 'repeating',
  ['...commands'] = '...'
}

--- Local replacements for param names
config.local_name_replacements = {
  pprint = {
    param_v = '...'
  }
}

--- Global replacements for param types
config.global_type_replacements = {
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
}

--- Local replacements for param types
config.local_type_replacements = {
  ['buffer.create'] = {
    param_table_declaration = '{ name:hash|string, type:buffer.VALUE_TYPE, count:number }[]'
  },
  ['buffer.set_metadata'] = {
    param_table_values = 'number[]',
    param_constant_value_type = 'buffer.VALUE_TYPE|integer'
  },
  ['buffer.get_metadata'] = {
    return_table_values = 'number[]',
    return_constant_value_type = 'buffer.VALUE_TYPE|integer'
  },
  ['gui.cancel_animations'] = {
    param_constant_property = 'gui.PROP'
  },
  ['gui.get'] = {
    param_constant_property = 'gui.PROP'
  },
  ['gui.set'] = {
    param_constant_property = 'gui.PROP'
  },
  ['render.enable_texture'] = {
    param_constant_buffer_type = 'graphics.BUFFER_TYPE|integer'
  },
  ['collectionfactory.create'] = {
    return_table_ids = 'table<hash, hash>'
  },
  ['collectionproxy.get_resources'] = {
    return_table_resources = 'string[]'
  },
  ['collectionproxy.missing_resources'] = {
    return_table_resources = 'string[]'
  },
  ['crash.get_modules'] = {
    return_table_modules = '{ name:string, address:string }[]'
  },
  ['editor.create_resources'] = {
    ['param_string[_resources'] = 'string[]'
  },
  ['editor.bundle.check_boxes_grid_row'] = {
    ['return_component[_row'] = 'editor.component[]'
  },
  ['editor.bundle.common_variant_grid_row'] = {
    ['return_component[_row'] = 'editor.component[]'
  },
  ['editor.bundle.desktop_variant_grid_row'] = {
    ['return_component[_row'] = 'editor.component[]'
  },
  ['editor.bundle.dialog'] = {
    ['param_component[_rows'] = 'editor.component[]'
  },
  ['editor.bundle.grid_row'] = {
    ['param_component[_content'] = 'editor.component[]',
    ['return_component[_row'] = 'editor.component[]'
  },
  ['editor.bundle.texture_compression_grid_row'] = {
    ['return_component[_row'] = 'editor.component[]'
  },
  ['editor.bundle.assoc_in'] = {
    ['param_any[_keys'] = 'any[]'
  },
  ['editor.bundle.select_box'] = {
    ['param_any[_options'] = 'any[]'
  },
  ['editor.transact'] = {
    ['param_transaction_step[_txs'] = 'editor.transaction_step[]'
  },
  ['editor.execute'] = {
    param_table_options = '{ reload_resources?:boolean, out?:string, err?:string }'
  },
  ['editor.external_file_attributes'] = {
    return_table_attributes = '{ path:string, exists:boolean, is_file:boolean, is_directory:boolean }'
  },
  ['editor.prefs.schema.array'] = {
    param_table_opts = '{ item:editor.schema, default?:any[], scope?:string }'
  },
  ['editor.prefs.schema.boolean'] = {
    param_table_opts = '{ default?:boolean, scope?:string }'
  },
  ['editor.prefs.schema.enum'] = {
    param_table_opts = '{ values:(nil|boolean|number|string)[], default?:any, scope?:string }'
  },
  ['editor.prefs.schema.integer'] = {
    param_table_opts = '{ default?:integer, scope?:string }'
  },
  ['editor.prefs.schema.keyword'] = {
    param_table_opts = '{ default?:string, scope?:string }'
  },
  ['editor.prefs.schema.number'] = {
    param_table_opts = '{ default?:number, scope?:string }'
  },
  ['editor.prefs.schema.object'] = {
    param_table_opts = '{ properties:table<string, editor.schema>, default?:table<string, editor.schema>, scope?:string }'
  },
  ['editor.prefs.schema.object_of'] = {
    param_table_opts = '{ key:editor.schema, val:editor.schema, default?:table, scope?:string }'
  },
  ['editor.prefs.schema.set'] = {
    param_table_opts = '{ item:editor.schema, default?:table<editor.schema, boolean>, scope?:string }'
  },
  ['editor.prefs.schema.string'] = {
    param_table_opts = '{ default?:string, scope?:string }'
  },
  ['editor.prefs.schema.tuple'] = {
    param_table_opts = '{ items:editor.schema[], default?:any[], scope?:string }'
  },
  ['editor.resource_attributes'] = {
    return_table_value = '{ exists:boolean, is_file:boolean, is_directory:boolean }'
  },
  ['editor.ui.use_memo'] = {
    ['param_...any_...'] = 'any',
    ['return_...any_values'] = 'any ...'
  },
  ['editor.ui.use_state'] = {
    ['param_...any_...'] = 'any'
  },
  ['editor.ui.show_resource_dialog'] = {
    ['return_string[_value'] = 'string[]|nil'
  },
  ['gui.clone_tree'] = {
    return_table_clones = 'table<hash, node>'
  },
  ['gui.get_tree'] = {
    return_table_clones = 'table<hash, node>'
  },
  ['gui.play_flipbook'] = {
    param_table_play_properties = '{ offset?:number, playback_rate?:number }'
  },
  ['gui.stop_particlefx'] = {
    param_table_options = '{ clear?:boolean }'
  },
  ['gui.get_layouts'] = {
    ['return_table_'] = 'table<hash, vector3>'
  },
  ['http.server.external_file_response'] = {
    ['param_table&lt;string,string&gt;_headers'] = 'table<string, string>'
  },
  ['http.server.json_response'] = {
    ['param_table&lt;string,string&gt;_headers'] = 'table<string, string>'
  },
  ['http.server.resource_response'] = {
    ['param_table&lt;string,string&gt;_headers'] = 'table<string, string>'
  },
  ['http.server.response'] = {
    ['param_table&lt;string,string&gt;_headers'] = 'table<string, string>'
  },
  ['json.decode'] = {
    param_table_options = '{ decode_null_as_userdata?:boolean }'
  },
  ['json.encode'] = {
    param_table_options = '{ encode_empty_table_as_object:string }'
  },
  ['particlefx.stop'] = {
    param_table_options = '{ clear?:boolean }'
  },
  ['sprite.play_flipbook'] = {
    param_table_options = '{ offset?:number, playback_rate?:number }'
  },
  ['sound.play'] = {
    param_table_play_properties = '{ delay?:number, gain?:number, pan?:number, speed?:number, start_time?:number, start_frame?:number }'
  },
  ['sound.stop'] = {
    param_table_stop_properties = '{ play_id:number }'
  },
  ['model.play_anim'] = {
    param_table_play_properties = '{ blend_duration?:number, offset?:number, playback_rate?:number}'
  },
  ['image.load'] = {
    return_table_image = '{ width:number, height:number, type:image.TYPE, buffer:string }'
  },
  ['image.load_buffer'] = {
    return_table_image = '{ width:number, height:number, type:image.TYPE, buffer:buffer_data }'
  },
  ['physics.get_joint_properties'] = {
    return_table_properties = '{ collide_connected?:boolean }'
  },
  ['physics.raycast'] = {
    param_table_options = '{ all?:boolean }',
    return_table_result = 'physics.raycast_response[]|physics.raycast_response'
  },
  ['physics.get_shape'] = {
    return_table_table = '{ type?:number, diameter?:number, dimensions?:vector3, height?:number }'
  },
  ['physics.set_shape'] = {
    param_table_table = '{ diameter?:number, dimensions?:vector3, height?:number }'
  },
  ['resource.create_atlas'] = {
    param_table_table = 'resource.atlas'
  },
  ['resource.get_atlas'] = {
    return_table_data = 'resource.atlas'
  },
  ['resource.set_atlas'] = {
    param_table_table = 'resource.atlas'
  },
  ['resource.get_render_target_info'] = {
    return_table_table = '{ handle:number, attachments:{ handle:number, width:number, height:number, depth:number, mipmaps:number, type:number, buffer_type:number, texture:hash }[] }'
  },
  ['resource.create_sound_data'] = {
    param_table_options = '{ data?:string, filesize?:number, partial?:boolean }'
  },
  ['resource.create_texture'] = {
    param_table_table = '{ type:number, width:number, height:number, depth:number, format:number, flags?:number, max_mipmaps?:number, compression_type?:number}'
  },
  ['resource.create_texture_async'] = {
    param_table_table = '{ type:number, width:number, height:number, depth:number, format:number, flags?:number, max_mipmaps?:number, compression_type?:number}',
    param_function_callback = 'fun(self, request_id, resource)'
  },
  ['resource.set_texture'] = {
    param_table_table = '{ type:number, width:number, height:number, format:number, x?:number, y?:number, z?:number, mipmap?:number, compression_type?:number}'
  },
  ['resource.get_texture_info'] = {
    return_table_table = '{ handle:number, width:number, height:number, depth:number, mipmaps:number, flags:number, type:number }'
  },
  ['resource.get_text_metrics'] = {
    param_table_options = '{ width?:number, leading?:number, tracking?:number, line_break?:boolean}',
    return_table_metrics = '{ width:number, height:number, max_ascent:number, max_descent:number }'
  },
  ['resource.create_buffer'] = {
    param_table_table = '{ buffer:buffer_data, transfer_ownership?:boolean }'
  },
  ['resource.set_buffer'] = {
    param_table_table = '{ transfer_ownership?: boolean }'
  },
  ['render.draw'] = {
    param_table_options = '{ frustum?:matrix4, frustum_planes?:number, constants?:constant_buffer, sort_order?:integer }'
  },
  ['render.draw_debug3d'] = {
    param_table_options = '{ frustum?:matrix4, frustum_planes?:number }'
  },
  ['render.predicate'] = {
    param_table_tags = '(string|hash)[]'
  },
  ['render.render_target'] = {
    param_table_parameters = 'table<number, { format:number, width:number, height:number, min_filter?:number, mag_filter?:number, u_wrap?:number, v_wrap?:number, flags?:number}>'
  },
  ['render.set_camera'] = {
    param_table_options = '{ use_frustum?:boolean }'
  },
  ['render.set_render_target'] = {
    param_table_options = '{ transient?:number[] }'
  },
  ['sound.get_groups'] = {
    return_table_groups = 'hash[]'
  },
  ['sys.get_sys_info'] = {
    param_table_options = '{ ignore_secure?:boolean }',
    return_table_sys_info = '{ device_model?:string, manufacturer?:string, system_name:string, system_version:string, api_version:string, language:string, device_language:string, territory:string, gmt_offset:number, device_ident?:string, user_agent?:string }'
  },
  ['sys.get_application_info'] = {
    return_table_app_info = '{ installed:boolean }'
  },
  ['sys.get_engine_info'] = {
    return_table_engine_info = '{ version:string, version_sha1:string, is_debug:boolean }'
  },
  ['sys.get_ifaddrs'] = {
    return_table_ifaddrs = '{ name:string, address?:string, mac?:string, up:boolean, running:boolean }'
  },
  ['sys.open_url'] = {
    param_table_attributes = '{ target?:string, name?:string }'
  },
  ['timer.get_info'] = {
    return_table_data = '{ time_remaining:number, delay:number, repeating:boolean }'
  },
  ['vmath.euler_to_quat'] = {
    param_number_y = 'number?',
    param_number_z = 'number?'
  },
  ['vmath.vector'] = {
    param_table_t = 'number[]'
  },
  ['zip.pack'] = {
    param_table_opts = '{ method?:string, level?:integer }'
  }
}

config.generics = {
  ['vmath.clamp'] = 'number|vector3|vector4',
  ['vmath.dot'] = 'vector3|vector4',
  ['vmath.normalize'] = 'vector3|vector4|quaternion',
  ['vmath.mul_per_elem'] = 'vector3|vector4',
  ['vmath.slerp'] = 'vector3|vector4',
  ['vmath.lerp'] = 'vector3|vector4'
}

---Default type for unknown types
config.unknown_type = 'unknown'

---Known types
config.known_types = {
  'nil',
  'any',
  'boolean',
  'number',
  'integer',
  'string',
  'userdata',
  'function',
  'thread',
  'table'
}

---Known classes
config.known_classes = {
  vector3 = {
    fields = {
      x = 'number',
      y = 'number',
      z = 'number'
    },
    operators = {
      sub = { param = 'vector3', result = 'vector3' },
      add = { param = 'vector3', result = 'vector3' },
      mul = { param = 'number', result = 'vector3' },
      unm = { result = 'vector3' }
    }
  },
  vector4 = {
    fields = {
      x = 'number',
      y = 'number',
      z = 'number',
      w = 'number'
    },
    operators = {
      sub = { param = 'vector4', result = 'vector4' },
      add = { param = 'vector4', result = 'vector4' },
      mul = { param = 'number', result = 'vector4' },
      unm = { result = 'vector4' }
    }
  },
  url = {
    socket = 'hash',
    path = 'hash',
    fragment = 'hash'
  },
  ['http.server'] = {
    is_global = true
  },
  ['zip'] = {
    is_global = true
  },
  ['zip.METHOD'] = {
    is_global = true
  },
  ['zip.ON_CONFLICT'] = {
    is_global = true
  },
  ['socket.dns'] = {
    is_global = true
  },
  ['editor.ui'] = {
    is_global = true
  },
  ['editor.ui.ALIGNMENT'] = {
    is_global = true
  },
  ['editor.ui.COLOR'] = {
    is_global = true
  },
  ['editor.ui.HEADING_STYLE'] = {
    is_global = true
  },
  ['editor.ui.ICON'] = {
    is_global = true
  },
  ['editor.ui.ISSUE_SEVERITY'] = {
    is_global = true
  },
  ['editor.ui.ORIENTATION'] = {
    is_global = true
  },
  ['editor.ui.PADDING'] = {
    is_global = true
  },
  ['editor.ui.SPACING'] = {
    is_global = true
  },
  ['editor.ui.TEXT_ALIGNMENT'] = {
    is_global = true
  },
  ['editor.prefs'] = {
    is_global = true
  },
  ['editor.prefs.SCOPE'] = {
    is_global = true
  },
  ['editor.prefs.schema'] = {
    is_global = true
  },
  ['editor.tx'] = {
    is_global = true
  },
  ['tilemap.tiles'] = {
    is_global = true
  },
  ['editor.bundle'] = {
    is_global = true
  },
  matrix4 = {
    m00 = 'number',
    m01 = 'number',
    m02 = 'number',
    m03 = 'number',
    m10 = 'number',
    m11 = 'number',
    m12 = 'number',
    m13 = 'number',
    m20 = 'number',
    m21 = 'number',
    m22 = 'number',
    m23 = 'number',
    m30 = 'number',
    m31 = 'number',
    m32 = 'number',
    m33 = 'number',
    c0 = 'vector4',
    c1 = 'vector4',
    c2 = 'vector4',
    c3 = 'vector4',
  },
  ['resource.atlas'] = {
    texture = 'string|hash The path to the texture resource, e.g "/main/my_texture.texturec"',
    animations = 'resource.animation[] A list of the animations in the atlas',
    geometries = 'resource.geometry[] A list of the geometries that should map to the texture data',
  },
  ['resource.animation'] = {
    id = 'string The id of the animation, used in e.g sprite.play_animation',
    width = 'integer The width of the animation',
    height = 'integer The height of the animation',
    frame_start = 'integer Index to the first geometry of the animation. Indices are lua based and must be in the range of 1 .. in atlas.',
    frame_end = 'integer Index to the last geometry of the animation (non-inclusive). Indices are lua based and must be in the range of 1 .. in atlas.',
    ['playback?'] = 'constant Optional playback mode of the animation, the default value is go.PLAYBACK_ONCE_FORWARD',
    ['fps?'] = 'integer Optional fps of the animation, the default value is 30',
    ['flip_vertical?'] = 'boolean Optional flip the animation vertically, the default value is false',
    ['flip_horizontal?'] = 'boolean Optional flip the animation horizontally, the default value is false'
  },
  ['resource.geometry'] = {
    id = 'string The name of the geometry. Used when matching animations between multiple atlases',
    width = 'number The width of the image the sprite geometry represents',
    height = 'number The height of the image the sprite geometry represents',
    pivot_x = 'number The pivot x value of the image in unit coords. (0,0) is upper left corner, (1,1) is bottom right. Default is 0.5.',
    pivot_y = 'number The pivot y value of the image in unit coords. (0,0) is upper left corner, (1,1) is bottom right. Default is 0.5.',
    rotated = 'boolean Whether the image is rotated 90 degrees counter-clockwise in the atlas. This affects UV coordinate generation for proper rendering. Default is false.',
    vertices = 'number[] A list of the vertices in texture space of the geometry in the form { px0, py0, px1, py1, ..., pxn, pyn }',
    uvs = 'number[] A list of the uv coordinates in texture space of the geometry in the form of { u0, v0, u1, v1, ..., un, vn }',
    indices = 'number[] A list of the indices of the geometry in the form { i0, i1, i2, ..., in }. Each tripe in the list represents a triangle.'
  },
  ['physics.raycast_response'] = {
    fraction = 'number The fraction of the hit measured along the ray, where 0 is the start of the ray and 1 is the end',
    position = 'vector3 The world position of the hit',
    normal = 'vector3 The normal of the surface of the collision object where it was hit',
    id = 'hash The instance id of the hit collision object',
    group = 'hash The collision group of the hit collision object as a hashed name',
    request_id = 'number The id supplied when the ray cast was requested'
  },
  ['on_input.action'] = {
    ['value?'] = 'number The amount of input given by the user. This is usually 1 for buttons and 0-1 for analogue inputs. This is not present for mouse movement.',
    ['pressed?'] = 'boolean If the input was pressed this frame. This is not present for mouse movement.',
    ['released?'] = 'boolean If the input was released this frame. This is not present for mouse movement.',
    ['repeated?'] = 'boolean If the input was repeated this frame. This is similar to how a key on a keyboard is repeated when you hold it down. This is not present for mouse movement.',
    ['x?'] = 'number The x value of a pointer device, if present.',
    ['y?'] = 'number The y value of a pointer device, if present.',
    ['screen_x?'] = 'number The screen space x value of a pointer device, if present.',
    ['screen_y?'] = 'number The screen space y value of a pointer device, if present.',
    ['dx?'] = 'number The change in x value of a pointer device, if present.',
    ['dy?'] = 'number The change in y value of a pointer device, if present.',
    ['screen_dx?'] = 'number The change in screen space x value of a pointer device, if present.',
    ['gamepad?'] = 'integer The change in screen space y value of a pointer device, if present.',
    ['screen_dy?'] = 'number The index of the gamepad device that provided the input.',
    ['touch?'] = 'on_input.touch[] List of touch input, one element per finger, if present.',
    ['text?'] = 'string The text entered with the `text` action, if present'
  },
  ['on_input.touch'] = {
    id = 'number A number identifying the touch input during its duration.',
    pressed = 'boolean True if the finger was pressed this frame.',
    released = 'boolean True if the finger was released this frame.',
    tap_count = 'integer Number of taps, one for single, two for double-tap, etc',
    x = 'number The x touch location.',
    y = 'number The y touch location.',
    dx = 'number The change in x value.',
    dy = 'number The change in y value.',
    ['acc_x?'] = 'number Accelerometer x value (if present).',
    ['acc_y?'] = 'number Accelerometer y value (if present).',
    ['acc_z?'] = 'number Accelerometer z value (if present).',
    ['screen_x?'] = 'number The screen space x value of a pointer device, if present.',
    ['screen_y?'] = 'number The screen space y value of a pointer device, if present.',
    ['screen_dx?'] = 'number The change in screen space x value of a pointer device, if present.',
    ['screen_dy?'] = 'number The index of the gamepad device that provided the input.'
  }
}

---Known aliases
config.known_aliases = {
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

  b2BodyType = 'number',
  b2World = 'userdata',
  b2Body = 'userdata',

  socket_client = 'userdata',
  socket_master = 'userdata',
  socket_unconnected = 'userdata',

  ['editor.schema'] = 'userdata',
  ['editor.component'] = 'userdata',
  ['editor.transaction_step'] = 'userdata',
  ['editor.tiles'] = 'userdata',
  ['editor.command'] = 'userdata',
  ['http.response'] = 'userdata',
  ['http.route'] = 'userdata'
}

config.disabled_diagnostics = {
  'lowercase-global',
  'missing-return',
  'duplicate-doc-param',
  'duplicate-set-field',
  'args-after-dots'
}

return config
