--------------------------------------
-------------Localization-------------
--------------------------------------
--local TravelBak = Travel;
local L = AAA.L
local ReleaseDate = "April.19,2019"

AAA_MENU_VERSION_STRING = "1.3.3"
AAA_MENU_VERSION_NUMBER = 133;

filterChoice = nil;
CurrentAlbum = Travel;
--local AAASettings["GlobalScale"] = 1;
local FrameGap = 1/60;
local BlackscreenAlpha = 0.25;

MENU_OPENSOUND  = SOUNDKIT.ACHIEVEMENT_MENU_OPEN;

--------------------------------------
local function OpenNClosePanel()
	if (not AAASwitch:IsShown()) then
		DoEmote("Read", "none")
		AAA_ShowPanel();
	else
		AAA_HidePanel();
		DoEmote("Read", "none")
	end
end

SLASH_AAA1 = "/aaa"
SlashCmdList["AAA"] = function()
	OpenNClosePanel()
end
-------------------------------------
local function ResetAlbum()
	DropdownButton_Update(_,"clear")
	local Journal = AAA_Journal;
	Journal.selectedID = nil;
	sub_Num = nil;
	Journal.ListScrollFrame.scrollBar:SetValue(0);
	Journal.VirtualFrame.JournalDisplayTopLayer.Display:SetTexture("Interface/AddOns/AzerothAdventureAlbum/ART/Album/DefaultCover")
	Journal.VirtualFrame.JournalTestBackground:Hide();
	Journal.VirtualFrame.JournalPinButton.PinButtonDown:Hide();
	Journal.VirtualFrame.JournalPinButton.PinButtonUp:Hide();
	Journal.VirtualFrame.JournalPinButton:SetAlpha(0);
end

local function ShowShelf()
	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN);
	local Journal = AAA_Journal;
	Journal.JournalBottomPanel.FilterButton:Disable();
	Journal.JournalBottomPanel.animIn:SetScript("OnPlay", function()
		AAA_GetTotalProgress();
	end);
	
	Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:Hide();
	Journal.VirtualFrame.JournalPinButton:Disable();

	local animationDuration = 0.3;

	local ag = Journal.ListScrollFrame:CreateAnimationGroup();
	local a1 = ag:CreateAnimation("Alpha");

	a1:SetFromAlpha(1);
	a1:SetDuration(animationDuration);
	a1:SetToAlpha(0);		
	ag:SetScript("OnFinished", function()
		Journal.ListScrollFrame:Hide()
	end);

	local ag2 = Journal.VirtualFrame:CreateAnimationGroup();
	local a2 = ag2:CreateAnimation("Alpha");

	a2:SetFromAlpha(1);
	a2:SetDuration(animationDuration);
	a2:SetToAlpha(0);		
	ag2:SetScript("OnFinished", function()
		Journal.VirtualFrame:Hide()
	end);

	ag:Play();
	ag2:Play();

	Journal.ListScrollFrame2:SetFrameStrata("HIGH");
	UIFrameFadeIn(Journal.ListScrollFrame2, animationDuration, 0, 1);
	Journal.JournalBottomPanel.animOut:Play();
	Journal.BackButton:Hide();
end

function AAA_HideShelf(self)
	local Journal = AAA_Journal;
	Journal.Filter:Hide();
	Journal.Settings:Hide();

	
	AAA_DisableShelf();

	filterChoice = nil;
	Journal.selectedID = nil;
	lastbuttonNumber = 0;

	Journal.JournalBottomPanel.animIn:SetScript("OnPlay", function()
		AAA_UpdateProgress()
		Journal.JournalBottomPanel.FilterButton.CurrentChoice:SetText(AAA_MENU_BFA);
	end);

	ChangeCurrentAlbum(self);
	ResetAlbum();
	SetThumbTextureHeight()
	Journal.VirtualFrame.JournalDisplayTopLayer.Display:SetTexture(CurrentAlbum["DefaultCover"]);
	Journal.VirtualFrame.JournalPinButton:Enable();

	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_CLOSE);
	local animationDuration = 0.5
	

	local ag = Journal.ListScrollFrame2:CreateAnimationGroup();
	local a1 = ag:CreateAnimation("Alpha");

	a1:SetFromAlpha(1);
	a1:SetDuration(animationDuration);
	a1:SetToAlpha(0);	

	ag:SetScript("OnStop", function()
		AAA_EnableShelf();
	end);		
	ag:SetScript("OnFinished", function()
		Journal.ListScrollFrame2:SetFrameStrata("LOW");
		Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:Show();
		Journal.VirtualFrame:SetAlpha(1);
		C_Timer.After(0.6, function()
			AAA_EnableShelf();
		end)
	end);

	

	local ag2 = Journal.ListScrollFrame:CreateAnimationGroup();
	local a2 = ag2:CreateAnimation("Alpha");

	a2:SetFromAlpha(0);
	a2:SetDuration(animationDuration);
	a2:SetToAlpha(1);		
	ag2:SetScript("OnPlay", function()
		Journal.ListScrollFrame:Show()
	end);

	local ag3 = Journal.ListScrollFrame.ScrollChild:CreateAnimationGroup();
	local a3 = ag3:CreateAnimation("Translation");
	local offsetX = 100;
	a3:SetOrder(1);
	a3:SetOffset(0, offsetX);
	a3:SetDuration(0);

	local a4 = ag3:CreateAnimation("Translation");
	a4:SetOrder(2);
	a4:SetOffset(0, -offsetX);
	a4:SetSmoothing("OUT");
	a4:SetDuration(animationDuration);
	ag:Play();
	ag2:Play();
	ag3:Play();
	UIFrameFadeIn(Journal.VirtualFrame, animationDuration, 0, 1)
	Journal.JournalBottomPanel.animOut:Play();
	Journal.BackButton:Show();
end

local function HybridScrollFrame_CreateButtons_Horizontal(self, buttonTemplate, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	local scrollChild = self.scrollChild;
	local button, buttonWidth, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	initialPoint = initialPoint or "TOPLEFT";
	initialRelative = initialRelative or "TOPLEFT";
	point = point or "TOPLEFT";
	relativePoint = relativePoint or "TOPRIGHT";
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if ( self.buttons ) then
		buttons = self.buttons;
		buttonWidth = buttons[1]:GetWidth();
		buttonHeight = buttons[1]:GetHeight();
	else
		button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, scrollChild, buttonTemplate);
		buttonWidth = button:GetWidth();
		buttonHeight = button:GetHeight();
		button:SetPoint(initialPoint, scrollChild, initialRelative, initialOffsetX, initialOffsetY);
		buttons = {}
		tinsert(buttons, button);
	end

	self.buttonWidth = Round(buttonWidth) - offsetX;

	local numButtons = math.ceil(self:GetWidth() / buttonWidth) + 1;

	for i = #buttons + 1, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, scrollChild, buttonTemplate);
		button:SetPoint(point, buttons[i-1], relativePoint, offsetX, offsetY);
		tinsert(buttons, button);
	end

	scrollChild:SetHeight(self:GetHeight())
	scrollChild:SetWidth(numButtons * buttonWidth);
	self:SetVerticalScroll(0);
	self:UpdateScrollChildRect();

	self.buttons = buttons;
	local scrollBar = self.scrollBar;
	scrollBar:SetMinMaxValues(0, numButtons * buttonWidth)
	scrollBar.buttonWidth = buttonWidth;
	scrollBar.buttonHeight = buttonHeight;
	scrollBar:SetValueStep(buttonWidth);
	scrollBar:SetStepsPerPage(numButtons - 2);
	scrollBar:SetValue(0);

