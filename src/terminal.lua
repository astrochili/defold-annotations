--[[
  terminal.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local config = require 'src.config'

local terminal = {}

--
-- Local

local is_windows = config.folder_separator == '\\'

---Wrap the path in double quotes
---@param path string
---@return string
local function quoted(path)
  return '"' .. path .. '"'
end

---Execute a command in the system shell
---@param unix_command string
---@param windows_command string
---@return boolean?
local function execute(unix_command, windows_command)
  if is_windows then
    local pipe = io.popen('powershell -command -', 'w')
    assert(pipe, 'Can\'t init powershell session')

    if pipe:write(windows_command) then
      return pipe:close()
    end
  else
    return os.execute(unix_command)
  end
end

--
-- Public

---Download the file at url
---@param url string
---@param output_path string
function terminal.download(url, output_path)
  print('Downloading the file from ' .. quoted(url))

  local result = execute(
    'curl -s -L ' .. url .. ' -o ' .. quoted(output_path),
    'Invoke-WebRequest -URI ' .. url .. ' -OutFile ' .. quoted(output_path) .. ' -UseBasicParsing'
  )

  assert(result, 'Error during downloading file "' .. url .. '"')
  print('The file ' .. quoted(url) .. ' has been successfully downloaded and saved as ' .. quoted(output_path))
end

---Delete the file
---@param path string
function terminal.delete_file(path)
  print('Deleting the file ' .. quoted(path))

  local result = execute(
    'rm -f ' .. quoted(path),
    'if (Test-Path ' .. quoted(path) .. ') { Remove-Item -Path ' .. quoted(path) .. ' -Force }'
  )

  assert(result, 'Error during deleting the file "' .. path .. '"')
  print('The file ' .. quoted(path) .. ' has been successfully deleted')
end

---Delete the folder with all the content
---@param path string
function terminal.delete_folder(path)
  print('Deleting the folder ' .. quoted(path))

  local result = execute(
    'rm -rf ' .. quoted(path),
    'if (Test-Path ' .. quoted(path) .. ') { Remove-Item -Path ' .. quoted(path) .. ' -Recurse -Force }'
  )

  assert(result, 'Error during deleting the folder "' .. path .. '"')
  print('The folder ' .. quoted(path) .. ' has been successfully deleted')
end

---Create a new folder
---@param path string
function terminal.create_folder(path)
  print('Creating the folder ' .. quoted(path))

  local result = execute(
    'mkdir ' .. quoted(path),
    'New-Item -Path ' .. quoted(path) .. ' -ItemType Directory | Out-Null'
  )

  assert(result, 'Error during creating a folder "' .. path .. '"')
  print('The folder ' .. quoted(path) .. ' has been successfully created')
end

---Unzip a zip archive
---@param path string
---@param destination string
function terminal.unzip(path, destination)
  print('Unzipping the archive ' .. quoted(path))

  local result = execute(
    'unzip -q ' .. quoted(path) .. ' -d ' .. quoted(destination),
    'Expand-Archive -Path ' .. quoted(path) .. ' -DestinationPath ' .. quoted(destination)
  )

  assert(result, 'Error during unziping the archive "' .. path .. '"')
  print('The archive ' .. quoted(path) .. ' has been successfully unzipped')
end

---Find all files in the folder with the exact extension and save the list in the output file
---@param folder_path string
---@param extension string
---@param output_path string
function terminal.list_all_files(folder_path, extension, output_path)
  print('Listing the ' .. extension .. ' files at ' .. quoted(folder_path))

  local result = execute(
    'find ' ..
    quoted(folder_path) .. ' -type f -name "*.' .. extension .. '" | egrep -o -e "[^/]+$" > ' .. quoted(output_path),
    'Get-ChildItem -Path ' ..
    quoted(folder_path) ..
    ' -Name -Filter "*.' .. extension .. '" | Out-File -FilePath ' .. quoted(output_path) .. ' -Encoding ASCII -append'
  )

  assert(result, 'Error during listing the files at "' .. folder_path .. '"')
  print('The list of ' .. extension .. ' files has been successfully listed and saved to ' .. quoted(output_path))
end

return terminal
