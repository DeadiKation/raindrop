-- this is a utility library, it is assumed that base functions are kept within this file. More info later.

CL = CLIENT
SV = SERVER

rain.util = {}

function rain.util.log(sText, sTag)

	if !sTag then
		sTag = "PRINT"
	else
		sTag = string.upper(sTag)
	end

	if SV then
		MsgC(Color(45,137,239),"[RAIN]")
		MsgC(Color(110,110,255,255)," [SV]")
		MsgC(Color(255,0,0,255)," ["..sTag.."] ")
		MsgC(Color(110,110,255,255), sText.."\n")
	elseif CL then
		MsgC(Color(45,137,239),"[RAIN]")
		MsgC(Color(255,196,13)," [CL]")
		MsgC(Color(255,0,0,255)," ["..sTag.."] ")
		MsgC(Color(255,196,13), sText.."\n")
	end
end

function rain.util.rawinclude(sFilePath)
	include(sFilePath)
	rain.util.log(sFilePath, "loaded file")
end

function rain.util.include(sFilePath)
	local explode = string.Explode("/", sFilePath)
	local filename = explode[#explode]
	explode[#explode] = nil
	local filepath = string.Implode("/", explode)
	filepath = filepath.."/"..filename

	if string.StartWith(filename, "sv_") then
		if SV then
			rain.util.rawinclude(filepath)
		end
	elseif string.StartWith(filename, "sh_") or string.StartWith(filename, "lib_") or string.StartWith(filename, "ut_") then
		if SV then
			rain.util.rawinclude(filepath)
			AddCSLuaFile(filepath)
		elseif CL then
			rain.util.rawinclude(filepath)
		end
	elseif string.StartWith(filename, "cl_") then
		if SV then
			AddCSLuaFile(filepath)
		elseif CL then
			rain.util.rawinclude(filepath)
		end
	end
end

function rain.util.loadlibraries()
	rain.util.include("libraries/ut_loadorder.lua")
	
	for _, lib in pairs(rain.util.loadorder) do
		rain.util.include("libraries/"..lib..".lua")
	end
end

--[[
	Name: dir
	Purpose: sets up a directory to run FileIO library operations
--]]

function rain.util.dir(sFolderPath)
	return "gamemodes/raindrop/gamemode/"..sFolderPath, "GAME"
end

--[[
	Name: Load Folder
	Purpose: Loads an entire folder, including all the files properly.
--]]

function rain.util.loadfolder(sFolderPath)
	local sFolderPath = sFolderPath.."/"

	local a, b = rain.util.dir(sFolderPath)

	if !file.Exists(a, b) then
		return
	end

	local files = file.Find(a.."*.lua", b) 

	for _, file in pairs(files) do
		rain.util.include(sFolderPath..file)
	end
end

--[[
	Name: Load Raindrop
	Purpose: Loads the gamemode
--]]

function rain.util.loadraindrop()
	rain.util.include("ut_loadorder.lua")
	for _, folder in pairs(rain.util.loadorder) do
		rain.util.loadfolder(folder)
	end
end

if SV then
	function rain.util.initraindrop()
		rain.db.connect(rain.cfg.db.address, rain.cfg.db.username, rain.cfg.db.password, rain.cfg.db.database, rain.cfg.db.port)
	end
end	