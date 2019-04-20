local function InitializeDB()
    AAASettings = AAASettings or {};
    AAASettings.Splash = AAASettings.Splash or {};
    AAASettings.Splash[2019] = AAASettings.Splash[2019] or false;
    AAASettings["Sound"] = AAASettings["Sound"] or true
    AAASettings["Darken Background"] = AAASettings["Darken Background"] or true
    if AAASettings["Minimap"] == nil then
        AAASettings["Minimap"] = true;
    end
    if AAASettings["Little Things"] == nil then
        AAASettings["Little Things"] = true;
    end
    if AAASettings["Night Mode"] == nil then
        AAASettings["Night Mode"] = true;
    end
    if AAASettings["Intro Switch"] == nil then
        AAASettings["Intro Switch"] = true;
    end
    AAASettings["MinimapAngle"] = AAASettings["MinimapAngle"] or 35
    AAASettings["Pin Style"] = AAASettings["Pin Style"] or 1
    AAASettings["Current Version"] = AAASettings["Current Version"] or 100
    AAASettings["Localization"] =  false --AAASettings["Localization"] --Change Me Later
    AAASettings["GlobalScale"] = AAASettings["GlobalScale"] or 1;
    Progress = Progress or {};
    Progress.Titans= Progress.Titans or {};
    Progress.TidesofV= Progress.TidesofV or {};

end

local LoadProgress = CreateFrame("Frame")

LoadProgress:RegisterEvent("VARIABLES_LOADED");

LoadProgress:SetScript("OnEvent",function(self,event,...)
    InitializeDB()

    for i=1, #Travel,1 do
        Progress[i] = Progress[i] or false;
        if (Travel[i]["Status"]) == false then
        Travel[i]["Status"] = Progress[i];
        end
    end

    for i=1, #Titans,1 do
        Progress.Titans[i] = Progress.Titans[i] or false;
        if (Titans[i]["Status"]) == false then
        Titans[i]["Status"] = Progress["Titans"][i];
        end
    end

    for i=1, #TidesofV,1 do
        Progress.TidesofV[i] = Progress.TidesofV[i] or false;
        if (TidesofV[i]["Status"]) == false then
        TidesofV[i]["Status"] = Progress["TidesofV"][i];
        end
    end
   ------------------------------------
   --Compensation for a bug in 1.3.1.--
   ---------DELETE THIS LATER!---------
   ------------------------------------
    if AAASettings["Current Version"] == 131 then
        Travel[7]["Status"] = true
        Progress[7] = true

        Travel[18]["Status"] = true
        Progress[18] = true
    elseif AAASettings["Current Version"] == 132 then
        Titans[4]["Status"] = true
        Progress.Titans[4] = true;
    end
end)



local SetIntro = CreateFrame("Frame")

SetIntro:RegisterEvent("PLAYER_ENTERING_WORLD");
SetIntro:RegisterEvent("PLAYER_LOGOUT");

SetIntro:SetScript("OnEvent",function(self,event,...)
    if event == "PLAYER_ENTERING_WORLD" then
        if AAASettings["Intro Switch"] then
            --print("Show Intro");
            --AAASettings["Intro Switch"] = false;
        else
            --print("false")
        end
    elseif event == "PLAYER_LOGOUT" then
        AAASettings["Intro Switch"] = true;
    end
        
end)

    