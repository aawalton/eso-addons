--[[
if not EHT then EHT = { } end

if not EHTSaver then EHTSaver = { } end
local S = EHTSaver

if not S.Archive then S.Archive = { } end
if not S.Handlers then S.Handlers = { } end
if not S.Setup then S.Setup = { } end
if not S.UI then S.UI = { } end
if not S.Util then S.Util = { } end

local function NO_OP() end


S.ADDON_VERSION = "2"
S.ADDON_AUTHOR = "@Cardinal05, @Architectura"
S.ADDON_NAME = "EssentialHousingToolsSaver"
S.ADDON_TITLE = "Essential Housing Tools Saver"
S.ADDON_TITLE_LONG = S.ADDON_TITLE .. " (v " .. S.ADDON_VERSION .. ")"

S.SAVED_VARS_VERSION = 2
S.SAVED_VARS_FILE = "EssentialHousingToolsSaverSavedVars"
S.SAVED_VARS_DEFAULTS = {
	Archives = {
		
	}
}

S.CONST = { }
S.CONST.DIALOG_ALERT = "EHTSaverAlert"
S.CONST.DIALOG_CONFIRM = "EHTSaverConfirm"
S.CONST.KEY_MOST_RECENT_ARCHIVE = "EHTSaverMostRecentArchiveTimestamp"
S.CONST.MAX_ARCHIVES = 1
S.CONST.POST_RESET_ARCHIVE_DELAY = 60 * 60 * 24
S.CONST.POST_RESET_MAX_HOUSES = 5
S.CONST.RECENT_ARCHIVE_DELAY = 60 * 30

S.STRINGS = { }
local SS = S.STRINGS

SS.EHT_RESET_DETECTED = "|cff0000Well this isn't good...|r\n" ..
	"It seems as though your saved\n" ..
	"|cffffffEssential Housing Tools|r data has become corrupt.\n\n" ..
	"Corruption can sometimes result from a game crash or very large amounts of saved data.\n\n" ..
	"|c00ff00But there is good news...|r\n" ..
	"Your Essential Housing Tools data was backed up automatically on |cffffff%s|r at |cffffff%s|r.\n\n" ..
	"Would you like to restore this backup now?\n" ..
	"It will only take a few moments and then the User Interface will reload automatically."

SS.EHT_CONFIRM_RESTORE = "You are about to perform a FULL RESTORE of the most recent backup of your " ..
	"Essential Housing Tools data.\n\n" ..
	"Please note the following:\n\n" ..
	"|cffff00THIS PROCESS IS NOT REVERSIBLE.|r\n" ..
	"|cff0000ALL OF YOUR DATA WILL BE REVERTED TO THE BACKUP TAKEN ON|r\n" ..
	"|cffffff%s|r at |cffffff%s|r.\n\n" ..
	"Do you want to proceed with this restore operation?"

SS.EHT_RESTORE_DECLINED = "If you change your mind, you will have the option to restore the " ..
	"|cffffffEssential Housing Tools|r backup data until %s at %s.\n\n" ..
	"To restore the backup, use the button:\n" ..
	"|cffffffSettings|r >\n  |cffffffAddons|r >\n  |cffffffEssential Housing Tools|r >\n  |cff0000Repeair Corrupt Database|r"


-- Saved Variables
local vars


--- Add-On : Initialization ---


function S.Setup.Initialize()

	S.SavedVars = ZO_SavedVars:NewAccountWide( S.SAVED_VARS_FILE, S.SAVED_VARS_VERSION, nil, S.SAVED_VARS_DEFAULTS )
	vars = S.SavedVars
	--if not vars.Archives then vars.Archives = { } end
	--S.Setup.InitializeSlashCommands()

end


function S.Setup.InitializeSlashCommands()

	SLASH_COMMANDS[ "/ehtsaver" ] = S.Setup.ExecuteSlashCommand

end


function S.Setup.ExecuteSlashCommand( cmd )

	if nil == cmd then
		cmd = ""
	else
		cmd = string.lower( cmd )
	end

	if "archive" == cmd or "backup" == cmd then

		df( "Creating archive..." )
		local archive = S.Archive.CreateArchive()

		if nil == archive then
			df( "Failed to create archive." )
		else
			df( "Archive created on %s at %s.", archive.Date, archive.Time )
		end

		return true

	end

	if "restore" == cmd then

		local archive = S.Archive.GetMostRecentArchive()
		if nil == archive then
			df( "No archives found." )
			return true
		end

		df( "Restoring archive from %s on %s...", archive.Date, archive.Time )
		S.Archive.RestoreMostRecentArchive()

		return true

	end

	if "list" == cmd then

		local archives = S.Archive.GetArchives()
		local archiveCount = 0
		df( "Automatic Archives:" )

		if nil ~= archives then

			archiveCount = #archives
			for index, archive in ipairs( archives ) do
				df( "%d. %s at %s", index, archive.Date, archive.Time )
			end

		end

		df( "%d Archive(s).", archiveCount )

		return true

	end

	df( "Essential Housing Tools Saver commands" )
	df( "/ehtsaver backup" )
	df( " - Creates a new archive." )
	df( "/ehtsaver restore" )
	df( " - Restores the most recent archive." )
	df( "/ehtsaver list" )
	df( " - Lists stored archives." )

	return true

end


--- Add-On : Archive Management ---


function S.Archive.GetEHTSavedVars()

	return EHT.SavedVars

end


local function CompareArchiveAges( archive1, archive2 )

	return archive1.Timestamp > archive2.Timestamp

end


function S.Archive.GetArchives()

	table.sort( vars.Archives, CompareArchiveAges )
	return vars.Archives

end


function S.Archive.ClearArchives()

	vars.Archives = { }
	S.Archive.ClearArchiveDelay()
	S.Handlers.OnArchivesChanged()

end


function S.Archive.GetMostRecentArchive()

	local archives = S.Archive.GetArchives()
	return archives[1]

end


function S.Archive.TrimArchives()

	local archives = S.Archive.GetArchives()
	local minIndex, maxIndex = S.CONST.MAX_ARCHIVES + 1, #archives
	local numArchivesRemoved = 0

	if minIndex <= maxIndex then

		numArchivesRemoved = maxIndex - minIndex + 1

		for i = maxIndex, minIndex, -1 do
			table.remove( archives, i )
		end

	end

	return numArchivesRemoved

end


function S.Archive.CreateArchive()

	local es = S.Archive.GetEHTSavedVars()
	if not es then return end

	local esData = { }
	for eKey, _ in pairs( es.default ) do
		esData[ eKey ] = S.Util.CloneTable( es[ eKey ] )
	end

	local tstamp, dateString, timeString = S.Util.GetTimestamp()
	local archive = {
		Timestamp = tstamp,
		Date = dateString,
		Time = timeString,
		Archive = esData
	}

	local archives = S.Archive.GetArchives()
	table.insert( archives, 1, archive )

	local mostRecentKey = S.CONST.KEY_MOST_RECENT_ARCHIVE
	es[ mostRecentKey ] = tstamp
	vars[ mostRecentKey ] = tstamp

	S.Archive.ClearArchiveDelay()
	S.Handlers.OnArchivesChanged()

	return archive

end


function S.Archive.RestoreMostRecentArchive()

	local mostRecentKey = S.CONST.KEY_MOST_RECENT_ARCHIVE

	local es = S.Archive.GetEHTSavedVars()
	if not es then return false end

	local archive = S.Archive.GetMostRecentArchive()
	if not archive then return false end

	for aKey, _ in pairs( archive.Archive ) do
		es[ aKey ] = archive.Archive[ aKey ]
	end

	es.LastEHTSaverRestore = GetTimeStamp()
	es[ mostRecentKey ] = archive.Timestamp
	vars[ mostRecentKey ] = archive.Timestamp

	S.Archive.ClearArchiveDelay()

	ReloadUI()
	return true

end

--/script for k, v in pairs( EHTSaver.Archive.GetEHTSavedVars() ) do if string.find( k, "EHTSaver" ) then d( k, v ) end end
function S.Archive.GetMostRecentArchiveTimestamps()

	local mostRecentKey = S.CONST.KEY_MOST_RECENT_ARCHIVE
	local es = S.Archive.GetEHTSavedVars()

	if nil ~= es then
		return es[ mostRecentKey ], vars[ mostRecentKey ]
	else
		return nil, vars[ mostRecentKey ]
	end

end


function S.Archive.SetArchiveDelay()

	if nil == vars.DelayArchiveUntil then
		vars.DelayArchiveUntil = GetTimeStamp() + S.CONST.POST_RESET_ARCHIVE_DELAY
	end

end


function S.Archive.GetArchiveDelay()

	return vars.DelayArchiveUntil

end


function S.Archive.ClearArchiveDelay()

	vars.DelayArchiveUntil = nil

end


function S.Archive.HasEHTSavedVarsReset()

	local ehtTS, sTS = S.Archive.GetMostRecentArchiveTimestamps()
	local es = S.Archive.GetEHTSavedVars()

	if nil ~= es and nil ~= es.Houses and nil == ehtTS and nil ~= sTS then

		local archive = S.Archive.GetMostRecentArchive()

		if nil ~= archive and nil ~= archive.Archive and nil ~= archive.Archive.Houses then
			if S.CONST.POST_RESET_MAX_HOUSES >= S.Util.TableCountShallow( es.Houses ) and S.Util.TableCountShallow( archive.Archive.Houses ) >= S.Util.TableCountShallow( es.Houses ) then
				return true
			end
		end

	end

	return false

end

-- /script local eTS, sTS = EHTSaver.Archive.GetMostRecentArchiveTimestamps() d( ".", eTS, sTS )
function S.Archive.IsRecentlyArchived()

	local _, sTS = S.Archive.GetMostRecentArchiveTimestamps()
	local now = GetTimeStamp()
	return nil ~= sTS and ( now - sTS ) < S.CONST.RECENT_ARCHIVE_DELAY

end


function S.Archive.AutoCreateArchive( loggingOut )

	if true ~= loggingOut then loggingOut = false end

	local hasReset = S.Archive.HasEHTSavedVarsReset()
	if hasReset then

		local delay = S.Archive.GetArchiveDelay()
		if nil ~= delay then

			local now = GetTimeStamp()
			if now >= delay or delay > ( now + 2 * S.CONST.POST_RESET_ARCHIVE_DELAY ) then

				S.Archive.ClearArchives()

			else

				return

			end

		else

			if not loggingOut then
				S.Archive.SetArchiveDelay()
				zo_callLater( S.Archive.ConfirmPostResetRestore, 1000 )
			end

			return

		end

	end

	if not loggingOut and S.Archive.IsRecentlyArchived() then return end

	S.Archive.CreateArchive()

end


function S.Archive.ConfirmPostResetRestore( finalConfirm )

	local archive = S.Archive.GetMostRecentArchive()
	if nil == archive then return end

	if "CONFIRM" ~= finalConfirm then

		local message = string.format( SS.EHT_RESET_DETECTED, archive.Date, archive.Time )
		S.UI.ShowConfirmDialog( message, function() S.Archive.ConfirmPostResetRestore( "CONFIRM" ) end, S.Archive.DeclinePostResetRestore )

	else

		local message = string.format( SS.EHT_CONFIRM_RESTORE, archive.Date, archive.Time )
		S.UI.ShowConfirmDialog( message, S.Archive.RestoreMostRecentArchive, S.Archive.DeclinePostResetRestore )

	end

end


function S.Archive.DeclinePostResetRestore()

	local dateString, timeString = "", ""

	local delay = S.Archive.GetArchiveDelay()
	if nil ~= delay then dateString, timeString = S.Util.GetTimestampDateTime( delay ) end

	local message = string.format( SS.EHT_RESTORE_DECLINED, dateString, timeString )

	S.UI.ShowAlertDialog( message )

end


--- User Interface : Dialogs ---


function S.UI.SetupAlertDialog()

	local dialog = ESO_Dialogs[ S.CONST.DIALOG_ALERT ]

    if not dialog then

		dialog = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_OK,
                    callback = function( dlg ) end,
                }
            }
        }

		ESO_Dialogs[ S.CONST.DIALOG_ALERT ] = dialog

    end

	return dialog

