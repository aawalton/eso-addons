local LCCC = LibCodesCommonCode
local LootLog = LootLog
local LootLogMulti = LootLog.modules.multi

local LMAS = LibMultiAccountSets
local LCK = LibCharacterKnowledge


LootLogMulti.name = "LootLogMulti"

LootLogMulti.CONTEXT_LOOTED_PERSONAL = true
LootLogMulti.CONTEXT_LOOTED_OTHERS = false
LootLogMulti.CONTEXT_HISTORY_FILTER = 1
LootLogMulti.CONTEXT_INCOMING_CHAT = 2
LootLogMulti.CONTEXT_MAIL_ATTACHMENT = 3
LootLogMulti.FALLBACK_COLOR = 0xFFFFFF

local FLAG_SUPPORTED_LMAS = 1
local FLAG_SUPPORTED_LCK = 2

local PRIORITY_OFF = 0
local PRIORITY_LOW = 1
local PRIORITY_MAX = 3

local IndicatorIcons = { default = "LootLog/art/uncollected.dds" }
for i = PRIORITY_LOW, PRIORITY_MAX do
	IndicatorIcons[i] = string.format("LootLog/art/uncollected-%d.dds", i)
end


--------------------------------------------------------------------------------
-- LootLogMulti.Initialize
--------------------------------------------------------------------------------

