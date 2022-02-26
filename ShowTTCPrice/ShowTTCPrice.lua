local Addon = {name = "ShowTTCPrice", version = 9, SV_version = 3}

Addon.Prices = {None = "None", Average = "Avg", Suggested = "SuggestedPrice", Min = "Min", Max = "Max"}
local coinIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
local settings = {}
local Colors = {Orange = "|cFCBA03", DarkOrange = "|cFC8403", White = "|cFFFFFF", Green = "|c24FC03", DarkGreen = "|c20B00B"}

Addon.SV_default = {PreferredPrice = "Suggested", PriceToShow = "Both", RoundNumbers = true, IgnoreBoundItems = true, IgnoreTrash = false, HighlightReq = false, DesiredValue = 5000, MinimumReq = false, RequiredValue = 25}

function Addon.SetupSettings()

	local LAM = LibAddonMenu2
	if not LAM then return end
	
	settings = Addon.savedVariables
	
	local panelName = "ShowTTCPriceSettings"
	
	local panelData = {
		type = "panel",
		name = "Show TTC Price",
		displayName = "Show TTC Price",
		author = "MarioKness",
		version = tostring(Addon.version),
		registerForDefaults = true}
		
	LAM:RegisterAddonPanel(panelName, panelData)
	
	local optionsData = {
		{
		type = "dropdown",
		name = "Preferred price",
		tooltip = "None = default Elder Scrolls Online prices",
		choices = {"None", "Suggested", "Average", "Min", "Max"},
		getFunc = function() return settings.PreferredPrice end,
		setFunc = function(choice) settings.PreferredPrice = choice end,
		default = Addon.SV_default.PreferredPrice
		},
		{
		type = "dropdown",
		name = "Price to show",
		choices = {"Stack", "Unit", "Both"},
		getFunc = function() return settings.PriceToShow end,
		setFunc = function(choice) settings.PriceToShow = choice end,
		default = Addon.SV_default.PriceToShow
		},
		{
		type = "checkbox",
		name = "Round numbers",
		getFunc = function() return settings.RoundNumbers end,
		setFunc = function(value) settings.RoundNumbers = value end,
		default = Addon.SV_default.RoundNumbers
		},
		{
		type = "checkbox",
		name = "Ignore bound items",
		getFunc = function() return settings.IgnoreBoundItems end,
		setFunc = function(value) settings.IgnoreBoundItems = value end,
		default = Addon.SV_default.IgnoreBoundItems
		},
		{
		type = "checkbox",
		name = "Ignore items of type 'Trash'",
		getFunc = function() return settings.IgnoreTrash end,
		setFunc = function(value) settings.IgnoreTrash = value end,
		default = Addon.SV_default.IgnoreTrash
		},
		{
		type = "divider", alpha = 1, width = "full",
		},
		{
		type = "checkbox",
		name = "Highlight above value",
		tooltip = "Highlight items whose price is at or above Desired value",
		getFunc = function() return settings.HighlightReq end,
		setFunc = function(value) settings.HighlightReq = value end,
		default = Addon.SV_default.HighlightReq
		},
		{
		type = "slider",
		name = "Desired value",
		min = 0, max = 1000000, width = "full",
		getFunc = function() return settings.DesiredValue end,
		setFunc = function(value) settings.DesiredValue = value end,
		default = Addon.SV_default.DesiredValue
		},
		{
		type = "divider", alpha = 1, width = "full",
		},
		{
		type = "checkbox",
		name = "Ignore below value",
		tooltip = "Ignore items whose price is below Required value",
		getFunc = function() return settings.MinimumReq end,
		setFunc = function(value) settings.MinimumReq = value end,
		default = Addon.SV_default.MinimumReq
		},
		{
		type = "slider",
		name = "Required value",
		min = 0, max = 1000000, width = "full",
		getFunc = function() return settings.RequiredValue end,
		setFunc = function(value) settings.RequiredValue = value end,
		default = Addon.SV_default.RequiredValue
		},
	}
	LAM:RegisterOptionControls(panelName, optionsData)
	
end