end
--------------------------------------
------------MinimapButton-------------
--------------------------------------
-- Derivative from [[LibDBIcon-1.0]]

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function AAA_MinimapButton_UpdateAngle(radian)
	local cos, sin, sqrt, max, min = math.cos, math.sin, math.sqrt, math.max, math.min
	local x, y, q = cos(radian), sin(radian), 1
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	local w = (Minimap:GetWidth() / 2) + 10
	local h = (Minimap:GetHeight() / 2) + 10
	if quadTable[q] then
		x, y = x*w, y*h
	else
		local diagRadiusW = sqrt(2*(w)^2) - 10	--  -10
		local diagRadiusH = sqrt(2*(h)^2) - 10
		x = max(-w, min(x*diagRadiusW, w))
		y = max(-h, min(y*diagRadiusH, h))
	end
	AAA_MinimapButton:SetPoint("CENTER", "Minimap", "CENTER", x, y)
end

local function AAA_MinimapButton_OnLoad()
	local radian = AAASettings["MinimapAngle"];
	AAA_MinimapButton_UpdateAngle(radian);
end

function AAA_MinimapButton_DraggingFrame_OnUpdate()
	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
	local button = AAA_MinimapButton
	local radian

	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	radian = math.atan2(py - my, px - mx);

	AAA_MinimapButton_UpdateAngle(radian);
	AAASettings["MinimapAngle"] = radian;
end


function MinimapButton_Update()
	if(AAASettings["Minimap"] ~= nil and AAASettings["Minimap"] == true) then
		AAA_MinimapButton:Show();
	else
		AAA_MinimapButton:Hide();
	end
end

function AAA_MinimapButton_OnClick(self, button, down)
	GameTooltip:Hide()

	if button == "RightButton" then
		self:Hide();
		print(BUTTON_MINIMAP_DISABLED)
		AAASettings["Minimap"] = false;
		UpdateMinimapSettings();
		return;
	end
	
	if button == "LeftButton" then
		OpenNClosePanel();

		self:Disable();
		C_Timer.After(0.8, function()
			self:Enable()
		end)
		return;
	end
end




function UpdateSettings()
	local Journal = AAA_Journal;
	local Setting = Journal.Settings
	if (AAASettings["Minimap"]) then
		Setting.MiniButton.ButtonName:SetTextColor(0,1,0);
		Setting.MiniButton.ButtonName:SetText(AAA_MENU_ENABLED);
	else
		Setting.MiniButton.ButtonName:SetTextColor(1,0,0);
		Setting.MiniButton.ButtonName:SetText(AAA_MENU_DISABLED);
	end

	if (AAASettings["Little Things"]) then
		Setting.LittleThingsButton.ButtonName:SetTextColor(0,1,0);
		Setting.LittleThingsButton.ButtonName:SetText(AAA_MENU_ENABLED);
	else
		Setting.LittleThingsButton.ButtonName:SetTextColor(1,0,0);
		Setting.LittleThingsButton.ButtonName:SetText(AAA_MENU_DISABLED);
	end

	if (AAASettings["Darken Background"]) then
		Blackscreen.Black:SetColorTexture(0,0,0, BlackscreenAlpha);
		Setting.DarkenButton.ButtonName:SetTextColor(0,1,0);
		Setting.DarkenButton.ButtonName:SetText(AAA_MENU_ENABLED);
	else
		Blackscreen.Black:SetColorTexture(0,0,0,0);
		Setting.DarkenButton.ButtonName:SetTextColor(1,0,0);
		Setting.DarkenButton.ButtonName:SetText(AAA_MENU_DISABLED);
	end

	if (AAASettings["Night Mode"]) then
		Setting.NightModeButton.ButtonName:SetTextColor(0,1,0);
		Setting.NightModeButton.ButtonName:SetText(AAA_MENU_ENABLED);
	else
		Setting.NightModeButton.ButtonName:SetTextColor(1,0,0);
		Setting.NightModeButton.ButtonName:SetText(AAA_MENU_DISABLED);
	end

	if (AAASettings["Pin Style"] == 1) then
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin1");
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin1");
		Setting.PinStyleButton.ButtonName:SetText(AAA_MENU_PAPERCLIP);
	elseif (AAASettings["Pin Style"] == 2) then
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin2");
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin2");
		Setting.PinStyleButton.ButtonName:SetText(AAA_MENU_TAPE);
	elseif (AAASettings["Pin Style"] == 3) then
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin3");
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin3");
		Setting.PinStyleButton.ButtonName:SetText(AAA_MENU_STAPLE);
	end

	if AAASettings["GlobalScale"] == 1 then
		Setting.ScaleButton.ButtonName:SetText(AAA_MENU_SCALE_REGULAR);
	else
		Setting.ScaleButton.ButtonName:SetText(AAA_MENU_SCALE_SMALL);
	end
end

local LoadSettings = CreateFrame("Frame");

LoadSettings:RegisterEvent("PLAYER_ENTERING_WORLD");

LoadSettings:SetScript("OnEvent",function(self,event,...)
		AAA_MinimapButton_OnLoad();
		MinimapButton_Update();
		InitializeIntroPage();
		UpdateSettings();
		LoadSettings:UnregisterEvent("PLAYER_ENTERING_WORLD");
		local Journal = AAA_Journal;
		Journal.ListScrollFrame:SetScript("OnMouseWheel", SmoothScroll_OnMouseWheel);
end)