end


function S.UI.SetupConfirmDialog()

	local dialog = ESO_Dialogs[ S.CONST.DIALOG_CONFIRM ]

    if not dialog then

		dialog = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_DIALOG_CONFIRM,
                    callback = function( dlg ) end,
                },
                [2] = {
                    text = SI_DIALOG_CANCEL,
					callback = function( dlg ) end,
                }
            }
        }

		ESO_Dialogs[ S.CONST.DIALOG_CONFIRM ] = dialog

    end

	return dialog

end


function S.UI.ShowAlertDialog( message, callback )

	if nil == callback then callback = NO_OP end

    local dialog = S.UI.SetupAlertDialog()

    dialog.title.text = S.ADDON_TITLE
    dialog.mainText.text = message
    dialog.buttons[1].callback = callback

    ZO_Dialogs_ShowDialog( S.CONST.DIALOG_ALERT )

end


function S.UI.ShowConfirmDialog( message, confirmCallback, cancelCallback )

	if nil == confirmCallback then confirmCallback = NO_OP end
	if nil == cancelCallback then cancelCallback = NO_OP end

    local dialog = S.UI.SetupConfirmDialog()

    dialog.title.text = S.ADDON_TITLE
    dialog.mainText.text = message
    dialog.buttons[1].callback = confirmCallback
	dialog.buttons[2].callback = cancelCallback

    ZO_Dialogs_ShowDialog( S.CONST.DIALOG_CONFIRM )

