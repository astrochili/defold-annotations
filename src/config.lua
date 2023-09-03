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

--- Replacements for param names
config.param_name_replacements = {
    ['repeat'] = 'repeating',
    ['v'] = '...'
}

--- Replacements for param types
config.param_type_replacements = {
    ['resource'] = 'resource_data',
    ['buffer'] = 'buffer_data'
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
        x = 'number',
        y = 'number',
        z = 'number'
    },
    vector4 = {
        x = 'number',
        y = 'number',
        z = 'number',
        w = 'number'
    },
    url = {
        socket = 'hash',
        path = 'hash',
        fragment = 'hash'
    },
    ['socket.dns'] = {
        is_global = true
    }
}

---Known aliases
config.known_aliases = {
    bool = 'boolean',
    float = 'number',
    quaternion = 'vector4',
    quat = 'quaternion',
    vector = 'vector4|vector3',
    hash = 'userdata',
    constant = 'userdata',
    object = 'userdata',
    matrix4 = 'userdata',
    node = 'userdata',
    constant_buffer = 'userdata',
    render_target = 'userdata',
    predicate = 'userdata',
    bufferstream = 'userdata',
    array = 'table',
    handle = 'number',
    client = 'userdata',
    master = 'userdata',
    unconnected = 'userdata',
    resource_data = 'userdata',
    buffer_data = 'userdata'
}

config.disabled_diagnostics = {
    'lowercase-global',
    'missing-return',
    'duplicate-doc-param',
    'duplicate-set-field'
}

return config
