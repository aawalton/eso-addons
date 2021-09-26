ShowTTCPrice = {name = "ShowTTCPrice", version = 6, variableVersion = 3}
ShowTTCPrice.DefaultSavedVars = {PreferredPrice = "Average", PriceToShow = "Stack", RoundNumbers = true}

ShowTTCPrice.Prices = {None = "None", Average = "Avg", Suggested = "SuggestedPrice", Min = "Min", Max = "Max"}
local coinIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
local settings = {}

function ShowTTCPrice.SetupSettings()

	local LAM = LibAddonMenu2
	
	if not LAM then return end
	
	settings = ShowTTCPrice.savedVariables
	
	local panelName = "ShowTTCPriceSettings"
	
	local panelData = {
		type = "panel",
		name = "Show TTC Price",
		displayName = "Show TTC Price",
		author = "MarioKness (EU)",
		version = ShowTTCPrice.version,
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
		}
	}
	LAM:RegisterOptionControls(panelName, optionsData)
	
end

local function CommaValue(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
        break
        end
    end
    return formatted
end

function ShowTTCPrice.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return CommaValue(math.floor(num * mult + 0.5) / mult)
end

function ShowTTCPrice.ChangeInventoryPrice(control, slot)
	if settings.PreferredPrice == "None" then return end
	local data = control.dataEntry.data
    local bagId = data.bagId
    local slotIndex = data.slotIndex
    local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
	if not itemLink then return end
	local sellPriceControl = control:GetNamedChild("SellPrice")
	if sellPriceControl == nil then return end
	local priceDataTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	if priceDataTTC == nil then return end
	local PreferredPrice = ShowTTCPrice.Prices[settings.PreferredPrice]
	if priceDataTTC[PreferredPrice] == nil then return end
	data.TTCsellPrice = tonumber(priceDataTTC[PreferredPrice])
	data.TTCstackSellPrice = (data.TTCsellPrice * data.stackCount)
	local defaultPrice = data.sellPrice
	if data.TTCsellPrice < defaultPrice then return end --if selling to merchants is better, do nothing
	local newPriceText = ""
	if settings.RoundNumbers then
		data.TTCsellPrice = ShowTTCPrice.round(data.TTCsellPrice)
		data.TTCstackSellPrice = ShowTTCPrice.round(data.TTCstackSellPrice)
	end
	local priceToShowToText = {
		["Both"] = "|cfcba03"..data.TTCstackSellPrice.."|r\n|cffffff(|r|cfc8403"..data.TTCsellPrice.."|r|cffffff)|r"..coinIcon,
		["Stack"] = "|cfcba03"..data.TTCstackSellPrice.."|r"..coinIcon,
		["Unit"] = "|cfc8403"..data.TTCsellPrice.."|r"..coinIcon
	}
	local priceToShow = settings.PriceToShow
	local newPriceText = priceToShowToText[priceToShow]
	sellPriceControl:SetText(newPriceText)
end 

function ShowTTCPrice.Initialize()
	for _, i in pairs(PLAYER_INVENTORY.inventories) do --show inventory and craft bag prices
		local listView = i.listView
		if listView and listView.dataTypes and listView.dataTypes[1] and listView:GetName() ~= "ZO_PlayerInventoryQuest" then
			local originalCall = listView.dataTypes[1].setupCallback
			listView.dataTypes[1].setupCallback = function(control, slot)
				originalCall(control, slot)
				local currentScene = SCENE_MANAGER:GetCurrentScene()
				if currentScene == STABLES_SCENE then return end
				ShowTTCPrice.ChangeInventoryPrice(control, slot)
			end
		end
	end
	SecurePostHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot) --show prices while deconstructing
        ShowTTCPrice.ChangeInventoryPrice(control, slot)
	end)
end

function ShowTTCPrice.OnAddOnLoaded(event, addonName)
	if addonName == ShowTTCPrice.name then
		EVENT_MANAGER:UnregisterForEvent(ShowTTCPrice.name, EVENT_ADD_ON_LOADED)
		ShowTTCPrice.savedVariables = ZO_SavedVars:NewAccountWide("ShowTTCPriceVars", ShowTTCPrice.variableVersion, GetWorldName(), ShowTTCPrice.DefaultSavedVars)
		if not TamrielTradeCentrePrice then return end
		ShowTTCPrice.SetupSettings()
		ShowTTCPrice.Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(ShowTTCPrice.name, EVENT_ADD_ON_LOADED, ShowTTCPrice.OnAddOnLoaded)