end


--- Utilities : Tables ---


function S.Util.CloneTable( obj )

	local oT = type( obj )

	if "table" ~= oT then
		if "number" == oT then
			if obj ~= obj or -obj ~= -obj then
				return 0
			else
				return obj
			end
		elseif "boolean" == oT or "string" == oT then
			return obj
		else
			return nil
		end
	end

	local tbl = { }

	for k, v in pairs( obj ) do
		tbl[ k ] = S.Util.CloneTable( v )
	end

	return tbl

end


function S.Util.TableCountShallow( t )

	local count = 0
	if nil ~= t and "table" == type( t ) then for _, _ in pairs( t ) do count = count + 1 end end
	return count

end


--- Utilities : Time ---


function S.Util.GetTimestamp()

	local tstamp = GetTimeStamp()
	local dateString, timeString = FormatAchievementLinkTimestamp( tstamp )
	return tstamp, dateString, timeString

end


function S.Util.GetTimestampDateTime( tstamp )

	local dateString, timeString = FormatAchievementLinkTimestamp( tstamp )
	return dateString, timeString

end


function S.Util.GetTimestampDifferenceInSeconds( tstamp1, tstamp2 )

	if nil == tstamp2 then tstamp2 = GetTimeStamp() end
	return GetDiffBetweenTimeStamps( tstamp1, tstamp2 )

end


--- Events : Handlers ---


function S.Handlers.OnAddOnLoaded( event, addonName )

	if addonName == S.ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent( S.ADDON_NAME, EVENT_ADD_ON_LOADED )
		S.Setup.Initialize()
	end

end


function S.Handlers.OnPlayerActivated( event, firstActivation )

	zo_callLater( S.Archive.AutoCreateArchive, 10000 )

end


function S.Handlers.OnLogoutDeferred( event, deferMilliseconds, quitRequested )

	S.Archive.AutoCreateArchive( true )

end


function S.Handlers.OnArchivesChanged()

	S.Archive.TrimArchives()

end


--- Events : Handler Registrations ---


EVENT_MANAGER:RegisterForEvent( S.ADDON_NAME, EVENT_ADD_ON_LOADED, S.Handlers.OnAddOnLoaded )
--EVENT_MANAGER:RegisterForEvent( S.ADDON_NAME, EVENT_PLAYER_ACTIVATED, S.Handlers.OnPlayerActivated )
--EVENT_MANAGER:RegisterForEvent( S.ADDON_NAME, EVENT_LOGOUT_DEFERRED, S.Handlers.OnLogoutDeferred )
]]