function Addon.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Addon.ChangeInventoryPrice(control, slot)
	if settings.PreferredPrice == "None" then return end
	local data = control.dataEntry.data
	--if data.isJunk then return end --if marked as junk
    local bagId = data.bagId
    local slotIndex = data.slotIndex
    local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
	if not itemLink then return end
	if IsItemLinkBound(itemLink) and settings.IgnoreBoundItems then return end --ignore bound items
	local iType, siType = GetItemLinkItemType(itemLink)
	if siType == SPECIALIZED_ITEMTYPE_TRASH and settings.IgnoreTrash then return end --if trash
	local sellPriceControl = control:GetNamedChild("SellPrice")
	if sellPriceControl == nil then return end
	local priceDataTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	if priceDataTTC == nil then return end
	local PreferredPrice = Addon.Prices[settings.PreferredPrice]
	if priceDataTTC[PreferredPrice] == nil then return end
	data.TTCsellPrice = tonumber(priceDataTTC[PreferredPrice])
	data.TTCstackSellPrice = data.TTCsellPrice * data.stackCount
	if data.TTCsellPrice < data.sellPrice then return end --if default price is higher, do nothing
	if settings.RoundNumbers then --round
		data.TTCsellPrice = Addon.round(data.TTCsellPrice)
		data.TTCstackSellPrice = Addon.round(data.TTCstackSellPrice)
	end
	if settings.MinimumReq then --if required value
		if data.TTCsellPrice < settings.RequiredValue then return end
	end
	local newPriceText = ""
	local priceFormats = {
		["Both"] = Colors.Orange .. data.TTCstackSellPrice .. "|r\n" .. Colors.White .. "(|r" .. Colors.DarkOrange .. data.TTCsellPrice .. "|r" .. Colors.White .. ")|r " .. coinIcon,
		["Stack"] = Colors.Orange .. data.TTCstackSellPrice.. "|r " .. coinIcon,
		["Unit"] = Colors.DarkOrange .. data.TTCsellPrice .. "|r " .. coinIcon
	}
	local priceFormatsHighlighted = {
		["Both"] = Colors.Green .. data.TTCstackSellPrice .. "|r\n" .. Colors.White .. "(|r" .. Colors.DarkGreen .. data.TTCsellPrice .. "|r" .. Colors.White .. ")|r " .. coinIcon,
		["Stack"] = Colors.Green .. data.TTCstackSellPrice.. "|r " .. coinIcon,
		["Unit"] = Colors.DarkGreen .. data.TTCsellPrice .. "|r " .. coinIcon
	}
	local priceToShow = settings.PriceToShow
	if data.stackCount == 1 and priceToShow == "Both" then priceToShow = "Stack" end
	if settings.HighlightReq and data.TTCsellPrice >= settings.DesiredValue then --if desired value
		newPriceText = priceFormatsHighlighted[priceToShow]
	else
		newPriceText = priceFormats[priceToShow]
	end
	sellPriceControl:SetText(newPriceText)
end 

function Addon.Initialize()
	for _, i in pairs(PLAYER_INVENTORY.inventories) do --show prices in inventories
		local listView = i.listView
		if listView and listView.dataTypes and listView.dataTypes[1] and listView:GetName() ~= "ZO_PlayerInventoryQuest" then
			local originalCall = listView.dataTypes[1].setupCallback
			listView.dataTypes[1].setupCallback = function(control, slot)
				originalCall(control, slot)
				local currentScene = SCENE_MANAGER:GetCurrentScene()
				if currentScene == STABLES_SCENE then return end
				Addon.ChangeInventoryPrice(control, slot)
			end
		end
	end
	SecurePostHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot) --show prices while deconstructing
        Addon.ChangeInventoryPrice(control, slot)
	end)
end

function Addon.OnAddOnLoaded(event, addonName)
	if addonName ~= Addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)
	Addon.savedVariables = ZO_SavedVars:NewAccountWide("ShowTTCPriceVars", Addon.SV_version, GetWorldName(), Addon.SV_default)
	Addon.SetupSettings()
	Addon.Initialize()
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, Addon.OnAddOnLoaded)