--------------------------------------
-------------DropdownMenu-------------
--------------------------------------
function SetThumbTextureHeight()
	if(CurrentAlbum ~= nil) then
		local Journal = AAA_Journal;
		Journal.ListScrollFrame.scrollBar.thumbTexture:SetHeight(Round(470*7/(#CurrentAlbum+1)))
	end
end

function UpdateShelfProgressBar(self, button)
	local done, sum
	local buttonNumber = self.buttonNumber or button.buttonNumber;
	if (buttonNumber == 1) then
		done, sum = AAA_CheckProgress(Travel);
	elseif (buttonNumber == 2) then
		done, sum = AAA_CheckProgress(Titans);
	elseif (buttonNumber == 3) then
		done, sum = AAA_CheckProgress(TidesofV);
	elseif (buttonNumber == 4) then
		--CurrentAlbum = N/A;
	end
	done = done or 10;
	sum = sum or 10;
	local CurrentButton = self or button
	CurrentButton.StatusNum:SetText(done.."/"..sum)
	CurrentButton.StatusBar:SetWidth(182*done/sum);
end

function AAA_CheckProgress(Album)
	local done = 0;
	for i=1, #Album, 1 do
		if (Album[i]["Status"] == true) then
			done = done + 1;
		end
	end
	return done, #Album;
end

function AAA_GetTotalProgress()
	local a, _ = AAA_CheckProgress(Travel);
	local b, _ = AAA_CheckProgress(Titans);
	local c, _ = AAA_CheckProgress(TidesofV);
	local totals = #Travel + #Titans + #TidesofV;
	local Journal = AAA_Journal;

	Journal.JournalBottomPanel.FilterButton.CurrentChoice:SetText(AAA_MENU_TOTALS)
	Journal.JournalBottomPanel.FilterButton.CurrentProgress:SetText(a+b+c.."/"..totals)
end

function ChangeCurrentAlbum(self)
	local Journal = AAA_Journal;

	if (self.buttonNumber == 1) then
		CurrentAlbum = Travel;	
	elseif (self.buttonNumber == 2) then
		CurrentAlbum = Titans;
	elseif (self.buttonNumber == 3) then
		CurrentAlbum = TidesofV;
	elseif (self.buttonNumber == 4) then
		
	end
	if (self.buttonNumber == 1) then
		Journal.JournalBottomPanel.FilterButton:Enable();
	else
		Journal.JournalBottomPanel.FilterButton:Disable();
	end
	Journal_UpdateList();
end

function AAA_UpdateProgress()
	local sum_all, done_all, sum_sub, done_sub = 0, 0, 0, 0;
	local Journal = AAA_Journal;
	sum_all = #CurrentAlbum;
	if (filterChoice == nil) then
		for i=1, #CurrentAlbum, 1 do
			if (CurrentAlbum[i]["Status"] == true) then
				done_all = done_all + 1;
			end
		end
		Journal.JournalBottomPanel.FilterButton.CurrentProgress:SetText(done_all.."/"..sum_all);
		return sum_all
	else
		for i=1, #CurrentAlbum, 1 do
			if (CurrentAlbum[i]["mapID"] == filterChoice) then
				sum_sub = sum_sub + 1;
				if (CurrentAlbum[i]["Status"] == true) then
					done_sub = done_sub +1;
				end
			elseif (filterChoice == 862 and CurrentAlbum[i]["mapID"] == 1165) then --Dazar'alor
				sum_sub = sum_sub + 1;
				if (CurrentAlbum[i]["Status"] == true) then
					done_sub = done_sub +1;
				end
			elseif (filterChoice == 895 and CurrentAlbum[i]["mapID"] == 1161) then --Boralus
				sum_sub = sum_sub + 1;
				if (CurrentAlbum[i]["Status"] == true) then
					done_sub = done_sub +1;
				end
			end
		end
		Journal.JournalBottomPanel.FilterButton.CurrentProgress:SetText(done_sub.."/"..sum_sub);
		return sum_sub
	end
end

function DropdownButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	DropdownButton_Update(self);
	local mapName =self.ButtonName:GetText();
	local temp = filterChoice;
	local Journal = AAA_Journal;

	if 	   (mapName == AAA_MENU_NAZMIR) then
		filterChoice = 863;
	elseif (mapName == AAA_MENU_VOLDUN) then
		filterChoice = 864;
	elseif (mapName == AAA_MENU_ZULDAZAR) then
		filterChoice = 862;
	elseif (mapName == AAA_MENU_STORMSONG) then
		filterChoice = 942;
	elseif (mapName == AAA_MENU_DRUSTVAR) then
		filterChoice = 896;
	elseif (mapName == AAA_MENU_TIRAGARDE) then
		filterChoice = 895;
	elseif (mapName == AAA_MENU_BFA) then
		filterChoice = nil;
	end

	Journal.JournalBottomPanel.FilterButton.CurrentChoice:SetText(self.ButtonName:GetText())
	
	sub_Num = AAA_UpdateProgress(filterChoice)

	if (filterChoice ~= temp) then
		Journal.ListScrollFrame.animOut:Play();
	end
end


function DropdownButton_Update(self, command)
	local Journal = AAA_Journal;
	local FilterButtonList = {};
	FilterButtonList[1] =Journal.Filter.DropdownButton1;
	FilterButtonList[2] =Journal.Filter.DropdownButton2;
	FilterButtonList[3] =Journal.Filter.DropdownButton3;
	FilterButtonList[4] =Journal.Filter.DropdownButton4;
	FilterButtonList[5] =Journal.Filter.DropdownButton5;
	FilterButtonList[6] =Journal.Filter.DropdownButton6;
	FilterButtonList[7] =Journal.Filter.DropdownButton7;
	local chosen = command or self:GetName();
	if (command == "clear") then
		FilterButtonList[1].ButtonName:SetTextColor(1,0.8,0);
		for i=2,#FilterButtonList,1 do
			FilterButtonList[i].ButtonName:SetTextColor(1,1,1);
		end
	else		
	for i=1,7,1 do
		if (FilterButtonList[i]:GetName() == self:GetName()) then
			FilterButtonList[i].ButtonName:SetTextColor(1,0.8,0);
		else
			FilterButtonList[i].ButtonName:SetTextColor(1,1,1);
		end
	end
	end
end

--------------------------------------
---------------Settings---------------
--------------------------------------


function VersionButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(MENU_AAA_GRADIENT);
	GameTooltip:AddLine(" ", 1, 1, 1, true);
	GameTooltip:AddDoubleLine(AAA_MENU_RELEASE_DATE, ReleaseDate, nil, nil, nil, 1 , 1, 1);
	GameTooltip:AddDoubleLine(L["Author"], "Peterodox", nil, nil, nil, 1 , 1, 1);
	GameTooltip:AddLine("\n"..L["Addon Explanation Line 1"], 1, 1, 1, true);
	GameTooltip:AddLine("\n"..L["Addon Explanation Line 2"], 0.25, 0.78, 0.92, true);
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
	self.showingTooltip = true;
end

function DarkenSwitchButton_OnClick(self)
	AAASettings["Darken Background"] = not AAASettings["Darken Background"]

	if AAASettings["Darken Background"] == false then
		UIFrameFadeOut(Blackscreen, 0.5, Blackscreen:GetAlpha(), 0)
		self.ButtonName:SetTextColor(1,0,0);
		self.ButtonName:SetText(AAA_MENU_DISABLED);

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);

	elseif AAASettings["Darken Background"] == true then

		Blackscreen.Black:SetColorTexture(0,0,0,BlackscreenAlpha)
		UIFrameFadeIn(Blackscreen, 1, 0, 1)

		self.ButtonName:SetTextColor(0,1,0);
		self.ButtonName:SetText(AAA_MENU_ENABLED)

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function DarkenSwitchButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(AAA_MENU_DARKEN);
	GameTooltip:AddLine(L["DarkenButton Explanation Line 1"], 1, 1, 1, true);
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
	self.showingTooltip = true;
end

function PinStyleButton_OnClick(self)
	local Journal = AAA_Journal;
	if (not Journal.VirtualFrame.JournalTestBackground:IsShown()) then
		Journal.VirtualFrame.JournalTestBackground.animOut:Stop();
		Journal.VirtualFrame.JournalTestBackground:Show();
		Journal.VirtualFrame.JournalTestBackground.animIn:Play();
	end
	Journal.VirtualFrame.JournalPinButton.PinButtonUp:Hide();
	Journal.VirtualFrame.JournalPinButton.PinButtonDown:Show();
	Journal.VirtualFrame.JournalPinButton:SetAlpha(1);

	if (AAASettings["Pin Style"] ~= nil and AAASettings["Pin Style"] == 1) then
		AAASettings["Pin Style"] = 2;
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin2")
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin2")
		self.ButtonName:SetText(AAA_MENU_TAPE);
	elseif (AAASettings["Pin Style"] == 2) then
		AAASettings["Pin Style"] = 3;
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin3")
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin3")
		self.ButtonName:SetText(AAA_MENU_STAPLE);
	elseif (AAASettings["Pin Style"] == 3) then
		AAASettings["Pin Style"] = 1;
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin1")
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin1")
		self.ButtonName:SetText(AAA_MENU_PAPERCLIP);
	else
		AAASettings["Pin Style"] = 1;
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin1")
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:SetTexture("Interface\\AddOns\\AzerothAdventureAlbum\\ART\\Card\\Pin1")
		self.ButtonName:SetText(AAA_MENU_PAPERCLIP);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function PinStyleButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(AAA_MENU_PINSTYLE);
	GameTooltip:AddLine(L["PinStyleButton Explanation Line 1"], 1, 1, 1, true);
	GameTooltip:AddLine("\n"..L["PinStyleButton Explanation Line 2"], nil, nil, nil, true);
	GameTooltip:AddLine(AAA_MENU_PAPERCLIP..", "..AAA_MENU_TAPE..", "..AAA_MENU_STAPLE, 1, 1, 1, true);
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
	self.showingTooltip = true;	
end

function AAAScaleButton_OnClick(self)
	local scale = AAASettings["GlobalScale"];
	if scale == 1 then
		AAASettings["GlobalScale"] = 0.8;
		self.ButtonName:SetText(AAA_MENU_SCALE_SMALL);
	else
		AAASettings["GlobalScale"] = 1;
		self.ButtonName:SetText(AAA_MENU_SCALE_REGULAR);
	end

	GlobalScale = AAASettings["GlobalScale"];
	AAA_Journal:SetScale(GlobalScale);
	NightMode:SetScale(GlobalScale);
end

function AAAScaleButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(AAA_MENU_SCALE);
	GameTooltip:AddLine(L["ScaleButton Explanation Line 1"], 1, 1, 1, true);
	--GameTooltip:AddLine("\n"..L["ScaleButton Explanation Line 2"], nil, nil, nil, true);
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
end

function LittleThingsButton_OnClick(self)
	AAASettings["Little Things"]= not AAASettings["Little Things"];
	if (AAASettings["Little Things"] == false) then
		self.ButtonName:SetText(AAA_MENU_DISABLED);
		self.ButtonName:SetTextColor(1,0,0);
		if SnowContainer:IsShown() then
			SnowEffect(false)
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	elseif (AAASettings["Little Things"] == true) then
		self.ButtonName:SetText(AAA_MENU_ENABLED)
		self.ButtonName:SetTextColor(0,1,0);
		SnowEffect(true)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function LittleThingsButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(AAA_MENU_LITTLETHINGS);
	GameTooltip:AddLine(L["LittleThingsButton Explanation Line 1"], 1, 1, 1, true);
	GameTooltip:AddLine("\n"..L["LittleThingsButton Explanation Line 2"], nil, nil, nil, true);
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
	self.showingTooltip = true;
end

function MiniButton_OnClick(self)
	AAASettings["Minimap"] = not AAASettings["Minimap"];
	if (AAASettings["Minimap"] == false) then
		self.ButtonName:SetText(AAA_MENU_DISABLED);
		self.ButtonName:SetTextColor(1,0,0);

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	elseif (AAASettings["Minimap"] == true) then
		self.ButtonName:SetText(AAA_MENU_ENABLED)
		self.ButtonName:SetTextColor(0,1,0);

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	MinimapButton_Update();
end

function MiniButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(AAA_MENU_MINIMAPBUTTON);
	GameTooltip:AddLine(L["MinimapButton Explanation Line 1"], 1, 1, 1, true);
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
	self.showingTooltip = true;
end

function NightModeButton_OnClick(self)
	AAASettings["Night Mode"] = not AAASettings["Night Mode"]

	if (AAASettings["Night Mode"] == false) then
		self.ButtonName:SetText(AAA_MENU_DISABLED);
		self.ButtonName:SetTextColor(1,0,0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);

		if NightMode:IsShown() then
			NightMode:Hide()
		end

	elseif (AAASettings["Night Mode"] == true) then
		self.ButtonName:SetText(AAA_MENU_ENABLED)
		self.ButtonName:SetTextColor(0,1,0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		SetNightModeAlpha()
		NightMode:Show()
	end
end

function NightModeButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE",20, 0 );
	GameTooltip:SetText(AAA_MENU_NIGHTMODE);
	GameTooltip:AddLine(L["NightMode Explanation Line 1"], 1, 1, 1, true);
	GameTooltip:AddLine("\n"..L["NightMode Explanation Line 2"], nil, nil, nil, true);
	GameTooltip:AddLine("\n"..L["NightMode Explanation Special"], 0.25, 0.78, 0.92, true);  --Special Notification /RGB: Light Blue
	GameTooltip:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT", 4, 0)
	GameTooltip:Show()
	self.showingTooltip = true;
end

function UpdateMinimapSettings()
	local Journal = AAA_Journal;
	if (AAASettings["Minimap"]) then
		Journal.Settings.MiniButton.ButtonName:SetTextColor(0,1,0);
		Journal.Settings.MiniButton.ButtonName:SetText(AAA_MENU_ENABLED);
	else
		Journal.Settings.MiniButton.ButtonName:SetTextColor(1,0,0);
		Journal.Settings.MiniButton.ButtonName:SetText(AAA_MENU_DISABLED);
	end
end
--------------------------------------
------------Classification------------
--------------------------------------


function BuildSubList(filterChoice, list)
	local SubList = {};
	local j = 1;
	if (filterChoice == nil) then
		SubList = list
		for i=1, #list, 1 do
			list[i]["RealNumber"] = i;
			SubList[i]["RealNumber"] = i;
		end
		return SubList
	else
		for i=1,#list,1 do
			if (list[i]["mapID"] == filterChoice) then
				SubList[j] = list[i];
				SubList[j]["RealNumber"] = i;
				j = j + 1;
			elseif (filterChoice == 862 and list[i]["mapID"] == 1165) then
				SubList[j] = list[i];
				SubList[j]["RealNumber"] = i;
				j = j + 1;
			elseif (filterChoice == 895 and list[i]["mapID"] == 1161) then
				SubList[j] = list[i];
				SubList[j]["RealNumber"] = i;
				j = j + 1;
			end	
		end
		return SubList
	end
end

local function PlayShelfScrollAnimation()
	local Journal = AAA_Journal;
	for i=1, #Journal.ListScrollFrame2.buttons do
		--Journal.ListScrollFrame2.buttons[i].FakeScroll.animIn:Play();
		Journal.ListScrollFrame2.buttons[i].Scroll:SetTexCoord(0, 0.1416015625, 0, 0.283203125)
		Journal.ListScrollFrame2.buttons[i].DescriptionClipper:SetClipsChildren(true)
		Journal.ListScrollFrame2.buttons[i].DescriptionClipper:SetHeight(0)
		Journal.ListScrollFrame2.buttons[i].VirtualSwitch.animIn:Play();
	end
end

function AAA_ShowPanel()
	AAASwitch:Show();
	local Journal = AAA_Journal;
	local animationDuration = 0.3;
	local ag = Journal:CreateAnimationGroup();
	local a2 = ag:CreateAnimation("Alpha");

	a2:SetFromAlpha(0);
	a2:SetDuration(animationDuration);
	a2:SetToAlpha(1);	

	ag:SetScript("OnPlay", function()
		Journal:Show()
		PlayShelfScrollAnimation()
		Journal.ListScrollFrame2:Show()
		Journal:SetScale(AAASettings["GlobalScale"])
	end);
	ag:SetScript("OnFinished", function()
		Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:Show();
		--AAA_Shelf_Update();
		AAA_UpdateAllProgressBar();
	end);
	ag:Play();
	
end

function AAA_HidePanel() --self
	AAASwitch:Hide();
	local Journal = AAA_Journal;
	local animationDuration = 0.3;
	local ag = Journal:CreateAnimationGroup();
	local a1 = ag:CreateAnimation("Translation");
	local a2 = ag:CreateAnimation("Alpha");

	a1:SetOffset(0,-30); 
	a1:SetDuration(animationDuration);
	a1:SetSmoothing("OUT");

	a2:SetFromAlpha(1);
	a2:SetStartDelay(0.1)
	a2:SetDuration(animationDuration);
	a2:SetToAlpha(0);	

	ag:SetScript("OnPlay", function()
		Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:Hide();
	end);

	ag:SetScript("OnFinished", function()
		--Journal:Hide();
		--Journal.ListScrollFrame2:Hide()
		DoEmote("Read", "none")
		Journal:SetScale(0.0001)
		Journal.Filter:Hide(); --self:GetParent():Hide();
		Journal.Settings:Hide();
	end);
	ag:Play();
end

function TextBottomBorder()
	local Journal = AAA_Journal;
	local textHeight_Lore = 56 + Round(Journal.VirtualFrame.JournalTestBackground.Lore:GetHeight());
	Journal.VirtualFrame.JournalTestBackground.LoreBackground:SetHeight(textHeight_Lore);
end

function JournalDisplay_OnEnter()
	local Journal = AAA_Journal;
	if (Journal.selectedID ~= nil and (not Journal.VirtualFrame.JournalTestBackground:IsShown()) ) then
		Journal.VirtualFrame.JournalTestBackground.animOut:Stop();
		Journal.VirtualFrame.JournalTestBackground:Show();
		Journal.VirtualFrame.JournalTestBackground.animIn:Play();
	end
end

function JournalDisplay_OnLeave()
	local Journal = AAA_Journal;
	if (Journal.selectedID ~= nil and (not Journal.VirtualFrame.JournalPinButton.PinButtonDown:IsShown()) ) then
		Journal.VirtualFrame.JournalTestBackground.animIn:Stop();
		Journal.VirtualFrame.JournalTestBackground.animOut:Play();
	end
end

--Derivative from Blizzard: HybridScrollFrame_CreateButtons

local function HybridScrollFrame_CreateButtonsT (self, buttonTemplate, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	local scrollChild = self.scrollChild;
	local button, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	initialPoint = initialPoint or "TOPLEFT";
	initialRelative = initialRelative or "TOPLEFT";
	point = point or "TOPLEFT";
	relativePoint = relativePoint or "BOTTOMLEFT";
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if ( self.buttons ) then
		buttons = self.buttons;
		buttonHeight = buttons[1]:GetHeight();
	else
		button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, scrollChild, buttonTemplate);
		buttonHeight = button:GetHeight();
		button:SetPoint(initialPoint, scrollChild, initialRelative, initialOffsetX, initialOffsetY);
		buttons = {}
		tinsert(buttons, button);
	end

	self.buttonHeight = Round(buttonHeight) - offsetY;

	local numButtons = math.ceil(self:GetHeight() / buttonHeight) + 1;

	for i = #buttons + 1, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, scrollChild, buttonTemplate);
		button:SetPoint(point, buttons[i-1], relativePoint, offsetX, offsetY);
		tinsert(buttons, button);
	end

	scrollChild:SetWidth(self:GetWidth())
	scrollChild:SetHeight(numButtons * buttonHeight);
	self:SetVerticalScroll(0);
	self:UpdateScrollChildRect();

	self.buttons = buttons;
	local scrollBar = self.scrollBar;
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar.buttonHeight = buttonHeight;
	scrollBar:SetValueStep(buttonHeight);
	scrollBar:SetStepsPerPage(numButtons - 2);
	scrollBar:SetValue(0);

end


local function HybridScrollFrame_UpdateT (self, totalHeight, displayedHeight)
	local range = floor(totalHeight - self:GetHeight() + 0.5);
	if ( range > 0 and self.scrollBar ) then
		local minVal, maxVal = self.scrollBar:GetMinMaxValues();
		if ( math.floor(self.scrollBar:GetValue()) >= math.floor(maxVal) ) then
			self.scrollBar:SetMinMaxValues(0, range)
			if ( math.floor(self.scrollBar:GetValue()) ~= math.floor(range) ) then
				self.scrollBar:SetValue(range);
			else
				HybridScrollFrame_SetOffset(self, range);
			end
		else
			self.scrollBar:SetMinMaxValues(0, range)
		end
		self.scrollBar:Enable();
		HybridScrollFrame_UpdateButtonStates(self);
		self.scrollBar:Show();
	elseif ( self.scrollBar ) then
		self.scrollBar:SetValue(0);
		if ( self.scrollBar.doNotHide ) then
			self.scrollBar:Disable();
			self.scrollUp:Disable();
			self.scrollDown:Disable();
			self.scrollBar.thumbTexture:Hide();
		else
			self.scrollBar:Hide();
		end
	end

	self.range = range;
	self.totalHeight = totalHeight;
	self.scrollChild:SetHeight(displayedHeight);
	self:UpdateScrollChildRect();
end

local function HybridScrollFrame_Update_Horizontal(self, totalWidth, displayedWidth)
	--self.buttonHeight=0.01
	local range = floor(totalWidth - self:GetWidth() + 0.5);
	if ( range > 0 and self.scrollBar ) then
		local minVal, maxVal = self.scrollBar:GetMinMaxValues();
		if ( math.floor(self.scrollBar:GetValue()) >= math.floor(maxVal) ) then
			self.scrollBar:SetMinMaxValues(0, range)
			if ( math.floor(self.scrollBar:GetValue()) ~= math.floor(range) ) then
				self.scrollBar:SetValue(range);
			else
				HybridScrollFrame_SetOffset_Horizontal(self, range);
			end
		else
			self.scrollBar:SetMinMaxValues(0, range)
		end
		self.scrollBar:Enable();
		HybridScrollFrame_UpdateButtonStates(self);
		self.scrollBar:Show();
	elseif ( self.scrollBar ) then
		self.scrollBar:SetValue(0);
		if ( self.scrollBar.doNotHide ) then
			self.scrollBar:Disable();
			self.scrollUp:Disable();
			self.scrollDown:Disable();
			self.scrollBar.thumbTexture:Hide();
		else
			self.scrollBar:Hide();
		end
	end

	self.range = range;
	self.totalWidth = totalWidth;
	self.scrollChild:SetWidth(displayedWidth);
	self:UpdateScrollChildRect();
end

function HybridScrollFrame_OnValueChangedT(self, value)
	HybridScrollFrame_SetOffset(self:GetParent(), value);
	HybridScrollFrame_UpdateButtonStates(self:GetParent(), value);
end

function HybridScrollFrame_OnValueChanged_Horizontal(self, value)
	HybridScrollFrame_SetOffset_Horizontal(self:GetParent(), value);
	HybridScrollFrame_UpdateButtonStates(self:GetParent(), value);
	local Journal = AAA_Journal;
	if (Journal.ListScrollFrame2.scrollBar.UpButton:IsEnabled()) then
		UIFrameFadeIn(Journal.ListScrollFrame2.scrollBar.LeftOverlay,0.15,0,1);
	else
		UIFrameFadeOut(Journal.ListScrollFrame2.scrollBar.LeftOverlay,0.15,1,0);
	end
	if (Journal.ListScrollFrame2.scrollBar.DownButton:IsEnabled()) then
		UIFrameFadeIn(Journal.ListScrollFrame2.scrollBar.RightOverlay,0.15,0,1);
	else
		UIFrameFadeOut(Journal.ListScrollFrame2.scrollBar.RightOverlay,0.15,1,0);
	end
end


function HybridScrollFrame_SetOffset_Horizontal(self, offset)
	local buttons = self.buttons
	local buttonWidth = self.buttonWidth;
	local element, overflow;

	local scrollWidth = 0;

	local largeButtonTop = self.largeButtonTop
	if ( self.dynamic ) then --This is for frames where buttons will have different heights
		if ( offset < buttonWidth ) then
			-- a little optimization
			element = 0;
			scrollWidth = offset;
		else
			element, scrollWidth = self.dynamic(offset);
		end
	elseif ( largeButtonTop and offset >= largeButtonTop ) then
		local largeButtonWidth = self.largeButtonWidth;
		-- Initial offset...
		element = largeButtonTop / buttonWidth;

		if ( offset >= (largeButtonTop + largeButtonWidth) ) then
			element = element + 1;

			local leftovers = (offset - (largeButtonTop + largeButtonWidth) );

			element = element + ( leftovers / buttonWidth );
			overflow = element - math.floor(element);
			scrollWidth = overflow * buttonWidth;
		else
			scrollWidth = math.abs(offset - largeButtonTop);
		end
	else
		element = offset / buttonWidth;
		overflow = element - math.floor(element);
		scrollWidth = overflow * buttonWidth;
	end

	if ( math.floor(self.offset or 0) ~= math.floor(element) and self.update ) then
		self.offset = element;
		self:update();
	else
		self.offset = element;
	end

	self:SetHorizontalScroll(scrollWidth);
end
--------------------------------------------------------------------

function JournalButton_OnEnter(self)
	if ( self.Description:IsTruncated() ) then
		local buttonNumber = tonumber(self.buttonNumber:GetText());

		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip:SetText(self.Description:GetText() , 1, 1, 1, 1, true);
		self.showingTooltip = true;
	end
end

function AAA_PinButton_OnEnter(self)
	local Journal = AAA_Journal;
	if Journal.VirtualFrame.JournalTestBackground:IsShown() then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT",0,-10);
		if (Journal.VirtualFrame.JournalPinButton.PinButtonDown:IsShown() ) then
			GameTooltip:SetText(PIN_TOOLTIP_DISABLE);
		else
			GameTooltip:SetText(PIN_TOOLTIP_ENABLE);
			if (not Journal.VirtualFrame.JournalPinButton.PinButtonUp:IsShown() ) then
				Journal.VirtualFrame.JournalPinButton.PinButtonUp:Show();
			end
		end
		self.showingTooltip = true;
	end
end

function VirtualButton_OnEnter(self)
 self:GetParent().BackButton.Background:Show();
 self:GetParent().CloseButton.Background:Show();
end

function VirtualButton_OnLeave(self)
	self:GetParent().BackButton.Background:Hide();
	self:GetParent().CloseButton.Background:Hide();
end

function AAA_BackButton_OnClick(self)
	local Journal = AAA_Journal;
	Journal.Filter:Hide();
	Journal.Settings:Hide();
	ShowShelf();
end

function AAA_BackButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT",0,15);
	GameTooltip:SetText(BUTTON_TOOLTIP_BACK );
	self.showingTooltip = true;
	--Journal.VirtualButton:Disable();
end

function AAA_PinButton_OnClick(self)
	PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
	local Journal = AAA_Journal;
	if (not Journal.VirtualFrame.JournalPinButton.PinButtonDown:IsShown() ) then
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:Show();
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:Hide();
	else
		Journal.VirtualFrame.JournalPinButton.PinButtonDown:Hide();
		Journal.VirtualFrame.JournalPinButton.PinButtonUp:Show();
	end
	AAA_PinButton_OnEnter(self);
end

lastbuttonNumber = lastbuttonNumber or 0 --avoid double-click

function JournalButton_OnClick(self)
	local Journal = AAA_Journal;
	Journal.Filter:Hide();
	Journal.Settings:Hide();

	local buttonNumber = tonumber(self.buttonNumber:GetText());
	if (buttonNumber ~= nil and buttonNumber ~= lastbuttonNumber) then
		lastbuttonNumber = buttonNumber;
		Journal.selectedID = buttonNumber;
		--local destination = Journal.VirtualFrame;	
		Journal.VirtualFrame.JournalTestBackground.Source:SetText(CurrentAlbum[buttonNumber]["Location"]);
		local OldTopLayerTeture = Journal.VirtualFrame.JournalDisplayTopLayer.Display:GetTexture();
		--Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:SetTexture(Journal.VirtualFrame.JournalDisplayTopLayer.Display:GetTexture());
		if (CurrentAlbum[buttonNumber]["Status"]) then
			Journal.VirtualFrame.JournalTestBackground.Lore:SetText(CurrentAlbum[buttonNumber]["Lore"]);
			Journal.VirtualFrame.JournalDisplayTopLayer.Display:SetTexture(CurrentAlbum[buttonNumber]["Image"]);
		else
			Journal.VirtualFrame.JournalTestBackground.Lore:SetText(CARD_LORE_LOCKED);
			Journal.VirtualFrame.JournalDisplayTopLayer.Display:SetTexture(CurrentAlbum[buttonNumber]["Image-faded"]);
		end
		Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:SetTexture(OldTopLayerTeture)
		Journal.VirtualFrame.JournalDisplayTopLayer.animIn:Play();

		TextBottomBorder();
		local temp = Journal.ListScrollFrame.scrollBar:GetValue();
		Journal.ListScrollFrame.scrollBar:SetValue(72)
		Journal.ListScrollFrame.scrollBar:SetValue(temp)
		Journal_UpdateList();
	end
end



animationDone = true;
function HybridScrollFrame_OnMouseWheel_Horizontal (self, delta, stepSize)
	if ( not self.scrollBar:IsVisible() ) then
		return;
	end

	local minVal, maxVal = 0, self.range;
	local stepSize = stepSize or self.stepSize or self.buttonWidth;
	local Current = self.scrollBar:GetValue();
	self.scrollBar:SetValueStep(0.01);

	----------------------------------------	
	---Smoothing Animation for ScrollList---
	----------------------------------------
	local Journal = AAA_Journal;
	local animationDuration = 0.3;
	local ag = Journal.ListScrollFrame2.ScrollChild:CreateAnimationGroup();

	if (animationDone) then
		local a1 = ag:CreateAnimation("Translation")
		if ( delta == 1 ) then
			a1:SetOffset(-(-self.scrollBar:GetValue() + max(minVal, self.scrollBar:GetValue() - stepSize)),0); 
		else
			a1:SetOffset(-(-self.scrollBar:GetValue() + min(maxVal, self.scrollBar:GetValue() + stepSize)),0);
		end
		
		ag:SetScript("OnFinished", function()
			if ( delta == 1 ) then
				self.scrollBar:SetValue(max(minVal, self.scrollBar:GetValue() - stepSize));
			else
				self.scrollBar:SetValue(min(maxVal, self.scrollBar:GetValue() + stepSize));
			end
				animationDone = true;
			end)

			ag:SetScript("OnPlay", function()
				animationDone = false;
			end)
	
		a1:SetDuration(animationDuration)
		a1:SetSmoothing("OUT")
		ag:Play()
	end
end

function HybridScrollFrame_OnMouseWheelT (self, delta, stepSize)
	if ( not self.scrollBar:IsVisible() ) then
		return;
	end

	local minVal, maxVal = 0, self.range;
	local stepSize = stepSize or self.stepSize or self.buttonHeight;
	local Current = self.scrollBar:GetValue();
	self.scrollBar:SetValueStep(0.01);

	if ( delta == 1 ) then
		self.scrollBar:SetValue(max(minVal, self.scrollBar:GetValue() - stepSize));
	else
		self.scrollBar:SetValue(min(maxVal, self.scrollBar:GetValue() + stepSize));
	end
end

----------------------------------------	
---Smoothing Animation for ScrollList---
----------------------------------------
local SmoothScrollFactors = {};
SmoothScrollFactors.minVal = 0;
SmoothScrollFactors.maxVal = 0;
SmoothScrollFactors.stepSize = 0;
SmoothScrollFactors.delta = 0;
SmoothScrollFactors.animationDuration = 0;
SmoothScrollFactors.EndValue = 0;

local SmoothScrollContainer = CreateFrame("Frame");
SmoothScrollContainer:SetScript("OnShow", function()
	--print("SmoothScrollContainer Shown");
	local Journal = AAA_Journal;
	SmoothScrollFactors.EndValue = AAA_Journal.ListScrollFrame.scrollBar:GetValue()
end);

SmoothScrollContainer:Hide();

SmoothScrollContainer:SetScript("OnUpdate", function(self, elapsed)
	local Journal = AAA_Journal;
	local delta = SmoothScrollFactors.delta;
	local scrollBar = Journal.ListScrollFrame.scrollBar
	local speed = math.abs(scrollBar:GetValue() - SmoothScrollFactors.EndValue)/5;

	if ( delta == 1 ) then
		scrollBar:SetValue(max(0, scrollBar:GetValue() - speed));
	else
		scrollBar:SetValue(min(SmoothScrollFactors.maxVal, scrollBar:GetValue() + speed));
	end

	if SmoothScrollFactors.animationDuration >= 2 or speed<= 0.25 then
		--print(SmoothScrollFactors.animationDuration)
		--SmoothScrollFactors.animationDuration = 0;
		scrollBar:SetValue(min(SmoothScrollFactors.maxVal, SmoothScrollFactors.EndValue));
		SmoothScrollContainer:Hide();
	end
end);

function SmoothScroll_OnMouseWheel(self, delta, stepSize)
	if ( not self.scrollBar:IsVisible() ) then
		return;
	end
	--SmoothScrollFactors.animationDuration = 0;
	SmoothScrollFactors.maxVal = self.range;
	
	local stepSize = stepSize or self.stepSize or self.buttonHeight;
	SmoothScrollFactors.stepSize = stepSize;
	local Current = self.scrollBar:GetValue();
	self.scrollBar:SetValueStep(0.01);
	SmoothScrollFactors.delta = delta;

	--print(SmoothScrollFactors.delta.." Range= "..SmoothScrollFactors.maxVal.." StepSize= "..SmoothScrollFactors.stepSize)
	if not((Current == 0 and delta > 0) or (Current == self.range and delta < 0 )) then
		SmoothScrollContainer:Show()
	end
	SmoothScrollFactors.EndValue = min(max(0, SmoothScrollFactors.EndValue - delta*SmoothScrollFactors.stepSize), SmoothScrollFactors.maxVal)
end
----------------------------------------

function Journal_OnLoad(self)
	local Journal = AAA_Journal;
	self.ListScrollFrame.scrollBar:Hide();
	self.ListScrollFrame.update = Journal_UpdateList;
	HybridScrollFrame_CreateButtonsT(self.ListScrollFrame, "ButtonTemplate", 20, 0, nil, nil, 0, 0);
	Journal.selectedID = nil;
	self.ListScrollFrame.scrollBar.thumbTexture:SetHeight(Round(470*7/30))
	HybridScrollFrame_CreateButtons_Horizontal(self.ListScrollFrame2, "ShelfTemplate", 0, 0, nil, nil, 0, 0);

	self:SetScale(0.0001)
	Journal.JournalBottomPanel.FilterButton:Disable();
end

local InitialProgress = CreateFrame("Frame");
InitialProgress:RegisterEvent("PLAYER_ENTERING_WORLD")
InitialProgress:SetScript("OnEvent",function(self,event,...)
	if event == "PLAYER_ENTERING_WORLD" then
		AAA_GetTotalProgress();
		AAA_Shelf_Update();
	end
end)

--[[
function Journal_OnShow(self)
	GetDate();
	EnableNightMode();
	PlaySound(MENU_OPENSOUND, "Master");

	--ConsoleExec( "RenderScale 0.5" );
	Blackscreen.animOut:Stop();
	Blackscreen:Show();
	Blackscreen.animIn:Play();

	--determine whether intro page pops up or not. 
	--only pops up once for each login (see LoadProgress.lua)
	if (AAASettings["Intro Switch"]) then -- or true
		--InitializeIntroPage()
		IntroFrame.animIn:Play();
		AAASettings["Current Version"] = AAA_MENU_VERSION_NUMBER
		AAASettings["Intro Switch"] = false;
	end

	if (self:IsVisible()) then
		if (filterChoice == nil) then
			Journal_UpdateList();
		end
	end
	--AAA_Shelf_Update();
	AAA_MinimapButton.Color:Show();
end


function Journal_OnHide(self)
	Blackscreen.animIn:Stop();
	Blackscreen.animOut:Play();

	if NightMode:IsShown() then
		NightMode.animIn:Stop();
		NightMode.animOut:Play();
	end

	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_CLOSE);
	Journal.VirtualFrame.JournalTestBackground.animOut:Stop();
	Journal.Filter:Hide();
	Journal.Settings:Hide();
	AAA_MinimapButton.Color:Hide();
	Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:Hide();
	IntroFrame:Hide();
end
--]]

function AAASwitch_OnShow(self)
	AAA_GetDate();
	EnableNightMode();
	SnowEffect(true)

	PlaySound(MENU_OPENSOUND, "Master");
	Blackscreen.Black:SetColorTexture(0,0,0,BlackscreenAlpha)
	UIFrameFadeIn(Blackscreen, 1, 0, 1)
	--determine whether intro page pops up or not. 
	--only pops up once for each login (see LoadProgress.lua)

	
	if (AAASettings["Intro Switch"]) then -- or true
		IntroFrame:Show()
		IntroFrame:SetScale(0.0001)
		C_Timer.After(1, function()
			IntroFrame:SetScale(AAASettings["GlobalScale"])
			IntroFrame.animIn:Play();
		end)
		--IntroFrame.animIn:Play();
		AAASettings["Current Version"] = AAA_MENU_VERSION_NUMBER
		AAASettings["Intro Switch"] = false;
	end
	

	if (self:IsVisible()) then
		if (filterChoice == nil) then
			Journal_UpdateList();
		end
	end
	
	AAA_MinimapButton.Color:Show();
	AAA_MinimapButton.ShadowGradient:Show();
end

function AAASwitch_OnHide(self)
	local Journal = AAA_Journal;
	SnowEffect(false)
	UIFrameFadeOut(Blackscreen, 0.5, Blackscreen:GetAlpha(), 0)
	
	if NightMode:IsShown() then
		NightMode.animIn:Stop();
		NightMode.animOut:Play();
	end

	PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_CLOSE);
	Journal.VirtualFrame.JournalTestBackground.animOut:Stop();
	Journal.Filter:Hide();
	Journal.Settings:Hide();
	AAA_MinimapButton.Color:Hide();
	AAA_MinimapButton.ShadowGradient:Hide();
	Journal.VirtualFrame.JournalDisplay.DisplayBottomLayer:Hide();
	IntroFrame:Hide();
	AAA_HidePanel();
end





function Journal_UpdateList()
	local Journal = AAA_Journal;
	local scrollFrame = Journal.ListScrollFrame;
	
	SetThumbTextureHeight()
	if (sub_Num~=nil and sub_Num > 7) then --change the thumb texture height when using the map filter
		Journal.ListScrollFrame.scrollBar.thumbTexture:SetHeight(470*7/sub_Num);
	elseif (sub_Num~=nil and sub_Num == 7) then
		Journal.ListScrollFrame.scrollBar.thumbTexture:SetHeight(470*7/9);
	end
	
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	CurrentAlbum = CurrentAlbum or Travel
	TravelSub = BuildSubList(filterChoice, CurrentAlbum);

	local numList = #TravelSub;
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numList ) then
			local index = displayIndex;
			button.Title:SetText("Test Title"..displayIndex);
			button.Description:SetText("Test Description"..displayIndex);
			button.icon:SetTexture(133975 + displayIndex)
			button.active = active;
			button.buttonNumber:SetText(tostring(TravelSub[displayIndex]["RealNumber"]));
			if(TravelSub[displayIndex]["RealNumber"] == Journal.selectedID) then
				button.selectedTexture:Show();
			else
				button.selectedTexture:Hide();	
			end

			if( TravelSub[displayIndex] ~= nil ) then
				
				button.Title:SetText(TravelSub[displayIndex]["Title"]);
				button.Description:SetText(TravelSub[displayIndex]["Description"]);
				button.icon:SetTexture(TravelSub[displayIndex]["Icon"]);
				if (TravelSub[displayIndex]["Status"]) then
					button.Background:SetDesaturated(false);
					button.icon:SetDesaturated(false);
					button.ButtonHighlight:SetDesaturated(false);
					button.Overlay:SetDesaturated(false);
					button.Title:SetTextColor(1,0.8,0)
				else
					button.Background:SetDesaturated(true);
					button.icon:SetDesaturated(true);
					button.ButtonHighlight:SetDesaturated(true);
					button.Overlay:SetDesaturated(true);
					button.Title:SetTextColor(1,1,1);
				end
			else
				button.Title:SetTextColor(1,1,1);
				button.Title:SetText("Test Title");
				button.Description:SetText("This is a description.");
				button.icon:SetTexture(236452);
				button.Background:SetDesaturated(true);
				button.icon:SetDesaturated(true);
				button.ButtonHighlight:SetDesaturated(true);
				button.Overlay:SetDesaturated(true);
			end

			button:Show();
			button:SetEnabled(true);
		else
			button:Hide();
			button:SetEnabled(false);
		end
	end
	local totalHeight = numList * buttons[1]:GetHeight();
	HybridScrollFrame_UpdateT(scrollFrame, totalHeight, scrollFrame:GetHeight());
