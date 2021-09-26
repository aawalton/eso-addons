--Register LLA
local LIBRARY_NAME = "LibLoadedAddons"
local lib_name_str = "[" .. LIBRARY_NAME .. "] "
assert(not _G[LIBRARY_NAME], "\'" .. LIBRARY_NAME .. "\' has already been loaded")

local lla = {}
lla.loadedAddons = {}
_G[LIBRARY_NAME] = lla


--- 	General Functions  --
---
--- The library will automatically add all enabled AddOns to it's internal table
--- LibLoadedAddons.loadedAddons with the addonName as the index and a table containing
--- this data as value:
--LibLoadedAddons.loadedAddons[name]["name"] 			= name					--String, from the folder/manifest TXT file name of the AddOn
--LibLoadedAddons.loadedAddons[name]["title"] 			= title					--String, from ##Title TXT manifest file's tag
--LibLoadedAddons.loadedAddons[name]["author"] 			= author				--String, from ##Author TXT manifest file's tag
--LibLoadedAddons.loadedAddons[name]["description"]		= description			--String, from ##Description TXT manifest file's tag
--LibLoadedAddons.loadedAddons[name]["enabled"] 		= tostring(enabled)		--Boolean, from AddOnManager
--LibLoadedAddons.loadedAddons[name]["loadState"] 		= tostring(loadState)	--AddOnLoadState, from AddOnManager
--LibLoadedAddons.loadedAddons[name]["isOutOfDate"] 	= tostring(isOutOfDate) --Boolean, from AddOn manager
--LibLoadedAddons.loadedAddons[name]["isLibrary"] 		= tostring(isLibrary)	--Boolean, Integer from ##IsLibrary: TXT manifest file's tag
--LibLoadedAddons.loadedAddons[name]["version"] 		= addOnVersion 			--Integer from ##AddOnVersion: TXT manifest file's tag
------------------------------------------------------------------------
--Registers an uniqueAddonName to the addon tables.
function lla:RegisterAddon(uniqueAddonName, versionNumber)
	if type(versionNumber) ~= "number" then 
		return false, lib_name_str .. "Version number must be a number."
	end
	if uniqueAddonName == nil or uniqueAddonName == "" then
		return false, lib_name_str .. "Addon not loaded, addon name not specified."
	end
--d("[LibLoadedAddons]RegisterAddon - uniqueAddonName: " ..tostring(uniqueAddonName) .. ", versionNr: " .. tostring(versionNumber))
	lla.loadedAddons[uniqueAddonName] = lla.loadedAddons[uniqueAddonName] or {}
	local version = lla.loadedAddons[uniqueAddonName]["version"]
	if version then
		if version == 0 then
			lla.loadedAddons[uniqueAddonName]["version"] = versionNumber
			return true
		else
			return false, lib_name_str .. "Version number already set for this addon"
		end
	else
		lla.loadedAddons[uniqueAddonName]["version"] = versionNumber
		return true
	end
	return false, lib_name_str .. "Addon not loaded, addon name not found."
end

--Unregisteres an uniqueAddonName from the addon's tables
function lla:UnregisterAddon(uniqueAddonName)
	if lla.loadedAddons[uniqueAddonName] then
		lla.loadedAddons[uniqueAddonName] = nil
		return true
	end
	return false, lib_name_str .. "Addon name was not registered"
end

--Returns boolean isLoaded, integer version
function lla:IsAddonLoaded(uniqueAddonName, onlyVersionNr)
	if uniqueAddonName == nil or uniqueAddonName == "" then
		return false, lib_name_str .. "Addon not loaded, addon name not specified."
	end
	if onlyVersionNr == nil then onlyVersionNr = true end
--d("[LibLoadedAddons]IsAddonLoaded - uniqueAddonName: " ..tostring(uniqueAddonName) .. ", onlyVersionNr: " .. tostring(onlyVersionNr))
	if lla.loadedAddons[uniqueAddonName] ~= nil then
		if lla.loadedAddons[uniqueAddonName]["version"] == nil then
			lla.loadedAddons[uniqueAddonName]["version"] = 0
		end
		if onlyVersionNr then
			return true, lla.loadedAddons[uniqueAddonName]["version"]
		else
			return true, lla.loadedAddons[uniqueAddonName]
		end
	end
	return false, nil
end

--Load the enabled AddOns from the ingame AddOnManager instance, and get their info + version from ##AddOnVersion tag
local function loadAddonInfo()
--d("[LibLoadedAddons]loadAddonInfo")
	--Get the addon manager
	lla.AM = GetAddOnManager()
	if lla.AM == nil then return end
	--Check for each addon in the manager, if it's enabled, and which version is loaded
	local numAddons = lla.AM:GetNumAddOns()
	for addonIndex = 1, numAddons do
		--* GetAddOnInfo(*luaindex* _addOnIndex_)
		--** _Returns:_ *string* _name_, *string* _title_, *string* _author_, *string* _description_, *bool* _enabled_, *[AddOnLoadState|#AddOnLoadState]* _state_, *bool* _isOutOfDate_, *bool* _isLibrary_
		local name, title, author, description, enabled, loadState, isOutOfDate, isLibrary = lla.AM:GetAddOnInfo(addonIndex)
		if enabled then
			local addOnVersion = lla.AM:GetAddOnVersion(addonIndex)
--d(">AddOn name: " .. tostring(name) .. ", version: " .. addOnVersion .. ", isOutOfDate: " ..tostring(isOutOfDate) .. ", isLibrary: " .. tostring(isLibrary))
			lla.loadedAddons[name] = lla.loadedAddons[name] or {}
			lla.loadedAddons[name]["name"] 			= name
			lla.loadedAddons[name]["title"] 		= title
			lla.loadedAddons[name]["author"] 		= author
			lla.loadedAddons[name]["description"]	= description
			lla.loadedAddons[name]["enabled"] 		= tostring(enabled)
			lla.loadedAddons[name]["loadState"] 	= tostring(loadState)
			lla.loadedAddons[name]["isOutOfDate"] 	= tostring(isOutOfDate)
			lla.loadedAddons[name]["isLibrary"] 	= tostring(isLibrary)
			lla.loadedAddons[name]["version"] 		= lla.loadedAddons[name]["version"] or addOnVersion
		end
	end
end

local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(LIBRARY_NAME, EVENT_ADD_ON_LOADED)
	loadAddonInfo()
end

local function OnAddOnLoaded(_event, addonName)
	lla.loadedAddons[addonName] = lla.loadedAddons[addonName] or {}
end
---------------------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(LIBRARY_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(LIBRARY_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)