local luaunit = require 'luaunit'
local config = require 'src.config'
local generator = require 'src.generator'
local utils = require 'src.utils'

local original_api_folder = config.api_folder
local next_tmp_id = 0

local function get_tmp_dir()
  next_tmp_id = next_tmp_id + 1
  return string.format('tests/tmp_api_%d', next_tmp_id)
end

local function output_path(namespace)
  return string.format('%s/%s.lua', config.api_folder, namespace)
end

local function make_constant(name, description)
  return {
    type = 'CONSTANT',
    name = name,
    description = description or ''
  }
end

local gui_module = {
  info = {
    namespace = 'gui',
    brief = 'Test GUI module',
    description = 'Used to test constant aliases'
  },
  elements = {
    make_constant('gui.PLAYBACK_LOOP_FORWARD', 'loop forward'),
    make_constant('gui.PLAYBACK_LOOP_BACKWARD', 'loop backward'),
    make_constant('gui.PLAYBACK_ONCE_FORWARD', 'once forward'),
    make_constant('gui.PLAYBACK_ONCE_BACKWARD', 'once backward'),
    make_constant('gui.PLAYBACK_ONCE_PINGPONG', 'once ping pong'),
    make_constant('gui.PROP_POSITION', 'position property'),
    make_constant('gui.PROP_SCALE', 'scale property'),
    make_constant('gui.EASING_LINEAR', 'linear easing'),
    make_constant('gui.EASING_INQUAD', 'quadratic easing'),
    {
      type = 'FUNCTION',
      name = 'gui.animate',
      description = 'Test animation function',
      parameters = {
        {
          name = 'node',
          doc = 'node to animate',
          types = { 'node' },
          is_optional = 'False'
        },
        {
          name = 'property',
          doc = 'property to animate\n<ul>\n<li><code>gui.PROP_POSITION</code></li>\n<li><code>gui.PROP_SCALE</code></li>\n</ul>',
          types = { 'string', 'constant' },
          is_optional = 'False'
        },
        {
          name = 'easing',
          doc = 'easing mode\n<ul><li><code>gui.EASING_*</code></li></ul>',
          types = { 'vector', 'constant' },
          is_optional = 'False'
        },
        {
          name = 'playback',
          doc = table.concat({
            'playback mode',
            '<ul>',
            '<li><code>gui.PLAYBACK_ONCE_FORWARD</code></li>',
            '<li><code>gui.PLAYBACK_ONCE_BACKWARD</code></li>',
            '<li><code>gui.PLAYBACK_ONCE_PINGPONG</code></li>',
            '<li><code>gui.PLAYBACK_LOOP_FORWARD</code></li>',
            '<li><code>gui.PLAYBACK_LOOP_BACKWARD</code></li>',
            '</ul>'
          }, '\n'),
          types = { 'constant' },
          is_optional = 'True'
        }
      },
      returnvalues = {}
    }
  }
}

local function cleanup(should_delete)
  if should_delete then
    os.execute('rm -rf ' .. config.api_folder)
  end

  config.api_folder = original_api_folder
end

local TestGeneratorAlias = {}

function TestGeneratorAlias:setUp()
  config.api_folder = get_tmp_dir()
end

function TestGeneratorAlias:tearDown()
  cleanup(os.getenv('KEEP_GENERATOR_TEST_OUTPUT') ~= '1')
end

function TestGeneratorAlias:test_alias_generation_for_property_and_playback_enums()
  generator.generate_api({ gui_module }, 'test')

  local output = utils.read_file(output_path('gui'))

  luaunit.assertStrContains(output, '---@field PLAYBACK_LOOP_FORWARD integer')
  luaunit.assertStrContains(output, '---@alias gui.PLAYBACK')
  luaunit.assertStrContains(output, '---@param playback? gui.PLAYBACK|integer')
  luaunit.assertStrContains(output, '---@field PROP_POSITION string')
  luaunit.assertStrContains(output, '---@alias gui.PROP')
  luaunit.assertStrContains(output, '---@param property string|gui.PROP')
  luaunit.assertStrContains(output, '---@alias gui.EASING')
  luaunit.assertStrContains(output, '---@param easing vector|gui.EASING|integer')
end

function TestGeneratorAlias:test_cross_namespace_constant_aliases()
  local graphics_module = {
    info = { namespace = 'graphics', brief = 'Graphics', description = '' },
    elements = {
      make_constant('graphics.BUFFER_TYPE_COLOR0_BIT'),
      make_constant('graphics.BUFFER_TYPE_COLOR1_BIT'),
      make_constant('graphics.BUFFER_TYPE_DEPTH_BIT'),
      {
        type = 'FUNCTION',
        name = 'graphics.describe_buffer',
        description = 'Using buffer type constants',
        parameters = {
          {
            name = 'buffer_type',
            doc = 'buffer type',
            types = {
              'graphics.BUFFER_TYPE_COLOR0_BIT',
              'graphics.BUFFER_TYPE_COLOR1_BIT',
              'graphics.BUFFER_TYPE_DEPTH_BIT'
            },
            is_optional = 'False'
          }
        },
        returnvalues = {}
      }
    }
  }

  local render_module = {
    info = { namespace = 'render', brief = 'Render', description = '' },
    elements = {
      {
        type = 'FUNCTION',
        name = 'render.enable_texture',
        description = 'Tests cross-namespace constants',
        parameters = {
          { name = 'binding', doc = 'binding', types = { 'number' }, is_optional = 'False' },
          { name = 'handle_or_name', doc = 'handle', types = { 'texture' }, is_optional = 'False' },
          {
            name = 'buffer_type',
            doc = 'supported constants',
            types = {
              'type:graphics.BUFFER_TYPE_COLOR0_BIT',
              'graphics.BUFFER_TYPE_COLOR1_BIT',
              'graphics.BUFFER_TYPE_DEPTH_BIT'
            },
            is_optional = 'True'
          }
        },
        returnvalues = {}
      }
    }
  }

  generator.generate_api({ graphics_module, render_module }, 'test')

  local graphics_output = utils.read_file(output_path('graphics'))
  local render_output = utils.read_file(output_path('render'))

  luaunit.assertStrContains(graphics_output, '---@alias graphics.BUFFER_TYPE')
  luaunit.assertStrContains(render_output, '---@param buffer_type? graphics.BUFFER_TYPE|integer')
