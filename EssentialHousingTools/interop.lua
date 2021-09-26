if not EHT then EHT = { } end
if not EHT.Interop then EHT.Interop = { } end


local function StripCharacter( s, c, r )
	if s then
		return string.gsub( s, c, r or "" )
	end
end


---[ Interoperability : 3rd Party ]---


function EHT.Interop.GetAPIVersion()

	return 1

end


EHT.Interop.RESULT = {
	EXCEPTION = -1,
	SUCCESS = 0,
	NOT_FOUND = 1,
}


--[[
Queues the action(s) that would normally occur when
the specified trigger met its defined conditions.

ARGS:
 triggerName (string)

RETURNS:
 result (EHT.Interop.RESULT)
]]

function EHT.Interop.QueueTriggerActions( triggerName )

	assert( "string" == type( triggerName ), "Argument 'triggerName' must be of type 'string'." )

	local trigger = EHT.Data.GetTriggerByName( triggerName )
	if not trigger then
		return EHT.Interop.RESULT.NOT_FOUND
	end

	EHT.Biz.QueueSingleTriggerActions( trigger )
	return EHT.Interop.RESULT.SUCCESS

end


--[[
Queries whether any of the specified trigger's action(s)
are already queued.

ARGS:
 triggerName (string)

RETURNS:
 isQueued (boolean, nilable),
 result (EHT.Interop.RESULT)
]]

function EHT.Interop.IsTriggerQueued( triggerName )

	assert( "string" == type( triggerName ), "Argument 'triggerName' must be of type 'string'." )

	local trigger = EHT.Data.GetTriggerByName( triggerName )
	if not trigger then
		return nil, EHT.Interop.RESULT.NOT_FOUND
	end

	local isQueued = EHT.Biz.IsTriggerQueued( trigger )
	return isQueued, EHT.Interop.RESULT.SUCCESS

end

