--- ComputerCraft: Tweaked Globals
-- This file provides type definitions for CC:T globals

---@type { list: function, combine: function, getName: function, getSize: function, exists: function, isDir: function, isReadOnly: function, makeDir: function, move: function, copy: function, delete: function, open: function, getDrive: function, getFreeSpace: function, find: function, getDir: function }
fs = {}

---@type { get: function, post: function, checkUrlBlacklist: function }
http = {}

---@type { execute: function, setenv: function, getenv: function }
os = {}

---@type { write: function, writeln: function, blit: function, clear: function, clearLine: function, getCursorPos: function, setCursorPos: function, setCursorBlink: function, isColor: function, isColour: function, getSize: function, scroll: function, redirect: function, current: function }
term = {}

---@type { open: function, broadcast: function, receive: function, send: function, close: function, isOpen: function }
rednet = {}

---@type function
print = function() end

---@type function
sleep = function(time) end

---@type function
loadstring = function(str) end

---@type function
load = function(str) end

---@type { peripheral: { find: function, getNames: function, getType: function, isPresent: function, call: function, wrap: function } }
peripheral = {}