end

function TestGeneratorAlias:test_alias_injection_for_table_and_function_types()
  local buffer_module = {
    info = { namespace = 'buffer', brief = 'Buffer', description = '' },
    elements = {
      make_constant('buffer.VALUE_TYPE_UINT8'),
      make_constant('buffer.VALUE_TYPE_FLOAT32'),
      {
        type = 'FUNCTION',
        name = 'buffer.set_metadata',
        description = 'Set metadata',
        parameters = {
          { name = 'buf', doc = 'buffer', types = { 'buffer_data' }, is_optional = 'False' },
          { name = 'metadata_name', doc = 'name', types = { 'hash' }, is_optional = 'False' },
          { name = 'values', doc = 'values', types = { 'number' }, is_optional = 'False' },
          {
            name = 'value_type',
            doc = 'value types',
            types = {
              'buffer.VALUE_TYPE_UINT8',
              'buffer.VALUE_TYPE_FLOAT32'
            },
            is_optional = 'False'
          }
        },
        returnvalues = {}
      },
      {
        type = 'FUNCTION',
        name = 'buffer.get_metadata',
        description = 'Get metadata',
        parameters = {
          { name = 'buf', doc = 'buffer', types = { 'buffer_data' }, is_optional = 'False' },
          { name = 'metadata_name', doc = 'name', types = { 'hash' }, is_optional = 'False' }
        },
        returnvalues = {
          {
            name = 'values',
            doc = 'values',
            types = { 'number' },
            is_optional = 'False'
          },
          {
            name = 'value_type',
            doc = 'value type',
            types = {
              'buffer.VALUE_TYPE_UINT8',
              'buffer.VALUE_TYPE_FLOAT32',
              'nil'
            },
            is_optional = 'True'
          }
        }
      }
    }
  }

  generator.generate_api({ buffer_module }, 'test')

  local buffer_output = utils.read_file(output_path('buffer'))

  luaunit.assertStrContains(buffer_output, '---@alias buffer.VALUE_TYPE')
  luaunit.assertStrContains(buffer_output, '---@param value_type buffer.VALUE_TYPE|integer')
  luaunit.assertStrContains(buffer_output, '---@return buffer.VALUE_TYPE|nil|integer value_type')
end

function TestGeneratorAlias:test_proactive_alias_generation_without_function_references()
  local module = {
    info = { namespace = 'colors', brief = 'Colors', description = '' },
    elements = {
      -- Just constants, NO functions that reference them
      -- The generate_constant_aliases() should still create the alias
      make_constant('colors.RGB_RED'),
      make_constant('colors.RGB_GREEN'),
      make_constant('colors.RGB_BLUE')
    }
  }
  
  generator.generate_api({ module }, 'test')
  
  local output = utils.read_file(output_path('colors'))
  
  -- Should have the alias even though no function references these constants
  luaunit.assertStrContains(output, '---@alias colors.RGB')
  luaunit.assertStrContains(output, '---| `colors.RGB_RED`')
  luaunit.assertStrContains(output, '---| `colors.RGB_GREEN`')
  luaunit.assertStrContains(output, '---| `colors.RGB_BLUE`')
end

function TestGeneratorAlias:test_multilevel_namespace_constants()
  -- Multi-level namespace constants like foo.bar.CONST should be in foo.bar.lua
  -- with field name CONST (not bar.CONST)
  local module = {
    info = { namespace = 'foo.bar', brief = 'Foo Bar', description = '' },
    elements = {
      make_constant('foo.bar.SETTING_A'),
      make_constant('foo.bar.SETTING_B')
    }
  }
  
  generator.generate_api({ module }, 'test')
  
  local output = utils.read_file(output_path('foo.bar'))
  
  -- Constants should have simple field names (no namespace prefix)
  luaunit.assertStrContains(output, '---@field SETTING_A integer')
  luaunit.assertStrContains(output, '---@field SETTING_B integer')
  
  -- Should NOT have the partial namespace in the field name
  luaunit.assertNotStrContains(output, '---@field bar.SETTING')
  
  -- Alias should use full names
  luaunit.assertStrContains(output, '---@alias foo.bar.SETTING')
  luaunit.assertStrContains(output, '---| `foo.bar.SETTING_A`')
end

_G.TestGeneratorAlias = TestGeneratorAlias

return TestGeneratorAlias
