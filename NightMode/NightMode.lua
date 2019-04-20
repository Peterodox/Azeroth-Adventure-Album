--print("NightMode Loaded");
local GlobalScale = 1;

function AAA_GetDate()
	local month = date("%m")
	local day = date("/%d")
	local hour = date("%H")
	local minute = date("%M")
	month, day, hour, minute = tonumber(month), tonumber(day), tonumber(hour), tonumber(minute);

	if ( (hour >=23 or hour <=5) and (minute >= 0) )then
		MENU_OPENSOUND = (82664); --Owl
	else
		MENU_OPENSOUND = (SOUNDKIT.ACHIEVEMENT_MENU_OPEN);
	end
end

function SetNightModeAlpha()
	--Alpha - Time Relation +0.25/hour
	-- 0.25 - 21:00
	-- 1.00 - 00:00
	-- 1.00 - 03:00
	-- 0.25 - 06:00
	local CalendarTime = C_Calendar.GetDate();
	local hour = CalendarTime.hour;
	local minute = CalendarTime.minute;
	--print(hour..":"..minute)

	if ( (hour >= 21 or hour <= 5) and IsOutdoors() and AAASettings["Night Mode"]) then
		if hour >= 21 then
			NightMode.Black:SetAlpha(0.25 + 0.25*(hour + minute/60 - 21));
		elseif hour >= 0 and hour < 3 then
			NightMode.Black:SetAlpha(1);
		elseif hour >= 3 and hour <6 then
			NightMode.Black:SetAlpha(1 - 0.25*(hour + minute/60 - 3));
		end
		return true
	else
		return false
	end
end

function EnableNightMode()
	if SetNightModeAlpha() then
		NightMode.ImageMask:Show();
		NightMode.animOut:Stop();
		NightMode.animIn:Play();
	end
end

function NightMode_OnUpdate(self, elapsed)
	local scale = self:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale
	NightMode.ImageMask:SetPoint("CENTER", nil, "BOTTOMLEFT", x, y);
	NightMode.BorderMask:SetPoint("CENTER", NightMode.ImageMask, "CENTER", 0, 0);
	NightMode.CursorShadow:SetPoint("CENTER", NightMode.ImageMask, "CENTER", 12, -14);
end

function NightMode_OnShow(self)
	self:SetScale(AAASettings["GlobalScale"]);
	self.ImageMask.animIn:Play();
end