function LootLogMulti.Initialize( server )
	-- Determine how much of LootLogMulti will be supported
	LootLogMulti.support = 0
	if (LMAS) then
		local accounts = LMAS.GetAccountList(false)
		if (#accounts > 1) then
			LootLogMulti.support = BitOr(LootLogMulti.support, FLAG_SUPPORTED_LMAS)
		end
	end
	if (LCK) then
		LootLogMulti.support = BitOr(LootLogMulti.support, FLAG_SUPPORTED_LCK)
		LCK.RegisterForCallback(LootLogMulti.name, LCK.EVENT_INITIALIZED, function( )
			LootLogMulti.useLCK = true
		end)
	end

	-- If the old key name is present, rename it
	if (LootLog.vars.multiAccounts and not LootLog.vars.multi) then
		LootLog.vars.multi = LootLog.vars.multiAccounts
		LootLog.vars.multiAccounts = nil
	end

	-- Initialize color settings
	if (LootLogMulti.support > 0) then
		if (not LootLog.vars.multi) then
			LootLog.vars.multi = { }
		end

		if (not LootLog.vars.multi.colors) then
			LootLog.vars.multi.colors = {
				0xCCFFCC,
				0x00CC99,
				0x33CCFF,
			}
		end
		LootLogMulti.colors = LootLog.vars.multi.colors
	else
		LootLogMulti.colors = { }
	end

	-- Initialize account priority settings
	if (BitAnd(LootLogMulti.support, FLAG_SUPPORTED_LMAS) == FLAG_SUPPORTED_LMAS) then
		if (not LootLog.vars.multi[server]) then
			LootLog.vars.multi[server] = {
				enabled = false,
			}
		end
		LootLogMulti.vars = LootLog.vars.multi[server]
	else
		LootLogMulti.vars = { enabled = false }
	end
end


--------------------------------------------------------------------------------
-- LootLogMulti.GetCurrentAccountPriority
--------------------------------------------------------------------------------

function LootLogMulti.GetCurrentAccountPriority( )
	if (LootLogMulti.vars.enabled) then
		return LootLogMulti.vars[LootLog.self.userId] or PRIORITY_OFF
	else
		return PRIORITY_MAX
	end
end


--------------------------------------------------------------------------------
-- LootLogMulti.ShouldFlagAsUncollected
--------------------------------------------------------------------------------

local function GetItemPriority( itemLink, context, checkInventory, ignorePriorityFloor )
	local results = LMAS.GetItemCollectionAndTradabilityStatus(nil, itemLink, context)
	if (results == LMAS.ITEM_UNCOLLECTIBLE) then return false end

	-- Amend the current account's collection status with "unused" items, if requested
	if (checkInventory and results[LootLog.self.userId] ~= LMAS.ITEM_COLLECTED) then
		LootLog.ScanInventoryForUncollectedItems()
		if (LootLog.inventory.pieces[LootLog.GetItemLinkItemSetCollectionKey(itemLink)]) then
			results[LootLog.self.userId] = LMAS.ITEM_COLLECTED
		end
	end

	-- Find the highest matching priority
	local priority = PRIORITY_OFF
	for account, status in pairs(results) do
		local accountPriority = LootLogMulti.vars[account] or PRIORITY_OFF
		if (status == LMAS.ITEM_UNCOLLECTED_TRADE and accountPriority > priority) then
			priority = accountPriority
		end
	end

	-- Determine if the current account should "use" the item
	local selfPriority = LootLogMulti.vars[LootLog.self.userId] or PRIORITY_OFF
	local selfUse = priority == selfPriority and (ignorePriorityFloor or priority > PRIORITY_OFF) and results[LootLog.self.userId] ~= LMAS.ITEM_COLLECTED

	-- Use multi-account flagging only if the item is not intended for the current account
	return not selfUse, priority
end

local function ShouldFlagAsUncollectedSetItem( itemLink, context, checkInventory )
	if (type(context) == "table") then
		-- Item lists
		if (LootLogMulti.vars.enabled) then
			local useMulti, priority = GetItemPriority(itemLink, context, checkInventory, GetItemLinkBindType(itemLink) == BIND_TYPE_ON_PICKUP)
			if (useMulti) then
				return priority > PRIORITY_OFF, LootLogMulti.colors[priority], IndicatorIcons[priority]
			end
		end

		-- Default fallback
		return LootLog.IsItemLinkUncollected(itemLink, checkInventory), LootLog.vars.uncollectedColors.itemLists
	elseif (context == LootLogMulti.CONTEXT_INCOMING_CHAT) then
		-- Linked in chat
		if (not LootLog.IsItemLinkTradeable(itemLink)) then
			return false
		end

		-- Use multi-account mode only for BoE items for accounts of equal or higher priority
		if (LootLogMulti.vars.enabled and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_EQUIP) then
			local useMulti, priority = GetItemPriority(itemLink, nil, checkInventory)
			if (useMulti) then
				return priority > PRIORITY_OFF and priority >= LootLogMulti.GetCurrentAccountPriority(), LootLogMulti.colors[priority], IndicatorIcons[priority]
			end
		end

		-- Default fallback
		return LootLog.IsItemLinkUncollected(itemLink, checkInventory), LootLog.vars.uncollectedColors.linkedChat
	elseif (context == LootLogMulti.CONTEXT_HISTORY_FILTER) then
		-- Uncollected filter in the Loot History browser: Use multi-account mode only for BoE items for accounts of equal or higher priority
		if (LootLogMulti.vars.enabled and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_EQUIP) then
			local useMulti, priority = GetItemPriority(itemLink, nil, checkInventory)
			if (useMulti) then
				return priority > PRIORITY_OFF and priority >= LootLogMulti.GetCurrentAccountPriority()
			end
		end

		-- Default fallback
		return LootLog.IsItemLinkUncollected(itemLink, checkInventory)
	else
		-- All other contexts: Use multi-account mode only for BoE items
		if (LootLogMulti.vars.enabled and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_EQUIP) then
			local useMulti, priority = GetItemPriority(itemLink, nil, checkInventory)
			if (useMulti) then
				return priority > PRIORITY_OFF, LootLogMulti.colors[priority], IndicatorIcons[priority]
			end
		end

		-- Default fallback
		local color
		if (context == LootLogMulti.CONTEXT_LOOTED_PERSONAL) then
			color = LootLog.vars.uncollectedColors.lootedPersonal
		elseif (context == LootLogMulti.CONTEXT_LOOTED_OTHERS) then
			color = LootLog.vars.uncollectedColors.lootedGroup
		elseif (context == LootLogMulti.CONTEXT_MAIL_ATTACHMENT) then
			color = LootLog.vars.uncollectedColors.itemLists
		end
		return LootLog.IsItemLinkUncollected(itemLink, checkInventory), color
	end
end

local function ShouldFlagAsUncollectedRecipeOrMotif( itemLink, context, _, personal )
	local characters = LCK.GetItemKnowledgeList(itemLink)

	local rank
	local selfRank = #characters + 1
	local bindType = GetItemLinkBindType(itemLink)

	if (type(context) == "table" or context == LootLogMulti.CONTEXT_LOOTED_PERSONAL or context == LootLogMulti.CONTEXT_MAIL_ATTACHMENT) then
		personal = true
	elseif (context == LootLogMulti.CONTEXT_LOOTED_OTHERS or context == LootLogMulti.CONTEXT_INCOMING_CHAT) then
		personal = false
	end

	for i, character in ipairs(characters) do
		if (character.id == LootLog.self.charId) then
			selfRank = i
		end

		-- Find the first character that does not know the item and is eligible for trade
		if (not rank and character.knowledge == LCK.KNOWLEDGE_UNKNOWN) then
			if (bindType == BIND_TYPE_ON_PICKUP) then
				if (personal and character.account == LootLog.self.userId) then
					rank = i
				end
			elseif (bindType == BIND_TYPE_ON_PICKUP_BACKPACK) then
				if (personal and selfRank == i) then
					rank = i
				end
			else
				rank = i
			end
		end
	end

	if (not rank) then
		return false
	elseif (rank == selfRank) then
		if (context == LootLogMulti.CONTEXT_LOOTED_PERSONAL) then
			return true, LootLog.vars.uncollectedColors.lootedPersonal
		elseif (context == LootLogMulti.CONTEXT_LOOTED_OTHERS) then
			return true, LootLog.vars.uncollectedColors.lootedGroup
		elseif (context == LootLogMulti.CONTEXT_INCOMING_CHAT) then
			return true, LootLog.vars.uncollectedColors.linkedChat
		else
			return true, LootLog.vars.uncollectedColors.itemLists
		end
	else
		local priority
		if (rank == 1) then
			priority = PRIORITY_MAX
		elseif (rank < selfRank) then
			priority = 2
		else
			priority = PRIORITY_LOW
		end
		return true, LootLogMulti.colors[priority], IndicatorIcons[priority]
	end
end

function LootLogMulti.ShouldFlagAsUncollected( ... )
	local results
	local itemLink = ...
	if (LootLogMulti.useLCK and LCK.GetItemCategory(itemLink) ~= LCK.ITEM_CATEGORY_NONE) then
		results = { ShouldFlagAsUncollectedRecipeOrMotif(...) }
	else
		results = { ShouldFlagAsUncollectedSetItem(...) }
	end

	-- Set default color and icon as needed
	if (type(results[2]) ~= "number") then results[2] = LootLogMulti.FALLBACK_COLOR end
	if (type(results[3]) ~= "string") then results[3] = IndicatorIcons.default end
	return unpack(results)
end


--------------------------------------------------------------------------------
-- LootLogMulti.CountUncollectedAccounts
--------------------------------------------------------------------------------

function LootLogMulti.CountUncollectedAccounts( itemLink, context, priorityFloor )
	local count = 0

	if (LootLogMulti.vars.enabled) then
		local results = LMAS.GetItemCollectionAndTradabilityStatus(nil, itemLink, context)
		if (results ~= LMAS.ITEM_UNCOLLECTIBLE) then
			if (not priorityFloor) then priorityFloor = PRIORITY_OFF end

			for account, status in pairs(results) do
				local accountPriority = LootLogMulti.vars[account] or PRIORITY_OFF
				if (status == LMAS.ITEM_UNCOLLECTED_TRADE and accountPriority > priorityFloor) then
					count = count + 1
				end
			end
		end
	end

	return count
end


--------------------------------------------------------------------------------
-- LootLogMulti.BuildSettings
--------------------------------------------------------------------------------

function LootLogMulti.BuildSettings( Colors )
	local controls = { }

	local priorityCaptions = {
		[PRIORITY_OFF] = SI_CHECK_BUTTON_OFF,
		[PRIORITY_LOW] = SI_SUBSAMPLINGMODE0, -- formerly SI_LOW, before it was changed
		[PRIORITY_MAX] = SI_SUBSAMPLINGMODE2, -- formerly SI_HIGH, before it was changed
	}

	--------
	-- Colors section
	--------

	if (LootLogMulti.support > 0) then
		for i = PRIORITY_LOW, PRIORITY_MAX do
			local key = string.format("multi%d", i)
			local title = string.format(GetString(SI_LOOTLOG_MULTI_PRIORITY), i)
			if (priorityCaptions[i]) then
				title = string.format("%s (%s)", title, GetString(priorityCaptions[i]))
			end
			table.insert(controls, {
				type = "colorpicker",
				name = title,
				getFunc = function() return LCCC.Int24ToRGB(LootLogMulti.colors[i] or LootLogMulti.FALLBACK_COLOR) end,
				setFunc = function(...)
					LootLogMulti.colors[i] = LCCC.RGBToInt24(...)
					Colors.UpdatePreview(key)
					LootLog.RefreshUI()
				end,
				reference = Colors.GetGlobalName(key),
			})
			Colors.data[key] = {
				setting = LootLogMulti.colors,
				priority = i,
				icon = IndicatorIcons[i],
			}
		end
	end

	--------
	-- Account priorities section
	--------

	if (BitAnd(LootLogMulti.support, FLAG_SUPPORTED_LMAS) == FLAG_SUPPORTED_LMAS) then
		LootLog.linkHandlers["lllmas"] = LMAS.OpenSettingsPanel

		local append = function( t1, t2 )
			for _, v in ipairs(t2) do
				table.insert(t1, v)
			end
		end

		local accounts = LMAS.GetAccountList(false)
		local priorities = { }
		local priorityLabels = { }

		for i = PRIORITY_OFF, PRIORITY_MAX do
			table.insert(priorities, i)
			if (i == PRIORITY_OFF) then
				table.insert(priorityLabels, GetString(priorityCaptions[i]))
			elseif (priorityCaptions[i]) then
				table.insert(priorityLabels, string.format("%d (%s)", i, GetString(priorityCaptions[i])))
			else
				table.insert(priorityLabels, tostring(i))
			end
		end

		local accountsSection = { }
		for _, account in ipairs(accounts) do
			table.insert(accountsSection, {
				type = "dropdown",
				name = account,
				choices = priorityLabels,
				choicesValues = priorities,
				getFunc = function() return LootLogMulti.vars[account] or PRIORITY_OFF end,
				setFunc = function(priority)
					LootLogMulti.vars[account] = (priority ~= PRIORITY_OFF) and priority or nil
					LootLog.RefreshUI()
				end,
			})
		end

		append(controls, {
			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LOOTLOG_SECTION_MULTI,
			},
			--------------------
			{
				type = "description",
				text = SI_LOOTLOG_MULTI_DESCRIPTION,
				enableLinks = function( _, linkData )
					LootLog.OnLinkClick(nil, nil, nil, nil, string.gsub(linkData, ".*:", ""))
				end,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_ADDON_MANAGER_ENABLED,
				getFunc = function() return LootLogMulti.vars.enabled end,
				setFunc = function(enabled)
					LootLogMulti.vars.enabled = enabled
					LootLog.RefreshUI()
				end,
			},
			--------------------
			{
				type = "submenu",
				name = SI_LOOTLOG_MULTI_ACCOUNTS,
				controls = accountsSection,
				disabled = function() return not LootLogMulti.vars.enabled end,
			},
		})
	end

	return controls
end