---[ Interoperability : Essential Housing Community ]---
--[[
function EHT.Interop.GetCurrentSignerName()
	return string.format( "%s (%s)", GetUnitName( "player" ), GetDisplayName() )
end

function EHT.Interop.IsCommunityDefined()
	return EHT.Community and EHT.Community.GetRecord and EHT.Community.SetRecord
end

function EHT.Interop.CheckCommunityConnection( suppressDialog )
	if not ( EHT.Interop.IsCommunityDefined() and "number" == type( EHT.Community.LocalTimeStamp ) and math.abs( GetTimeStamp() - EHT.Community.LocalTimeStamp ) <= EHT.CONST.MAX_COMMUNITY_LOCAL_SERVER_TIMESTAMP_DELTA ) then
		if not suppressDialog then
			local MESSAGE = "" ..
				"|cff0000EXISTING COMMUNITY USERS: Please re-run the Community App once in order to restart your Community sync process. " ..
				"We apologize for this inconvenience.\n\n" ..
				"|cffffffTo use this feature, the following must be installed and enabled:\n\n" ..
				"|cffff00Essential Housing Community Add-On|cffffff\n" ..
				"|cffff00Essential Housing Community Application|cffffff\n\n" ..
				"|cffffffIf you have already enabled the Add-On and installed the Application, " ..
				"please type |c00ffff/reloadui|cffffff to complete the setup.\n\n" ..
				"Watch the |cffff00installation guide video|cffffff (<1 min) ?"

			EHT.UI.ShowConfirmationDialog( "", MESSAGE, function() EHT.UI.ShowURL( EHT.CONST.URLS.SetupCommunityPC ) end )
		end

		return false
	end

	return true
end

function EHT.Interop.GetCommunityRecord( key )
	if not EHT.Interop.IsCommunityDefined() then
		return nil
	end

	if "string" ~= type( key ) then
		return nil
	end

	return EHT.Community.GetRecord( key )
end

function EHT.Interop.SetCommunityFXRecord( houseId, effects )
	local player = string.lower( GetDisplayName() )

	if not EHT.Interop.CheckCommunityConnection() then
		return false
	end

	if "number" ~= type( houseId ) or 0 >= houseId then
		return false
	end

	if effects then
		effects = EHT.Util.CloneTable( effects )

		local data = { }
		data.TS = GetTimeStamp()
		data.World = EHT.Util.GetWorldCode()
		data.HouseId = houseId
		data.Effects = effects
		data.Version = EHT.ADDON_VERSION

		local rec = EHT.Interop.GetCommunityFXRecord( player )
		if "table" == type( rec ) then
			-- Add the new Houses table if it does not yet exist.
			if "table" ~= type( rec.Houses ) then
				rec.Houses = { }

				-- Migrate a legacy record's House data into the new Houses table.
				if rec.TS and rec.World and rec.HouseId and rec.Effects and rec.Version then
					table.insert( rec.Houses, {
						TS = rec.TS,
						World = rec.World,
						HouseId = rec.HouseId,
						Effects = rec.Effects,
						Version = rec.Version,
					} )

					rec.TS, rec.World, rec.HouseId, rec.Effects, rec.Version = nil, nil, nil, nil, nil
				end
			end

			-- Overwrite this house's record if one already exists.
			local added = false
			for index, house in pairs( rec.Houses ) do
				if string.lower( data.World ) == string.lower( house.World ) and data.HouseId == house.HouseId then
					added = true
					house.Effects = data.Effects
					house.TS = data.TS
					house.Version = data.Version
					break
				end
			end

			-- Insert this house's record if none exists.
			if not added then
				table.insert( rec.Houses, data )
			end

			data = rec
		end

		local key = string.format( "fx__%s", player )
		return EHT.Community.SetRecord( key, data )
	else
		local world = string.lower( EHT.Util.GetWorldCode() )
		local rec = EHT.Interop.GetCommunityFXRecord( player )

		if "table" == type( rec ) then
			if houseId == rec.HouseId and world == string.lower( rec.World ) then
				rec.HouseId = nil
				rec.World = nil
				rec.TS = nil
				rec.Effects = nil
				rec.Version = nil
			end

			if "table" == type( rec.Houses ) then
				for index, house in pairs( rec.Houses ) do
					if world == string.lower( house.World ) and houseId == house.HouseId then
						table.remove( rec.Houses, index )
						break
					end
				end
			end

			local key = string.format( "fx__%s", player )
			return EHT.Community.SetRecord( key, rec )
		end

		return true
	end
end

function EHT.Interop.GetCommunityFXRecord( player )
	if not EHT.Interop.IsCommunityDefined() then
		return nil
	end

	if "string" ~= type( player ) then
		return nil
	end

	local key = string.format( "fx__%s", string.lower( player ) )
	return EHT.Community.GetRecord( key )
end

function EHT.Interop.CheckForNewerVersion( version )
	if EHT.NewerVersionAlert == nil then
		if EHT.ADDON_COMPOUND_VERSION then
			local compoundVersion = EHT.Util.ParseVersionString( version )
			if compoundVersion and compoundVersion > EHT.ADDON_COMPOUND_VERSION then
				EHT.NewerVersionAlert = GetTimeStamp()
				EVENT_MANAGER:RegisterForUpdate( "EHT.NewerVersionAlert", 5000, function()
					EVENT_MANAGER:UnregisterForUpdate( "EHT.NewerVersionAlert" )
					d( "|cffff44A newer version of Essential Housing Tools may be available." )
				end )
			end
		end
	end
end

function EHT.Interop.GetCommunityHouseFXRecord( player, world, houseId )
	local houseRecord
	local rec = EHT.Interop.GetCommunityFXRecord( player )

	if rec then
		world = string.lower( world )

		if rec.HouseId == houseId and string.lower( rec.World ) == world then
			houseRecord =
			{
				TS = rec.TS,
				World = rec.World,
				HouseId = rec.HouseId,
				Effects = rec.Effects,
				Version = rec.Version,
			}
		elseif "table" == type( rec.Houses ) then
			for index, house in pairs( rec.Houses ) do
				if house.HouseId == houseId and string.lower( house.World ) == world then
					houseRecord = house
					break
				end
			end
		end

		if houseRecord and houseRecord.Version then
			EHT.Interop.CheckForNewerVersion( houseRecord.Version )
		end
	end

	return houseRecord
end

function EHT.Interop.SetCommunityOpenHouseRecord( worldHouses, worldDates, suppressDialog, suppressPostReloadFlag )
	if not EHT.Interop.CheckCommunityConnection( true == suppressDialog ) then
		return nil
	end

	if "table" ~= type( worldHouses ) then
		return false
	end

	if "table" ~= type( worldDates ) then
		worldDates = { }
	end

	local ts = GetTimeStamp()
	local now = EHT.Util.GetDate( ts )

	for world, houses in pairs( worldHouses ) do
		if "table" ~= type( houses ) or not EHT.Util.IsValidWorldCode( world ) then
			return false
		end

		local dates = worldDates[ world ]
		if "table" ~= type( dates ) then
			dates = { }
			worldDates[ world ] = dates
		end

		for houseId in pairs( houses ) do
			if nil == tonumber( dates[ houseId ] ) then
				dates[ houseId ] = now
			end
		end
	end

	local data = { }
	data.TS = ts
	data.Version = EHT.ADDON_VERSION
	data.Houses = worldHouses
	data.Dates = worldDates

	local key = string.format( "oh__%s", string.lower( GetDisplayName() ) )
	return EHT.Community.SetRecord( key, data, suppressPostReloadFlag )
end

function EHT.Interop.GetCommunityOpenHouseRecord( player )
	if not EHT.Interop.IsCommunityDefined() then
		return nil
	end

	if "string" ~= type( player ) then
		return nil
	end

	local key = string.format( "oh__%s", string.lower( player ) )
	return EHT.Community.GetRecord( key )
end

function EHT.Interop.SetCommunitySignGuestbookRecord( signatures )
	if not signatures then
		return false
	end

	if not EHT.Interop.CheckCommunityConnection() then
		return nil
	end

	local key = string.format( "sg__%s", string.lower( GetDisplayName() ) )
	return EHT.Community.SetRecord( key, signatures )
end

function EHT.Interop.GetCommunitySignGuestbookRecord()
	if not EHT.Interop.CheckCommunityConnection() then
		return nil
	end

	local key = string.format( "sg__%s", string.lower( GetDisplayName() ) )
	local record = EHT.Community.GetRawLocalRecord( key )

	return record or ""
end

function EHT.Interop.GetCommunityGuestbookRecord( owner, houseId, world )
	if not EHT.Interop.IsCommunityDefined() then
		return nil
	end

	if not houseId then
		owner, houseId = EHT.Housing.GetHouseOwner()
	end

	if "" == owner or 0 == houseId then
		return nil
	end

	if not world then
		world = EHT.Util.GetWorldCode()
	end

	local key = string.lower( string.format( "gb__%s__%s__%s", tostring( world ), tostring( owner ), tostring( houseId ) ) )
	local record = EHT.Community.GetRecord( key )

	if "string" == type( record ) and 0 < #record then
		local signatures = { SplitString( ";", record ) }
		local signature

		for index = #signatures, 1, -1 do
			signature = { SplitString( ",", signatures[index] ) }

			if not signature or 2 > #signature then
				table.remove( signatures, index )
			else
				signature[2] = tonumber( signature[2] )

				if not signature[2] then
					table.remove( signatures, index )
				else
					signatures[index] = signature
				end
			end
		end

		return signatures
	end

	return { }
end

function EHT.Interop.GetOpenHouses( player )
	local rec = EHT.Interop.GetCommunityOpenHouseRecord( player or GetDisplayName() )
	local list = { }

	if rec and rec.Houses then
		local world = EHT.Util.GetWorldCode()
		local dates = rec.Dates and rec.Dates[ world ]
		local earliestDate = EHT.Util.GetDate() - EHT.CONST.DEFAULT_OPEN_HOUSE_PERIOD_DAYS

		for w, houses in pairs( rec.Houses ) do
			if w == world then
				for houseId, houseName in pairs( houses ) do
					houseId = tonumber( houseId )
					local openHouse = { houseId = houseId, houseName = houseName, publishedDate = 0, daysRemaining = 0, expired = false }

					if not dates or not dates[ houseId ] then
						if rec.TS then
							openHouse.publishedDate = EHT.Util.GetDate( rec.TS )
							if openHouse.publishedDate <= earliestDate then
								openHouse.expired = true
							end
						end
					else
						openHouse.publishedDate = dates[ houseId ]
						if openHouse.publishedDate <= 0 or openHouse.publishedDate <= earliestDate then
							openHouse.expired = true
						end
					end

					if openHouse.publishedDate and openHouse.publishedDate > 0 then
						openHouse.daysRemaining = openHouse.publishedDate - earliestDate
					end

					list[ houseId ] = openHouse
				end

				break
			end
		end
	end

	return list
end

function EHT.Interop.GetOpenHouse( houseId, player )
	local openHouses = EHT.Interop.GetOpenHouses( player )
	return openHouses[ houseId ]
end


function EHT.Interop.GetOpenHouseName( houseId, player )

	local openHouse = EHT.Interop.GetOpenHouse( houseId, player )
	return openHouse and not openHouse.expired and openHouse.houseName

end


function EHT.Interop.IsOpenHouse( houseId, player )

	local openHouse = EHT.Interop.GetOpenHouse( houseId, player )
	local active, expired = openHouse and not openHouse.expired, openHouse and openHouse.expired
	return active, expired

end


function EHT.Interop.ToggleOpenHouse( houseId, isEnabled, suppressDialog )

	if not houseId or 0 >= houseId then
		return nil
	end

	if not EHT.Interop.CheckCommunityConnection( true == suppressDialog ) then
		return nil
	end

	local rec = EHT.Interop.GetCommunityOpenHouseRecord( GetDisplayName() )
	local world = EHT.Util.GetWorldCode()
	local houses, dates

	if not rec or not rec.Houses then
		houses = { }
	else
		houses = rec.Houses
	end
	if not houses[world] then
		houses[world] = { }
	end

	if not rec or not rec.Dates then
		dates = { }
	else
		dates = rec.Dates
	end
	if not dates[world] then
		dates[world] = { }
	end

	if nil == isEnabled then
		local isActive, isExpired = EHT.Interop.IsOpenHouse( houseId, GetDisplayName() )
		isEnabled = not isActive or isExpired
	end

	local open
	if isEnabled then
		houses[world][houseId] = GetCollectibleNickname( GetCollectibleIdForHouse( houseId ) )
		dates[world][houseId] = EHT.Util.GetDate()
		open = true
	else
		houses[world][houseId] = nil
		dates[world][houseId] = nil
		open = false
	end

	if nil == EHT.Interop.SetCommunityOpenHouseRecord( houses, dates ) then
		return nil
	end

	return open

end


function EHT.Interop.UpdateOpenHouseNickname( collectibleId )

	if GetCollectibleCategoryType( collectibleId ) ~= COLLECTIBLE_CATEGORY_TYPE_HOUSE then
		return
	end

	local houseId = EHT.Housing.GetHouseIdByCollectibleId( collectibleId )
	if not houseId then
		return
	end

	local newName = GetCollectibleNickname( collectibleId )
	local currentName = EHT.Interop.GetOpenHouseName( houseId )

	if currentName and "" ~= currentName and newName and "" ~= newName and currentName ~= newName then
		EHT.Interop.ToggleOpenHouse( houseId, true, true )
		EHT.UI.DisplayNotification( string.format( "Updating Open House name to \"%s\"...", newName ) )
	end

end


function EHT.Interop.AppendSignatureToCommunityGuestbookRecord( world, owner, houseId )

	local key = string.lower( string.format( "gb__%s__%s__%s", tostring( world ), tostring( owner ), tostring( houseId ) ) )
	local record = EHT.Community.GetRawRemoteRecord( key )
	local signature = string.format( "%s,%s;", EHT.Interop.GetCurrentSignerName(), tostring( GetTimeStamp() ) )

	if not record or "string" == type( record ) then
		EHT.Community.SetRawRemoteRecord( key, signature .. ( record or "" ) )
	end

end


function EHT.Interop.SignGuestbook()

	local owner, houseId = EHT.Housing.GetHouseOwner()
	if "" == owner or 0 == houseId then
		return false
	end

	owner = string.lower( owner )
	local signatures = EHT.Interop.GetCommunitySignGuestbookRecord()
	if not signatures then
		return false
	end

	local ts = GetTimeStamp()
	local world = EHT.Util.GetWorldCode()
	local signature = string.format( "%s,%s,%s,%s,%s;", tostring( ts ), world, tostring( owner ), tostring( houseId ), EHT.Interop.GetCurrentSignerName() )
	signatures = signature .. signatures

	if 2048 < #signatures then
		local delimiter = 0
		while delimiter and delimiter < 2048 do
			delimiter = string.find( signatures, ";", delimiter + 1 )
		end
		if delimiter then
			signatures = string.sub( signatures, 1, delimiter )
		end
	end

	local result = EHT.Interop.SetCommunitySignGuestbookRecord( signatures )
	if result then
		EHT.Interop.AppendSignatureToCommunityGuestbookRecord( world, owner, houseId )
	end

	return result

end


function EHT.Interop.GetGuestbook( owner, houseId, world )
	local signatures = EHT.Interop.GetCommunityGuestbookRecord( owner, houseId, world )

	if "table" == type( signatures ) then
		table.sort( signatures, function( a, b ) return ( "table" == type( a ) and "table" == type( b ) ) and a[2] < b[2] or false end )
	end

	return signatures
end


function EHT.Interop.HasSignedGuestbook()

	local signatures = EHT.Interop.GetGuestbook()

	if "table" == type( signatures ) then
		local mySig = string.lower( string.format( "(%s)", GetDisplayName() ) )

		for _, signature in pairs( signatures ) do
			if string.find( string.lower( signature[1] ), mySig ) then
				return true
			end
		end
	end

	return false

end


function EHT.Interop.SetCommunityResetGuestbookRecord()

	if 0 == EHT.Housing.GetHouseId() or not EHT.Housing.IsOwner() then
		return false
	end

	if not EHT.Interop.CheckCommunityConnection() then
		return nil
	end

	local world = string.lower( EHT.Util.GetWorldCode() )
	local owner = string.lower( GetDisplayName() )
	local houseId = tostring( EHT.Housing.GetHouseId() )
	local key = string.format( "gr__%s__%s__%s", world, owner, houseId )
	local result, message = EHT.Community.SetRecord( key, { TS = GetTimeStamp() } )

	if result then
		local key = string.lower( string.format( "gb__%s__%s__%s", tostring( world ), tostring( owner ), tostring( houseId ) ) )
		EHT.Community.SetRawRemoteRecord( key, "" )
	end

	return result, message

end


function EHT.Interop.ResetGuestbook()

	if not EHT.Housing.IsOwner() then
		return false
	end

	local houseId = EHT.Housing.GetHouseId()

	if 0 == houseId then
		return false
	end

	local signatures = EHT.Interop.GetGuestbook()

	if "table" ~= type( signatures ) or 0 >= #signatures then
		return false
	end

	return EHT.Interop.SetCommunityResetGuestbookRecord()

end


function EHT.Interop.GetContestants( suppressDialog )

	if not EHT.Interop.CheckCommunityConnection( suppressDialog ) then
		return nil
	end

	local key = string.format( "cn__%s", string.lower( EHT.Util.GetWorldCode() ) )
	local rec = EHT.Community.GetRecord( key )
	local list = { }

	if "table" == type( rec ) then
		for index, entry in pairs( rec ) do
			if "table" == type( entry ) and entry.HouseId and entry.Player then
				table.insert( list, { Player = string.lower( entry.Player ), HouseId = tonumber( entry.HouseId ), HouseName = tostring( entry.HouseName or "" ) } )
			end
		end
	end

	return list

end


function EHT.Interop.GetContestant( player )

	local list = EHT.Interop.GetContestants( true )
	if not list then return nil, nil end

	player = string.lower( player )

	for index, entry in ipairs( list ) do
		if player == entry.Player then
			return entry, index
		end
	end

	return nil, nil

end


function EHT.Interop.SetContestant( houseId )

	houseId = tonumber( houseId )

	if not EHT.Interop.CheckCommunityConnection() then
		return false
	end

	local ts = GetTimeStamp()
	local player = string.lower( GetDisplayName() )
	local world = string.lower( EHT.Util.GetWorldCode() )
	local houseName = houseId and GetCollectibleNickname( GetCollectibleIdForHouse( houseId ) ) or nil
	local key = string.format( "cr__%s__%s", player, world or "" )
	local rec = string.format( "%s;%s;%s", tostring( ts or 0 ), tostring( houseId or 0 ), StripCharacter( houseName or "" ) )

	return EHT.Community.SetRecord( key, rec )

end


function EHT.Interop.SetContestantVote( player, houseId )

	player = tostring( player or "" )
	houseId = tonumber( houseId )

	if not houseId or "" == player then
		return false
	end

	if not EHT.Interop.CheckCommunityConnection() then
		return false
	end

	local ts = GetTimeStamp()
	local world = string.lower( EHT.Util.GetWorldCode() )
	local key = string.format( "cv__%s__%s", string.lower( GetDisplayName() ), world or "" )
	local rec = string.format( "%s;%s;%s", tostring( ts or 0 ), StripCharacter( player ), tostring( houseId or 0 ) )

	return EHT.Community.SetRecord( key, rec )

end


function EHT.Interop.GetLeaderboard( suppressDialog )

	if not EHT.Interop.CheckCommunityConnection( suppressDialog ) then
		return nil
	end

	local key = string.format( "cl__%s", string.lower( EHT.Util.GetWorldCode() ) )
	local rec = EHT.Community.GetRecord( key )
	local list = { }

	if "table" == type( rec ) then
		for index, entry in ipairs( rec ) do
			if "table" == type( entry ) and entry.HouseId and entry.Player then
				table.insert( list, { Player = string.lower( entry.Player ), HouseId = tonumber( entry.HouseId ), HouseName = tostring( entry.HouseName or "" ), Votes = tonumber( entry.Votes ) } )
			end
		end
	end

	return list

end


function EHT.Interop.EstimateCommunityFXRecordSize()

	if not EHT.Interop.IsCommunityDefined() or not EHT.Community or not EHT.Community.EstimateRecordSize then
		return 0
	end

	return tonumber( EHT.Community.EstimateRecordSize( string.format( "fx__%s", string.lower( GetDisplayName() ) ) ) ) or 0

end


do

	local MetaData
	local MetaDataParsers = { }


	-- Open House Meta Data Parser

	MetaDataParsers["oh"] = function( key, rec )

		if not key or "oh__" ~= string.sub( key, 1, 4 ) then
			return false
		end

		local data = EHT.Interop.GetCommunityRecord( key )

		if data then
			local player = string.sub( key, 5 )

			if "table" == type( data.Houses ) then
				local recordTimestamp = EHT.Util.GetDate( tonumber( data.TS ) )

				for w, houses in pairs( data.Houses ) do
					if EHT.Util.IsValidWorldCode( w ) and "table" == type( houses ) then
						local worldList = MetaData["oh__" .. w]
						if not worldList then
							worldList = { Type = "oh", World = w, Houses = { } }
							MetaData["oh__" .. w] = worldList
						end

						if not worldList.Houses then
							worldList.Houses = { }
						end

						worldList = worldList.Houses
						for houseId, houseName in pairs( houses ) do
							local signatures = EHT.Interop.GetCommunityGuestbookRecord( player, houseId, w )
							local numSignatures = "table" == type( signatures ) and #signatures or 0
							table.insert( worldList, { player, houseId, houseName, recordTimestamp, numSignatures } )
						end
					end
				end
			end
			
			if "table" == type( data.Dates ) then
				for w, dates in pairs( data.Dates ) do
					if EHT.Util.IsValidWorldCode( w ) and "table" == type( dates ) then
						local worldList = MetaData["oh__" .. w]
						if not worldList then
							worldList = { Type = "oh", World = w, Houses = { } }
							MetaData["oh__" .. w] = worldList
						end

						if worldList.Houses then
							for houseId, publishDate in pairs( dates ) do
								publishDate = tonumber( publishDate )
								if publishDate then
									for _, record in ipairs( worldList.Houses ) do
										if record[2] == houseId then
											record[4] = publishDate
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end

		return true

	end


	function EHT.Interop.GetAllCommunityMetaData()

		if not MetaData then
			MetaData = { }

			if not EHT.Community or not EHT.Community.GetRecords then
				return MetaData
			end

			local records = EHT.Community.GetRecords()

			if "table" ~= type( records ) then
				return MetaData
			end

			local parser, parserKey

			for key, rec in pairs( records ) do
				parserKey = key and string.sub( key, 1, 2 )
				parser = MetaDataParsers[parserKey]

				if parser then
					local r = rec
					parser( key, r )
				end
			end
		end

		return MetaData

	end

end


function EHT.Interop.GetCommunityMetaData( filters )

	local records = EHT.Interop.GetAllCommunityMetaData()
	local list = { }

	local t, w = filters and filters.Type, filters and filters.World
	local tsMin, tsMax = filters and filters.MinTS, filters and filters.MaxTS

	for key, rec in pairs( records ) do
		if	( not t or t == rec.Type ) and
			( not w or w == rec.World ) and
			( not tsMin or ( rec.Timestamp and tsMin <= rec.Timestamp ) ) and
			( not tsMax or ( rec.Timestamp and tsMax >= rec.Timestamp ) ) then
			list[key] = rec
		end
	end

	return list

end


function EHT.Interop.GetCommunityMetaDataByKey( key )

	local records = EHT.Interop.GetAllCommunityMetaData()
	return records[key]

end
]]