end

function AAA_EnableShelf()
	local Journal = AAA_Journal;
	for i=1, (#Journal.ListScrollFrame2.buttons - 2) do
		Journal.ListScrollFrame2.buttons[i]:Enable()
	end
end

function AAA_DisableShelf()
	local Journal = AAA_Journal;
	for i=1, (#Journal.ListScrollFrame2.buttons -2) do
		Journal.ListScrollFrame2.buttons[i]:Disable()
	end
end

function AAA_UpdateAllProgressBar()
	local Journal = AAA_Journal;
	local scrollFrame = Journal.ListScrollFrame2;
	local buttons = scrollFrame.buttons;
	for i=1, #buttons do
		UpdateShelfProgressBar(buttons[i]);
	end
end

function AAA_Shelf_Update()
	local Journal = AAA_Journal;
	local scrollFrame = Journal.ListScrollFrame2;
	
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numList = 4;

	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numList ) then
			local index = displayIndex;
			button.buttonNumber = index;
			--button.FakeScroll.animIn.Translation:SetStartDelay(index/10)
			button.VirtualSwitch.animIn.Translation:SetStartDelay(index/10)
			button.Title:SetText(Shelf[index]["Title"]);
			button.DescriptionClipper.Description:SetText(Shelf[index]["Description"]);
			local textureFile = "Interface/AddOns/AzerothAdventureAlbum/Art/Animations/BookCover"..index;
			button.AnimCover:SetTexture(textureFile);
			button.StatusBar:SetColorTexture(Shelf[index]["BarColor"]["r"],Shelf[index]["BarColor"]["g"],Shelf[index]["BarColor"]["b"],0.6)
			UpdateShelfProgressBar(button);

			if (Shelf[index]["Status"]) then
				button.active = active;
				button:Show();
				button:SetEnabled(true);
			else
				button:Disable();
				button.AnimCover:SetDesaturated(true);
				button.Scroll:SetDesaturated(true);
				button.StatusBar:SetDesaturated(true);
				button.Title:SetTextColor(1,1,1);
			end
		else
			button:Hide();
			button:SetEnabled(false);
		end
	end
	local totalWidth = numList * buttons[1]:GetWidth();
	HybridScrollFrame_Update_Horizontal(scrollFrame, totalWidth, scrollFrame:GetWidth());
end

-----------------------
------Intro Frame------
-----------------------
function Intro_OnLoad(self)
	tinsert(UISpecialFrames, self:GetName());
end

function InitializeIntroPage()
	local CalendarTime = C_Calendar.GetDate();
	local year = CalendarTime.year;
	--print("year=="..year)
	local imageIndex;
	if (AAASettings["Current Version"] < AAA_MENU_VERSION_NUMBER) then
		imageIndex = 0;
		AAASettings["Current Version"] = AAA_MENU_VERSION_NUMBER;
	else
		imageIndex = 0;
		AAASettings["Intro Switch"] = false;
	end

	IntroFrame.image.Background:SetTexture(IntroList[imageIndex]["Image"]);
	
	if IntroList[imageIndex]["Title"] ~= nil then
		IntroFrame.image.Title:SetText(IntroList[imageIndex]["Title"]);
	else
		IntroFrame.image.Title:SetText("");
		IntroFrame.image.Title:Hide();
	end
	if IntroList[imageIndex]["SubTitle"] ~= nil then
		--IntroFrame.image.SubTitle:SetText(IntroList[imageIndex]["SubTitle"][1]);
	else
		IntroFrame.Button1:Hide()
		IntroFrame.Button2:Hide()
		IntroFrame.Button3:Hide()
		--IntroFrame.image.SubTitle:SetText("");
	end
	
	if IntroList[imageIndex]["Description"] ~= nil then
		IntroFrame.image.Description:SetText(IntroList[imageIndex]["Description"]);
		IntroFrame.image.Dividing:SetWidth(IntroFrame.image.Description:GetWidth() + 10)
		IntroFrame.image.Dividing:Show();
	else
		IntroFrame.image.Description:SetText("");
		IntroFrame.image.Dividing:Hide();
	end
	
end


--------------------------------------
--------------Animations--------------
--------------------------------------

local AnimSequenceInfo = {
	["Scroll"] = {
		 ["TotalFrames"] = 21,
		 ["cX"] = 0.1416015625,
		 ["cY"] = 0.283203125,
		 ["Column"] = 7,
		 ["Row"] = 3	
	},

	["BookCover"] = {
		["TotalFrames"] = 22,
		["cX"] = 0.14453125,
		["cY"] =  0.1826171875,
		["Column"] = 6,
		["Row"] = 5	
   },

}

local function InitializeAnimationContainer(frame, SequenceInfo, TargetFrame)
	frame.OppoDirection = false;
	frame.TimeSinceLastUpdate = 0
	frame.TotalTime = 0;
	frame.Index = 1;
	frame.Pending = false;
	frame.IsPlaying = false;	
	frame.SequenceInfo = SequenceInfo;
	frame.Target = TargetFrame
end

local function ScrollAnimation_OnHide(self)
	self.IsPlaying = false;
	self.TotalTime = 0;
	self.TimeSinceLastUpdate = 0;
	self.Index = 0;
end

local function AAAPlayAnimationSequence(index, SequenceInfo, Texture, direct)
	local Texture = Texture or PhotoModeControllerTransition.Sequence;
	local SequenceInfo = SequenceInfo or AnimSequenceInfo["Controller"];
	local Frames = SequenceInfo["TotalFrames"];
	local cX, cY = SequenceInfo["cX"], SequenceInfo["cY"];
	local Column, Row = SequenceInfo["Column"], SequenceInfo["Row"]

	if (index > Frames and not direct) or (index < 1 and direct) then
		return false;
	end

	local n = math.modf((index -1)/ Row) + 1;
	local m = index % Row
	if m == 0 then
		m = Row;
	end

	local left, right = (n-1)*cX, n*cX;
	local top, bottom = (m-1)*cY, m*cY;
	Texture:SetTexCoord(left, right, top, bottom);
	
	Texture:SetAlpha(1)
	return true;
end

local ASC1 = CreateFrame("Frame","AnimationSequenceContainer_ScrollDown");
ASC1:Hide();

local function UpdateDescriptionClipper(self, index)
	self:GetParent().DescriptionClipper:SetHeight((index-4)*10)
end

function AnimationSequence_SingleDirection_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate >= FrameGap then
		self.TimeSinceLastUpdate = 0;
		self.Index = self.Index + 1;
		UpdateDescriptionClipper(self,self.Index)
		if not AAAPlayAnimationSequence(self.Index, self.SequenceInfo, self.Target, false) then
			self:Hide()
			self:GetParent().DescriptionClipper:SetClipsChildren(false)
		end
	end
end

function AnimationSequence_Loop_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	
	if self.TimeSinceLastUpdate >= FrameGap then
		self.TimeSinceLastUpdate = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not AAAPlayAnimationSequence(self.Index, self.SequenceInfo, self.Target, self.OppoDirection) then
			self:Hide()
			return;
		end
	end

	--print(self.TimeSinceLastUpdate)
end

ASC1:SetScript("OnUpdate", AnimationSequence_SingleDirection_OnUpdate)
ASC1:SetScript("OnHide", ScrollAnimation_OnHide)
ASC1:SetScript("OnShow", function(self)
	self.IsPlaying = true;
end)

function AAA_ResetPosition(self, button)
	if button == "RightButton" then
		AAA_Journal:ClearAllPoints();
		AAA_Journal:SetPoint("CENTER", UIParent, "CENTER", 0 ,0);
		AAA_Journal:SetUserPlaced(false);
	end
end
