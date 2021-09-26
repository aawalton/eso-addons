
HomeStationMarker.Export = {}


function HomeStationMarker_Export_ToggleUI()
    local self = HomeStationMarker
    local h = HomeStationMarker_ExportUI:IsHidden()

    if not HomeStationMarker.Export.editbox then
        HomeStationMarker.Export.editbox = HomeStationMarker.Export.CreateEditBox()

        local lang = self.LANG[self.clientlang]["export"] or self.LANG["en"]["export"]

        HomeStationMarker_ExportUIWindowTitle:SetText(lang.WINDOW_TITLE)
    end

    if h then
        HomeStationMarker.Export:RefreshSoon()
    end

    HomeStationMarker_ExportUI:SetHidden(not h)
end

function HomeStationMarker_Import_ToggleUI()
    local self = HomeStationMarker
    local h = HomeStationMarker_ImportUI:IsHidden()

    if not HomeStationMarker.Export.editbox_import then
        HomeStationMarker.Export.editbox_import = HomeStationMarker_ImportUIEditBox

                        -- Leave "Import" button disabled until we have
                        -- text worthy of import.
        HomeStationMarker_ImportUIImportButton:SetEnabled(false)

                        -- Put the keyboard focus in the edit box so
                        -- we're immediately ready to accep the paste.
        zo_callLater(function() HomeStationMarker.Export.editbox_import:TakeFocus() end, 10)

        local lang = self.LANG[self.clientlang]["export"] or self.LANG["en"]["export"]
        HomeStationMarker_ImportUIWindowTitle:SetText(lang.WINDOW_TITLE_IMPORT)
        HomeStationMarker_ImportUIImportButton:SetText(lang.IMPORT_BUTTON)
    end

    HomeStationMarker_ImportUI:SetHidden(not h)
end

-- Zig ran into problems with the edit box not displaying more than 2818
-- characters. Rather than deeply debug and understand what went wrong, it's
-- easier for Zig to just bypass XML and create the UI element(s)
-- programmatically.
--
-- Only to later discover that the editbox-creation code was fine all along,
-- but the text data itself, full of colon ':', pipe '|', and number '0123456789'
-- characters somehow trigger undesired display failures in ZOS code. I suspect
-- that I'm triggering some item_link detecctor, even when
-- editbox:SetAllowMarkupType(ALLOW_MARKUP_TYPE_NONE).
--
function HomeStationMarker.Export.CreateEditBox()
    local container = HomeStationMarker_ExportUI

    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual( nil
                                                            , container
                                                            , "ZO_EditBackdrop"
                                                            )
    backdrop:SetAnchor(TOPLEFT,     container, TOPLEFT,      5, 50)
    backdrop:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -5, -5)

    local editbox = WINDOW_MANAGER:CreateControlFromVirtual(
          nil
        , backdrop
        , "ZO_DefaultEditMultiLineForBackdrop"
        )

    editbox:SetMaxInputChars(20000)

    local text = HomeStationMarker.Export.ToText()
    editbox:SetText(text)

                        -- Scroll to top. Doesn't work immediately, but
                        -- there's nothing that a SLEEP 10 can't fix!
    zo_callLater(function() editbox:SetCursorPosition(0) end, 10)

    return editbox
end

function HomeStationMarker_Import_OnTextChanged(new_text)
    HomeStationMarker.Debug("hi")
    ZO_EditDefaultText_OnTextChanged(HomeStationMarker_ImportUIEditBox)
    HomeStationMarker.Export.CallSoon("import_text_change_ms", HomeStationMarker.Export.RefreshImportNow)
end

function HomeStationMarker.Export.RefreshImportNow()
    local self = HomeStationMarker
    HomeStationMarker.Debug("parsing for status refresh...")

                        -- Parse text into station location table.
    local text = HomeStationMarker_ImportUIEditBox:GetText()
    local sl = HomeStationMarker.ImportStations(text)

                        -- Examine parse results.
    local house_name = nil
    if sl.house_id and tonumber(sl.house_id) then
        local cid = GetCollectibleIdForHouse(tonumber(sl.house_id))
        house_name = GetCollectibleName(cid)
    end
    local station_ct = 0
    for set_id, v in pairs(sl) do
        if type(v) == "table" then
            for station_id, coord in pairs(v) do
                if      coord.world_x
                    and coord.world_y
                    and coord.world_z
                    then
                        station_ct = station_ct + 1
                end
            end
        end
    end

                        -- Report parse results to player.
    local lang = self.LANG[self.clientlang]["export"] or self.LANG["en"]["export"]
    local function apnd(t, label, value, force_error_msg)
        local s = ""
        if value then
            if force_error_msg then
                s = string.format("%s : |cFF3333%s %s|r", label, tostring(value), force_error_msg)
            else
                s = string.format("%s : %s", label, tostring(value))
            end
        else
            s = string.format("|cFF3333%s : %s|r", label, lang.IMPORT_VALUE_MISSING)
        end
        table.insert(t, s)
    end

    local t = {}
    local err_server = nil
    if sl.server and sl.server ~= self.ServerName() then
        err_server = lang.IMPORT_ERROR_SERVER_MISMATCH
    end
    apnd(t, lang.IMPORT_LABEL_SERVER, sl.server , err_server)
    apnd(t, lang.IMPORT_LABEL_HOUSE,  house_name)
    apnd(t, lang.IMPORT_LABEL_OWNER,  sl.owner  )
    if 0 < station_ct then
        apnd(t, lang.IMPORT_LABEL_STATION_COUNT, tostring(station_ct))
    else
        apnd(t, lang.IMPORT_LABEL_STATION_COUNT, nil)
    end
    local summary_text = table.concat(t, "\n")
    HomeStationMarker_ImportUIStatus:SetText(summary_text)

    local can_import = sl.server
                     and sl.server == self.ServerName()
                     and sl.house_id
                     and sl.owner
                     and (0 < station_ct)
    HomeStationMarker_ImportUIImportButton:SetEnabled(can_import)

    HomeStationMarker.import_parse_results = sl