---[ Interoperability : Essential Housing Tools Saver ]---


function EHT.Interop.GetEHTSaverAPI()

	if EHTSaver and EHTSaver.Archive and EHTSaver.Archive.GetMostRecentArchive and EHTSaver.Archive.RestoreMostRecentArchive and EHTSaver.Archive.HasEHTSavedVarsReset then
		return 1
	else
		return 0
	end

end


function EHT.Interop.GetEHTSaverMostRecentArchive()

	if 1 > EHT.Interop.GetEHTSaverAPI() then return end

	local archive = EHTSaver.Archive.GetMostRecentArchive()
	return archive

end


function EHT.Interop.EHTSaverRestoreMostRecentArchive()

	if 1 > EHT.Interop.GetEHTSaverAPI() then return end

	return EHTSaver.Archive.RestoreMostRecentArchive()

end


function EHT.Interop.HasEHTSavedVarsReset()

	if 1 > EHT.Interop.GetEHTSaverAPI() then return false end

	return EHTSaver.Archive.HasEHTSavedVarsReset()

end


---[ Interoperability : DecoTrack ]---

function EHT.Interop.GetDecoTrackAPI()
	if DecoTrack and DecoTrack.Interop and DecoTrack.Interop.GetAPI then
		return DecoTrack.Interop.GetAPI() or 0
	else
		return 0
	end
