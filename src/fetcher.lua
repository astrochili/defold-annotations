--[[
  fetcher.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local json = require 'libs.json'
local config = require 'src.config'
local utils = require 'src.utils'
local terminal = require 'src.terminal'

local fetcher = {}

--
-- Public

---Fetch the latest Defold version
---@return string version like `1.0.0`
function fetcher.fetch_version()
  print('-- Version Fetching')

  local url = config.info_url()
  terminal.download(url, config.info_json)

  local info_content = utils.read_file(config.info_json)
  local info = json.decode(info_content)
  print('The "' .. config.info_json .. '" has been successfully decoded')

  local version = info.version

  assert(version, 'Can\'t find the version info in "' .. config.info_json .. '"')
  print('The latest Defold version is ' .. version)

  print('-- Version Fetched Successfully!\n')
  return version
end

---Fetch and unzip the Defold documantation files
---@param version_or_path string like `1.0.0' or 'some/docs'
---@return string[] json_paths an array of paths to json files
function fetcher.fetch_docs(version_or_path)
  print('-- Documentation Fetching')

  local json_list_filename = config.json_list_txt

  if utils.exists(version_or_path) then
    terminal.copy_folder(version_or_path, config.doc_folder)
  else
    local url = config.doc_url(version_or_path)
    terminal.download(url, config.doc_zip)
    terminal.unzip(config.doc_zip, config.temp_folder)
  end

  terminal.list_all_files(config.doc_folder, config.json_extension, json_list_filename)

  local json_list_content = utils.read_file(json_list_filename)
  local json_paths = utils.get_lines(json_list_content)

  print('Detected ' .. #json_paths .. ' *.json files at "' .. config.doc_folder .. '"')

  for index, json_path in ipairs(json_paths) do
    json_paths[index] = config.doc_folder .. config.folder_separator .. json_path
  end

  print('-- Documentation Fetched Successfully!\n')
  return json_paths
end

return fetcher
