function SetScrollPositionByIndex(index, AlbumID)
	if (AlbumID == 1) then
		CurrentAlbum = Travel;	
	elseif (AlbumID == 2) then
		CurrentAlbum = Titans;
	elseif (AlbumID == 3) then
		CurrentAlbum = TidesofV;
	elseif (AlbumID == 4) then
		--CurrentAlbum = N/A;
	end

	--Journal.VirtualFrame:Show()
	--Journal.ListScrollFrame:Show()
	--Journal.VirtualFrame.JournalPinButton:Enable();
	local Journal = AAA_Journal
	Journal.VirtualFrame:SetAlpha(1);
	Journal_UpdateList()
	local ExpectedValue = Journal.ListScrollFrame.buttons[1]:GetHeight()*(index - 1);
	Journal.ListScrollFrame.scrollBar:SetValue(ExpectedValue);
	local RealValue = Journal.ListScrollFrame.scrollBar:GetValue();
	--print(ExpectedValue)
	--print(index)
	if(Round(ExpectedValue) == RealValue) then
		Journal.ListScrollFrame.buttons[1]:Click();
	else
		Journal.ListScrollFrame.buttons[7-(#CurrentAlbum-index)]:Click();	
	end
end

function AAA_AlertFrameSystems_Register()
	if not JournalNotification then
		CreateFrame("Button","JournalNotification",nil,"JournalNotificationTemplate")
	end
	JournalNotification.soundtrack = nil;
end

function AlertFrame_OnClick(self, button, down)
	if button == "RightButton" then
		self:Hide();
		return true;
	end

	return false;
end

function CardAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
		local Journal = AAA_Journal
		lastbuttonNumber = 0; --avoid double-click
		filterChoice = nil;
		AAA_GetTotalProgress();
		if (not AAASwitch:IsShown()) then
			AAA_ShowPanel();
		end
		Journal.JournalBottomPanel.FilterButton.CurrentChoice:SetText(MENU_BFA)
		SetScrollPositionByIndex(CardID, AlbumID);
		if AlbumID == 1 then
			Journal.JournalBottomPanel.FilterButton:Enable();
		end
		Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:SetTexture(Journal.VirtualFrame.JournalDisplayTopLayer.Display:GetTexture());

		Journal.BackButton:Show();
		Journal.ListScrollFrame:SetFrameStrata("HIGH")
		Journal.VirtualFrame:SetFrameStrata("HIGH")
		Journal.ListScrollFrame2:SetFrameStrata("LOW")
		Journal.VirtualFrame.JournalPinButton:Enable();
		Journal.ListScrollFrame:Show();
		Journal.ListScrollFrame:SetAlpha(1);
		Journal.VirtualFrame:Show();
		UIFrameFadeIn(Journal.VirtualFrame, 0, 1, 1)
		UIFrameFadeIn(Journal.ListScrollFrame, 0, 1, 1)

		self:Hide();

		if (JournalNotification.soundtrack ~= nil) then
			PlaySound(JournalNotification.soundtrack)
		end
end

function Alert_OnLoad()
	if AAA_Journal:IsShown() then
	end
end