end

function EHT.Interop.GetDecoTrackCountsByItemId( itemId )
	if 1 > EHT.Interop.GetDecoTrackAPI() then return nil end
	if not DecoTrack.Interop.GetCountsByItemId then return nil end
	return DecoTrack.Interop.GetCountsByItemId( itemId )
end

function EHT.Interop.SearchDecoTrack( searchText )
	if 2 > EHT.Interop.GetDecoTrackAPI() then return nil end
	if not DecoTrack.Interop.Search then return nil end
	return DecoTrack.Interop.Search( searchText )
end

function EHT.Interop.GetDecoTrackCountsByHouse()
	if 2 > EHT.Interop.GetDecoTrackAPI() then return nil end
	if not DecoTrack or not DecoTrack.Data or "table" ~= type( DecoTrack.Data.Houses ) then return nil end

	local template = { }
	local containers = DecoTrack.Data.Houses
	local counts = { }

	for limitType = HOUSING_FURNISHING_LIMIT_TYPE_MIN_VALUE, HOUSING_FURNISHING_LIMIT_TYPE_MAX_VALUE do
		template[limitType] = 0
	end

	local house, limitType

	for _, container in pairs( DecoTrack.Data.Houses ) do
		if container.HouseId then
			house = EHT.Util.CloneTable( template )
			counts[container.HouseId] = house

			for itemId, count in pairs( container.Items ) do
				limitType = EHT.Housing.GetFurnitureLimitTypeByItemId( itemId )

				if limitType then
					house[limitType] = house[limitType] + count
				end
			end
		end
	end

	return counts
