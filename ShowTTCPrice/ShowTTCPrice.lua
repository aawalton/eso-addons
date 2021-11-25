local Addon = {name = "ShowTTCPrice", version = 7, variableVersion = 3}
Addon.DefaultSavedVars = {PreferredPrice = "Average", PriceToShow = "Stack", RoundNumbers = true, IgnoreBoundItems = true, MinimumReq = false, DesiredValue = 0, HighlightReq = false}

Addon.Prices = {None = "None", Average = "Avg", Suggested = "SuggestedPrice", Min = "Min", Max = "Max"}
local coinIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
local settings = {}
local Colors = {Orange = "|cFCBA03", DarkOrange = "|cFC8403", White = "|cFFFFFF", Green = "|c24FC03", DarkGreen = "|c20B00B"}

function Addon.SetupSettings()

	local LAM = LibAddonMenu2
	
	if not LAM then return end
	
	settings = Addon.savedVariables
	
	local panelName = "ShowTTCPriceSettings"
	
	local panelData = {
		type = "panel",
		name = "Show TTC Price",
		displayName = "Show TTC Price",
		author = "MarioKness (EU)",
		version = Addon.version,
		registerForDefaults = true}
		
	LAM:RegisterAddonPanel(panelName, panelData)
	
	local optionsData = {
		{
		type = "dropdown",
		name = "Preferred price",
		choices = {"None", "Average", "Suggested", "Min", "Max"},
		getFunc = function() return settings.PreferredPrice end,
		setFunc = function(choice) settings.PreferredPrice = choice end,
		default = "Suggested"
		},
		{
		type = "dropdown",
		name = "Price to show",
		choices = {"Both", "Stack", "Unit"},
		getFunc = function() return settings.PriceToShow end,
		setFunc = function(choice) settings.PriceToShow = choice end,
		default = "Both"
		},
		{
		type = "checkbox",
		name = "Round numbers",
		getFunc = function() return settings.RoundNumbers end,
		setFunc = function(value) settings.RoundNumbers = value end,
		default = true
		},
		{
		type = "checkbox",
		name = "Ignore bound items",
		getFunc = function() return settings.IgnoreBoundItems end,
		setFunc = function(value) settings.IgnoreBoundItems = value end,
		default = true
		},
		{
		type = "divider", alpha = 1, width = "full",
		},
		{
		type = "slider",
		name = "Desired value",
		min = 0, max = 1000000, width = "full",
		getFunc = function() return settings.DesiredValue end,
		setFunc = function(value) settings.DesiredValue = value end,
		default = 0,
		},
		{
		type = "checkbox",
		name = "Highlight above value",
		tooltip = "If an item's TTC price is above the desired value, its price will be highlighted in green.",
		getFunc = function() return settings.HighlightReq end,
		setFunc = function(value) settings.HighlightReq = value end,
		default = false
		},
		{
		type = "checkbox",
		name = "Ignore below value",
		tooltip = "If an item's TTC price is below the desired value, only its default price will be shown.",
		getFunc = function() return settings.MinimumReq end,
		setFunc = function(value) settings.MinimumReq = value end,
		default = false
		}
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
    local bagId = data.bagId
    local slotIndex = data.slotIndex
    local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
	if not itemLink then return end
	if IsItemLinkBound(itemLink) == true and settings.IgnoreBoundItems == true then return end --ignore bound items
	local sellPriceControl = control:GetNamedChild("SellPrice")
	if sellPriceControl == nil then return end
	local priceDataTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	if priceDataTTC == nil then return end
	local PreferredPrice = Addon.Prices[settings.PreferredPrice]
	if priceDataTTC[PreferredPrice] == nil then return end
	data.TTCsellPrice = tonumber(priceDataTTC[PreferredPrice])
	data.TTCstackSellPrice = (data.TTCsellPrice * data.stackCount)
	local defaultPrice = data.sellPrice
	if data.TTCsellPrice < defaultPrice then return end --if selling to merchants is better, do nothing
	if settings.MinimumReq == true then --if minimum required value
		if data.TTCsellPrice < settings.DesiredValue then return end
	end
	local newPriceText = ""
	if settings.RoundNumbers then
		data.TTCsellPrice = Addon.round(data.TTCsellPrice)
		data.TTCstackSellPrice = Addon.round(data.TTCstackSellPrice)
	end
	local priceFormats = {
		["Both"] = Colors.Orange .. data.TTCstackSellPrice .. "|r\n" .. Colors.White .. "(|r" .. Colors.DarkOrange .. data.TTCsellPrice .. "|r" .. Colors.White .. ")|r" .. coinIcon,
		["Stack"] = Colors.Orange .. data.TTCstackSellPrice.. "|r" .. coinIcon,
		["Unit"] = Colors.DarkOrange .. data.TTCsellPrice .. "|r" .. coinIcon
	}
	local priceFormatsHighlighted = {
		["Both"] = Colors.Green .. data.TTCstackSellPrice .. "|r\n" .. Colors.White .. "(|r" .. Colors.DarkGreen .. data.TTCsellPrice .. "|r" .. Colors.White .. ")|r" .. coinIcon,
		["Stack"] = Colors.Green .. data.TTCstackSellPrice.. "|r" .. coinIcon,
		["Unit"] = Colors.DarkGreen .. data.TTCsellPrice .. "|r" .. coinIcon
	}
	local priceToShow = settings.PriceToShow
	if data.stackCount == 1 and priceToShow == "Both" then priceToShow = "Stack" end
	local newPriceText
	if settings.HighlightReq == true and data.TTCsellPrice > settings.DesiredValue then
		newPriceText = priceFormatsHighlighted[priceToShow]
	else
		newPriceText = priceFormats[priceToShow]
	end
	sellPriceControl:SetText(newPriceText)
end 

function Addon.Initialize()
	for _, i in pairs(PLAYER_INVENTORY.inventories) do --show inventory and craft bag prices
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
	Addon.savedVariables = ZO_SavedVars:NewAccountWide("ShowTTCPriceVars", Addon.variableVersion, GetWorldName(), Addon.DefaultSavedVars)
	if not TamrielTradeCentrePrice then return end
	Addon.SetupSettings()
	Addon.Initialize()
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, Addon.OnAddOnLoaded)
