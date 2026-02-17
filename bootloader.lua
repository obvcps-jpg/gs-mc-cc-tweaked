local REPO_URL = "https://raw.githubusercontent.com/obvcps-jpg/gs-mc-cc-tweaked/refs/heads/main"

local function downloadFile(url, filepath)
  print("Downloading: " .. filepath)

  local response = http.get(url)
  if not response then
    print("Error: Failed to download: " .. url)
    return false
  end

  local content = response.readAll()
  response.close()

  local ok, err = pcall(function()
    local file = fs.open(filepath, "w")
    file.write(content)
    file.close()
  end)
  
  if not ok then
    print("Error: Failed to write " .. filepath .. " - " .. err)
    return false
  end

  print("Downloaded: " .. filepath)
  return true
end

local function loadPrograms()
  local programs = {}
  if fs.exists("/alexCC/programs.txt") then
    local file = fs.open("/alexCC/programs.txt", "r")
    local line = file.readLine()
    while line do
      line = line:gsub("^%s+|%s+$", "") -- trim whitespace
      if line ~= "" then
        table.insert(programs, line)
      end
      line = file.readLine()
    end
    file.close()
  end
  return programs
end

-- Download programs.txt from repository
local programs_url = REPO_URL .. "/programs.txt"
if not downloadFile(programs_url, "/alexCC/programs.txt") then
  print("Error: Could not download programs.txt")
  print("Make sure you're running from the home directory, not /rom/")
  return
end

local PROGRAMS = loadPrograms()

local function ensureDirectory(path)
  if not fs.exists(path) then
    fs.makeDir(path)
  end
end

local function setupStartupAutoupdater()
  ensureDirectory("startup")
  
  local autoupdater_code = [[-- Alex Auto-updater startup script
-- Automatically updates programs on boot

local REPO_URL = "]] .. REPO_URL .. [["

local function downloadFile(url, filepath)
  local response = http.get(url)
  if not response then
    return false
  end
  
  local content = response.readAll()
  response.close()
  
  local file = fs.open(filepath, "w")
  file.write(content)
  file.close()
  
  return true
end

local function loadPrograms()
  local programs = {}
  if fs.exists("/alexCC/programs.txt") then
    local file = fs.open("/alexCC/programs.txt", "r")
    local line = file.readLine()
    while line do
      line = line:gsub("^%s+|%s+$", "") -- trim whitespace
      if line ~= "" then
        table.insert(programs, line)
      end
      line = file.readLine()
    end
    file.close()
  end
  return programs
end

-- Download programs.txt from repository
local programs_url = REPO_URL .. "/alexCC/programs.txt"
if not downloadFile(programs_url, "/alexCC/programs.txt") then
  print("Warning: Failed to download programs.txt")
end

local PROGRAMS = loadPrograms()

-- Update all programs
local updated = false
for _, program in ipairs(PROGRAMS) do
  local url = REPO_URL .. "/" .. program
  if downloadFile(url, "/alexCC/" .. program) then
    updated = true
  end
end

if updated then
  print("Programs updated successfully!")
end
]]

  local startup_file = fs.open("startup/00_autoupdate.lua", "w")
  startup_file.write(autoupdater_code)
  startup_file.close()
  
  print("Autoupdater installed to startup/")
end

local function setupAutoMainRunner()
    local mainrunner_code = [[-- Alex Main-Runner startup script
-- Automatically runs main.lua on boot
shell.run("/alexCC/main.lua")
]]
  local startup_file = fs.open("startup/01_mainrunner.lua", "w")
  startup_file.write(mainrunner_code)
  startup_file.close()

  print("Main runner installed to startup/")
end

-- Main bootloader execution
print("=== ComputerCraft: Tweaked Alex API Bootloader ===")
print("Starting setup...")

ensureDirectory("/alexCC") -- Create directory for Alex API

-- Download programs.txt from repository
local programs_url = REPO_URL .. "/programs.txt"
downloadFile(programs_url, "/alexCC/programs.txt")

-- Download all programs
for _, program in ipairs(PROGRAMS) do
  local url = REPO_URL .. "/" .. program
  downloadFile(url, "/alexCC/" .. program)
end

-- Setup autoupdater
setupStartupAutoupdater()

-- setup main runner
setupAutoMainRunner()

shell.run("reboot")

print("=== Setup Complete ===")
print("Reboot to start autoupdater")