end

function EHT.Interop.DoesDecoTrackSupportEnhancedSearch()
	return 3 <= EHT.Interop.GetDecoTrackAPI()
end

function EHT.Interop.DoesDecoTrackSupportBoundItems()
	return 4 <= EHT.Interop.GetDecoTrackAPI()
end

function EHT.Interop.HasDecoTrackVisitedAllOwnedHomes()
	if 0 < EHT.Interop.GetDecoTrackAPI() and DecoTrack.Interop.HasVisitedAllOwnedHomes then
		return DecoTrack.Interop.HasVisitedAllOwnedHomes()
	end
	return true
end

function EHT.Interop.DecoTrackVisitAllHomes()
	if 0 < EHT.Interop.GetDecoTrackAPI() and DecoTrack.UpdateAllHouses then
		DecoTrack.UpdateAllHouses()
		return true
	end
	return false
end

---[ Interoperability : Furniture Snap ]---


EHT.Interop.FurnSnapCallbackId = 0
EHT.Interop.FurnSnapSuspended = false


function EHT.Interop.SuspendFurnitureSnap()

	if FurnSnap then
		EHT.Interop.FurnSnapSuspended = true

		if FurnSnap.SuspendSnapping then
			FurnSnap.SuspendSnapping()
		else
			EHT.FurnSnapEnabled = FurnSnap.Enabled
			FurnSnap.Enabled = false
		end
	end