end

function HomeStationMarker_Import_OnClicked()
    HomeStationMarker.Export.ImportFromParsedOutput(HomeStationMarker.import_parse_results)
end

function HomeStationMarker.Export.ImportFromParsedOutput(parsed)
    local self = HomeStationMarker
                        -- Intentionally NOT raising shields here against any
                        -- error that RefreshImportNow() already rejects.

    HomeStationMarker.Info("Importing.")
    local house_id = tonumber(parsed.house_id)
    local owner    = parsed.owner
    local house_key = self.ToHouseKey(house_id, owner)
    for set_id, station_table in pairs(parsed) do
        local set_info = { ["set_id"] = set_id }
        if tonumber(set_id) then
            set_info.set_id = tonumber(set_id)
            if self.LibSets() then
                set_info.set_name = self.LibSets().GetSetName(set_info.set_id)
            end
        end
        if type(station_table) == "table" then
            for station_id, coord in pairs(station_table) do
                self.RecordStationLocation( house_key
                                          , station_id
                                          , set_info
                                          , coord
                                          )
            end
        end
    end
end

function HomeStationMarker.Export:RefreshSoon()
    local text = HomeStationMarker.Export.ToText()
    -- local text = HomeStationMarker.Export.GenerateText(6000)

    HomeStationMarker.Export.editbox:SetText(text:sub(1,MYSTERY_LIMIT))
end

function HomeStationMarker.Export.ToText()
    local self = HomeStationMarker
    local lang = self.LANG[self.clientlang]["export"] or self.LANG["en"]["export"]

    local house_key = self.CurrentHouseKey()
    if not house_key then
        return "# " .. lang.ERR_NOT_IN_HOUSE
    end

    local sv_l = self.saved_vars.station_location
    if not sv_l[house_key] then
        return "# ".. lang.ERR_NO_STATION_LOCATION
    end

    local h = { "server:"   .. self.ServerName()
              , "owner:"    .. GetCurrentHouseOwner()
              , "house_id:" .. tostring(GetCurrentZoneHouseId())
              }
    local house_text = table.concat(h, "\n") .. "\n"

    local station_location  = sv_l[house_key]
    local station_text      = HomeStationMarker.ExportStations(station_location)

    local preamble          = lang.PREAMBLE
    local postamble         = lang.POSTAMBLE
    local text              = preamble
                            .. "\n\n" .. house_text
                            .. "\n"   .. station_text
                            .. "\n"   .. postamble
                            .. "\n"

    HomeStationMarker.ZZ = text
    HomeStationMarker.Debug("char count:%d", #text)
    return text
end

-- function HomeStationMarker.Export.GenerateText(char_ct)
--     local char_per_line = 100
--     local line_template = "%04d: 789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 1234 6789 "
--     local line_template = string.sub(line_template,1,char_per_line-1).."\n"
--     local lines = {}
--     for char_i = 1,char_ct,char_per_line do
--         local line = string.format(line_template, char_i)
--         table.insert(lines,line)
--     end
--     return table.concat(lines,"")
-- end


-- Delayed refresh -----------------------------------------------------------
--
-- Don't hammer the CPU refreshing UI over and over while the user types
-- into a filter field. Delays call to refres (or `func` here) until after
-- 400ms or so have passed between keystrokes (or calls to `CallSoon()` here).
--
-- Copied from WritWorthy
--
function HomeStationMarker.Export.CallSoon(key, func)
    HomeStationMarker.Debug("CallSoon     k:%s %d", key, HomeStationMarker[key] or -1)
    if not HomeStationMarker[key] then
        zo_callLater( function()
                        HomeStationMarker.Export.CallSoonPoll(key, func)
                      end
                    , 250 )
    end
    HomeStationMarker[key] = GetFrameTimeMilliseconds() + 400
end


function HomeStationMarker.Export.CallSoonPoll(key, func)
    HomeStationMarker.Debug("CallSoonPoll k:%s %d", key, HomeStationMarker[key] or -1)
    if not HomeStationMarker[key] then return end
    local now = GetFrameTimeMilliseconds() or 0
    if now <= HomeStationMarker[key] then
        HomeStationMarker.Debug("CallSoonPoll k:%s fire", key)
        HomeStationMarker[key] = nil
        func()
    else
        zo_callLater( function()
                        HomeStationMarker.Export.CallSoonPoll(key, func)
                      end
                    , 250 )
    end
end
