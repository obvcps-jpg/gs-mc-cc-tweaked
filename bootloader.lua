-- ComputerCraft: Tweaked Bootloader
-- Downloads and installs programs, then sets up autoupdate in startup

local REPO_URL = "https://raw.githubusercontent.com/your-username/your-repo/main"

local function downloadFile(url, filepath)
  print("Downloading: " .. filepath)

  local response = http.get(url)
  if not response then
    error("Failed to download: " .. url)
  end

  local content = response.readAll()
  response.close()

  local file = fs.open(filepath, "w")
  file.write(content)
  file.close()

  print("Downloaded: " .. filepath)
end

local function loadPrograms()
  local programs = {}
  if fs.exists("programs.txt") then
    local file = fs.open("programs.txt", "r")
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
downloadFile(programs_url, "programs.txt")

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
  if fs.exists("/rom/alexCC/programs.txt") then
    local file = fs.open("/rom/alexCC/programs.txt", "r")
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
local programs_url = REPO_URL .. "/rom/alexCC/programs.txt"
if not downloadFile(programs_url, "/rom/alexCC/programs.txt") then
  print("Warning: Failed to download programs.txt")
end

local PROGRAMS = loadPrograms()

-- Update all programs
local updated = false
for _, program in ipairs(PROGRAMS) do
  local url = REPO_URL .. "/" .. program
  if downloadFile(url, program) then
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
  run("/rom/alexCC/main.lua")
]]
  local startup_file = fs.open("startup/01_mainrunner.lua", "w")
  startup_file.write(mainrunner_code)
  startup_file.close()

  print("Main runner installed to startup/")
end

-- Main bootloader execution
print("=== ComputerCraft: Tweaked Alex API Bootloader ===")
print("Starting setup...")

ensureDirectory("/rom/alexCC") -- Create directory for Alex API

-- Download programs.txt from repository
local programs_url = REPO_URL .. "/programs.txt"
downloadFile(programs_url, "/rom/alexCC/programs.txt")

-- Download all programs
for _, program in ipairs(PROGRAMS) do
  local url = REPO_URL .. "/" .. program
  downloadFile(url, "/rom/alexCC/" .. program)
end

-- Setup autoupdater
setupStartupAutoupdater()

print("=== Setup Complete ===")
print("Reboot to start autoupdater")