end


function EHT.Interop.ResumeFurnitureSnap()

	if FurnSnap then
		EHT.Interop.FurnSnapSuspended = false

		if FurnSnap.ResumeSnapping then
			EHT.Interop.FurnSnapCallbackId = zo_callLater( function( id )
				if id ~= EHT.Interop.FurnSnapCallbackId or EHT.Interop.FurnSnapSuspended then
					return
				end
				FurnSnap.ResumeSnapping()
			end, 500 )
		else
			EHT.Interop.FurnSnapCallbackId = zo_callLater( function( id )
				if id ~= EHT.Interop.FurnSnapCallbackId or EHT.Interop.FurnSnapSuspended then
					return
				end
				FurnSnap.Enabled = EHT.FurnSnapEnabled
			end, 500 )
		end
	end

end


---[ Interoperability : Oops, I Did It Again ]---


function EHT.Interop.DisableOopsI()

	if OopsI and OopsI.ADDON_NAME and not OopsI.DisabledByEHT then

		OopsI.DisabledByEHT = true

		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_ADD_ON_LOADED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_GAME_CAMERA_UI_MODE_CHANGED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED )

		SLASH_COMMANDS[ "/oops" ] = nil
		SLASH_COMMANDS[ "/redo" ] = nil
		SLASH_COMMANDS[ "/undo" ] = nil
		SLASH_COMMANDS[ "/undohist" ] = nil
		SLASH_COMMANDS[ "/undoclear" ] = nil

		if not EHT.SavedVars.SuppressOopsIDidItAgainWarning then
			d( "'Essential Housing Tools' now includes Undo and Redo functionality and has replaced my earlier add-on 'Oops I Did It Again'." )
			d( "You may uninstall 'Oops I Did It Again' at your earliest convenience." )

			EHT.SavedVars.SuppressOopsIDidItAgainWarning = true
		end

	end

