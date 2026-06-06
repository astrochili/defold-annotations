local utils = require 'src.utils'

local M = {}

local SEP = package.config:sub(1, 1)
local ROOT = 'tests'

local RELOAD_MODULES = {
  'src.config',
  'src.terminal',
  'src.fetcher',
  'src.meta',
  'src.generator',
  'src.enums',
}

local RULE_MODULES = {
  aliases = 'rules.aliases',
  classes = 'rules.classes',
  disabled_diagnostics = 'rules.disabled_diagnostics',
  enums = 'rules.enums',
  generics = 'rules.generics',
  ignored_funcs = 'rules.ignored_funcs',
  known_types = 'rules.known_types',
  replacements = 'rules.replacements',
}

local function quote(path)
  return '"' .. path .. '"'
end

local function mkdir_p(path)
  assert(os.execute('mkdir -p ' .. quote(path)))
end

local function rm_rf(path)
  os.execute('rm -rf ' .. quote(path))
end

local function list_files(folder, extension)
  local command = 'find ' .. quote(folder) .. ' -type f'
  if extension then
    command = command .. ' -name "*.' .. extension .. '"'
  end

  local pipe = io.popen(command)
  assert(pipe, 'Unable to list files in ' .. folder)

  local files = {}
  for line in pipe:lines() do
    table.insert(files, line)
  end
  pipe:close()

  table.sort(files)
  return files
end

local function copy_file(from_path, to_path)
  local body = utils.read_file(from_path)
  utils.save_file(body, to_path)
end

local function snapshot_loaded(names)
  local snapshot = {}
  for _, name in ipairs(names) do
    snapshot[name] = package.loaded[name]
  end
  return snapshot
end

local function restore_loaded(snapshot)
  for name, value in pairs(snapshot) do
    package.loaded[name] = value
  end
end

local function clear_loaded(names)
  for _, name in ipairs(names) do
    package.loaded[name] = nil
  end
end

function M.path(...)
  return utils.path(...)
end

function M.fixture_path(...)
  return utils.path(ROOT, 'fixtures', ...)
end

function M.snapshot_path(name)
  return utils.path(ROOT, 'snapshots', name)
end

function M.read(path)
  return utils.read_file(path)
end

function M.load_fixture_module(name)
  return dofile(M.fixture_path('modules', name))
end

function M.list_json_fixtures(folder)
  return list_files(M.fixture_path('docs', folder), 'json')
end

function M.read_snapshot(name)
  return M.read(M.snapshot_path(name))
end

function M.with_rule_overrides(overrides, fn)
  overrides = overrides or {}

  local previous_loaded = snapshot_loaded(RELOAD_MODULES)
  local previous_rules = {}

  for key, module_name in pairs(RULE_MODULES) do
    previous_rules[module_name] = {
      loaded = package.loaded[module_name],
      preload = package.preload[module_name],
    }

    if overrides[key] ~= nil then
      package.loaded[module_name] = overrides[key]
      package.preload[module_name] = function()
        return overrides[key]
      end
    else
      package.loaded[module_name] = nil
      package.preload[module_name] = nil
    end
  end

  clear_loaded(RELOAD_MODULES)

  local ok, result, extra = pcall(fn)

  clear_loaded(RELOAD_MODULES)
  restore_loaded(previous_loaded)

  for module_name, state in pairs(previous_rules) do
    package.loaded[module_name] = state.loaded
    package.preload[module_name] = state.preload
  end

  if not ok then
    error(result, 0)
  end

  return result, extra
end

function M.load_app(overrides)
  return M.with_rule_overrides(overrides, function()
    return {
      config = require 'src.config',
      diagnostics = require 'src.diagnostics',
      fetcher = require 'src.fetcher',
      parser = require 'src.parser',
      patcher = require 'src.patcher',
      enums = require 'src.enums',
      meta = require 'src.meta',
      generator = require 'src.generator',
    }
  end)
end

function M.with_temp_config(config, name, fn)
  local base = utils.path('tmp', 'tests', name)
  local previous = {
    temp_folder = config.temp_folder,
    info_json = config.info_json,
    doc_zip = config.doc_zip,
    doc_folder = config.doc_folder,
    json_list_txt = config.json_list_txt,
    api_folder = config.api_folder,
  }

  rm_rf(base)
  mkdir_p(base)

  config.temp_folder = base
  config.info_json = utils.path(base, 'info.json')
  config.doc_zip = utils.path(base, 'ref-doc.zip')
  config.doc_folder = utils.path(base, 'doc')
  config.json_list_txt = utils.path(base, 'json_list.txt')
  config.api_folder = utils.path(base, 'defold_api')

  local ok, result, extra = pcall(fn, base)

  config.temp_folder = previous.temp_folder
  config.info_json = previous.info_json
  config.doc_zip = previous.doc_zip
  config.doc_folder = previous.doc_folder
  config.json_list_txt = previous.json_list_txt
  config.api_folder = previous.api_folder

  rm_rf(base)

  if not ok then
    error(result, 0)
  end

  return result, extra
end

function M.with_staged_patches(names, fn)
  names = names or {}
  local staged_paths = {}

  for _, name in ipairs(names) do
    local source_path = M.fixture_path('patches', name)
    local target_path = utils.path('patches', name)
    copy_file(source_path, target_path)
    table.insert(staged_paths, target_path)
  end

  local ok, result, extra = pcall(fn)

  for _, staged_path in ipairs(staged_paths) do
    os.remove(staged_path)
  end

  if not ok then
    error(result, 0)
  end

  return result, extra
end

function M.read_generated(api_folder)
  local outputs = {}

  if not utils.exists(api_folder) then
    return outputs
  end

  for _, path in ipairs(list_files(api_folder, 'lua')) do
    outputs[path:match('([^/\\]+)$')] = utils.read_file(path)
  end

  return outputs
end

function M.run_pipeline(opts)
  opts = opts or {}
  local app = M.load_app(opts.rules)
  local result = {}

  app.diagnostics.reset()

  M.with_temp_config(app.config, opts.name or 'pipeline', function()
    local json_paths = opts.json_paths or M.list_json_fixtures(opts.docs_dir)
    local modules = app.parser.parse_json(json_paths)

    M.with_staged_patches(opts.patch_files, function()
      app.patcher.patch_modules(modules)
    end)

    local registry = {
      aliases = {},
      alias_names = {},
      member_to_alias = {},
      ordered_names = {},
    }

    if not opts.skip_enums then
      registry = app.enums.build_registry(modules)
      app.enums.inject_aliases(modules, registry)
    end

    if opts.include_meta then
      table.insert(modules, app.meta.make_module())
    end

    if opts.generate ~= false then
      app.generator.generate_api(modules, opts.version or 'test-version', registry)
      result.outputs = M.read_generated(app.config.api_folder)
    end

    result.modules = modules
    result.registry = registry
    result.errors = app.diagnostics.get_errors()
  end)

  return result
end

return M
