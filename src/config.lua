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
  ['repeat'] = 'repeating'
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
  vector = 'vector4|vector3',
  resource = 'resource_data',
  buffer = 'buffer_data',
  bufferstream = 'buffer_stream',
  handle = 'resource_handle',
  texture = 'resource_handle',
  predicate = 'render_predicate',
  client = 'socket_client',
  master = 'socket_master',
  unconnected = 'socket_unconnected',
  ['vmath.vector3'] = 'vector3',
  ['vmath.vector4'] = 'vector4',
}

--- Local replacements for param types
config.local_type_replacements = {
  ['buffer.create'] = {
    param_table_declaration = '{ name:hash|string, type:constant, count:number }[]'
  },
  ['buffer.set_metadata'] = {
    param_table_values = 'number[]'
  },
  ['buffer.get_metadata'] = {
    return_table_values = 'number[]'
  },
  ['collectionfactory.create'] = {
    return_table_ids = 'table<string|hash, string|hash>'
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
  ['gui.clone_tree'] = {
    return_table_clones = 'table<string|hash, node>'
  },
  ['gui.get_tree'] = {
    return_table_clones = 'table<string|hash, node>'
  },
  ['gui.play_flipbook'] = {
    param_table_play_properties = '{ offset:number|nil, playback_rate:number|nil }'
  },
  ['gui.stop_particlefx'] = {
    param_table_options = '{ clear:boolean|nil }'
  },
  ['json.decode'] = {
    param_table_options = '{ decode_null_as_userdata:boolean|nil }'
  },
  ['json.encode'] = {
    param_table_options = '{ encode_empty_table_as_object:string }'
  },
  ['particlefx.stop'] = {
    param_table_options = '{ clear:boolean|nil }'
  },
  ['sprite.play_flipbook'] = {
    param_table_options = '{ offset:number|nil, playback_rate:number|nil }'
  },
  ['sound.play'] = {
    param_table_play_properties = '{ delay:number|nil, gain:number|nil, pan:number|nil, speed:number|nil }'
  },
  ['sound.stop'] = {
    param_table_stop_properties = '{ play_id:number }'
  },
  ['model.play_anim'] = {
    param_table_play_properties = '{ blend_duration:number|nil, offset:number|nil, playback_rate:number|nil}'
  },
  ['image.load'] = {
    return_table_image = '{ width:number, height:number, type:constant, buffer:string }'
  },
  ['image.load_buffer'] = {
    return_table_image = '{ width:number, height:number, type:constant, buffer:buffer_data }'
  },
  ['physics.get_joint_properties'] = {
    return_table_properties = '{ collide_connected:boolean|nil }'
  },
  ['physics.raycast'] = {
    param_table_options = '{ all:boolean|nil }',
    return_table_result = 'physics.raycast_response[]|physics.raycast_response'
  },
  ['physics.get_shape'] = {
    return_table_table = '{ type:number|nil, diameter:number|nil, dimensions:vector3|nil, height:number|nil }'
  },
  ['physics.set_shape'] = {
    param_table_table = '{ diameter:number|nil, dimensions:vector3|nil, height:number|nil }'
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
    return_table_table = '{ handle:resource_handle, attachments:{ handle:resource_handle, width:number, height:number, depth:number, mipmaps:number, type:number, buffer_type:number }[] }'
  },
  ['resource.create_texture'] = {
    param_table_table = '{ type:number, width:number, height:number, format:number, max_mipmaps:number|nil, compression_type:number|nil}'
  },
  ['resource.create_texture_async'] = {
    param_table_table = '{ type:number, width:number, height:number, format:number, max_mipmaps:number|nil, compression_type:number|nil}'
  },
  ['resource.set_texture'] = {
    param_table_table = '{ type:number, width:number, height:number, format:number, x:number|nil, y:number|nil, mipmap:number|nil, compression_type:number|nil}'
  },
  ['resource.get_texture_info'] = {
    return_table_table = '{ handle:resource_handle, width:number, height:number, depth:number, mipmaps:number, type:number }'
  },
  ['resource.get_text_metrics'] = {
    param_table_options = '{ width:number|nil, leading:number|nil, tracking:number|nil, line_break:boolean|nil}',
    return_table_metrics = '{ width:number, height:number, max_ascent:number, max_descent:number }'
  },
  ['resource.create_buffer'] = {
    param_table_table = '{ buffer:buffer_data, transfer_ownership:boolean|nil }'
  },
  ['resource.set_buffer'] = {
    param_table_table = '{ transfer_ownership: boolean|nil }'
  },
  ['render.draw'] = {
    param_table_options = '{ frustum:matrix4|nil, frustum_planes:number|nil, constants:constant_buffer|nil }'
  },
  ['render.draw_debug3d'] = {
    param_table_options = '{ frustum:matrix4|nil, frustum_planes:number|nil }'
  },
  ['render.predicate'] = {
    param_table_tags = '(string|hash)[]'
  },
  ['render.render_target'] = {
    param_table_parameters = 'table<number, { format:number, width:number, height:number, min_filter:number|nil, mag_filter:number|nil, u_wrap:number|nil, v_wrap:number|nil, flags:number|nil}>'
  },
  ['render.set_render_target'] = {
    param_table_options = '{ transient:number[]|nil }'
  },
  ['sound.get_groups'] = {
    return_table_groups = 'hash[]'
  },
  ['sys.get_sys_info'] = {
    param_table_options = '{ ignore_secure:boolean|nil }',
    return_table_sys_info = '{ device_model:string|nil, manufacturer:string|nil, system_name:string, system_version:string, api_version:string, language:string, device_language:string, territory:string, gmt_offset:number, device_ident:string|nil, user_agent:string|nil }'
  },
  ['sys.get_application_info'] = {
    return_table_app_info = '{ installed:boolean }'
  },
  ['sys.get_engine_info'] = {
    return_table_engine_info = '{ version:string, version_sha1:string, is_debug:boolean }'
  },
  ['sys.get_ifaddrs'] = {
    return_table_ifaddrs = '{ name:string, address:string|nil, mac:string|nil, up:boolean, running:boolean }'
  },
  ['sys.open_url'] = {
    param_table_attributes = '{ target:string|nil, name:string|nil }'
  },
  ['timer.get_info'] = {
    return_table_data = '{ time_remaining:number, delay:number, repeating:boolean }'
  }
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
  ['socket.dns'] = {
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
    texture = 'string|hash',
    animations = 'resource.animation[]',
    geometries = 'resource.geometry[]',
  },
  ['resource.animation'] = {
    id = 'string',
    width = 'integer',
    height = 'integer',
    frame_start = 'integer',
    frame_end = 'integer',
    playback = 'constant',
    fps = 'integer',
    flip_vertical = 'boolean',
    flip_horizontal = 'boolean'
  },
  ['resource.geometry'] = {
    id = 'string',
    vertices = 'number[]',
    uvs = 'number[]',
    indices = 'number[]'
  },
  ['physics.raycast_response'] = {
    fraction = 'number',
    position = 'vector3',
    normal = 'vector3',
    id = 'hash',
    group = 'hash',
    request_id = 'number'
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
  constant = 'userdata',

  resource_data = 'userdata',
  constant_buffer = 'userdata',
  render_target = 'userdata',
  render_predicate = 'userdata',
  resource_handle = 'number|userdata',
  buffer_stream = 'userdata',
  buffer_data = 'userdata',

  b2BodyType = 'number',
  b2World = 'userdata',
  b2Body = 'userdata',

  socket_client = 'userdata',
  socket_master = 'userdata',
  socket_unconnected = 'userdata',
}

config.disabled_diagnostics = {
  'lowercase-global',
  'missing-return',
  'duplicate-doc-param',
  'duplicate-set-field'
}

return config