end

---[ Interoperability : Tamriel Trade Centre ]---

function EHT.Interop.IsTradingPriceInfoAvailable()
	return TamrielTradeCentrePrice ~= nil and TamrielTradeCentrePrice.GetPriceInfo ~= nil
end

--[[
Returns
	If no price data is available:
		nil
	If price data is available:
		Avg
		Min
		Max
		EntryCount
		AmountCount
		SuggestedPrice
]]
function EHT.Interop.GetItemLinkTradingPriceInfo( itemLink )
	if not EHT.Interop.IsTradingPriceInfoAvailable() then
		return
	end

	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo( itemLink )
	if priceInfo then
		if priceInfo.SuggestedPrice then
			priceInfo.Resale = priceInfo.SuggestedPrice
		elseif priceInfo.Avg then
			priceInfo.Resale = priceInfo.Avg
		elseif priceInfo.Min and priceInfo.Max then
			priceInfo.Resale = 0.5 * ( priceInfo.Min + priceInfo.Max )
		end
	end
	return priceInfo
end

---[ Interoperability : Inbound Events ]---

function EHT.Interop.FurnitureChangedEvent( furnitureId, x, y, z, pitch, yaw, roll )
	if furnitureId then
		EHT.Handlers.OnFurnitureChanged( { furnitureId, x or 0, y or 0, z or 0, pitch or 0, yaw or 0, roll or 0 } )
	end
end

function EHT.Interop.SuppressFurnitureChange( furnitureId )
	if furnitureId then
		EHT.Handlers.SuppressFurnitureChange( furnitureId )
	end
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Interop = true
