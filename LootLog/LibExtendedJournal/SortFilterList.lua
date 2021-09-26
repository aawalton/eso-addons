local Internal = LibExtendedJournalInternal


--------------------------------------------------------------------------------
-- ExtendedJournalSortFilterList
--------------------------------------------------------------------------------

ExtendedJournalSortFilterList = ZO_SortFilterList:Subclass()
local ExtendedJournalSortFilterList = ExtendedJournalSortFilterList

function ExtendedJournalSortFilterList:New( control, contextMenuItems )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list.contextMenuItems = contextMenuItems
	list:Setup()
	return list
end

function ExtendedJournalSortFilterList:SortScrollList( )
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		table.sort(ZO_ScrollList_GetDataList(self.list), self.sortFunction)
	end
	self:RefreshVisible()
end

function ExtendedJournalSortFilterList:Row_OnMouseUp( control, button, upInside )
	local data = ZO_ScrollList_GetData(control)
	local menuItems = self.contextMenuItems
	if (menuItems and #menuItems >= 1 and upInside) then
		if (button == MOUSE_BUTTON_INDEX_LEFT) then
			-- LMB: Invoke the first context menu item
			local _, action = menuItems[1](data)
			if (type(action) == "function") then action() end
		elseif (button == MOUSE_BUTTON_INDEX_RIGHT) then
			-- RMB: Open the context menu
			ClearMenu()
			for _, func in ipairs(menuItems) do
				local label, action = func(data)
				if (label and type(action) == "function") then
					AddMenuItem(Internal.GetString(label), action)
				end
			end
			self:ShowMenu(control)
		end
	end
end
