local CheckList = {};

local function GetPlayerFaction()
    local playerFaction, _ = UnitFactionGroup("player")
    return  playerFaction
end
playerFaction = GetPlayerFaction()

local mapID_Temp, mapID
local mapType, mapInfo
local gossipHasClosed = false;
local gossipOption = 0;
--------------------------------------
-----------Build Notification---------
--------------------------------------
local function SetNotificationCard(CardID, Album)
    AAA_AlertFrameSystems_Register();
        
    JournalNotification.Title:SetText(Album[CardID]["Title"]);
    JournalNotification.Background:SetTexCoord(0.27734375,0.77734375,0.27734375,0.4033203125)
    JournalNotification.Background:SetTexture(Album[CardID]["Image"]);
    JournalNotification.animIn:Play();

    JournalNotification:Show();
    JournalNotification.soundtrack = Album[CardID]["sound"] or nil;
    --print(JournalNotification.soundtrack)
    PlaySound(73280);
end
--------------------------------------


--------------------------------------
-----------Check Achievement----------
--------------------------------------
function AchievementListener_OnShow(self)
    self:RegisterEvent("ACHIEVEMENT_EARNED");
    self:SetScript("OnEvent", function(self, event, ...)
        local achievementID = ...;
        --print(achievementID)
       end);
end

function AchievementListener_OnHide(self)
    self:UnregisterAllEvents();
end

--------------------------------------
---------Check Target's npcID----------
--------------------------------------

function TargetnpcID_OnShow(self)
    self:RegisterEvent("PLAYER_TARGET_CHANGED");
    self:SetScript("OnEvent", function(self, event, ...)
        gossipHasClosed = false;        --if player has spoken to specific NPC but failed to meet the criteria. 
       end);

    --print("Check npcID: |cFF00FF00ON|r")
end

function TargetnpcID_OnHide(self)
    self:UnregisterAllEvents();
    --print("Check npcID: |cFFFF0000OFF|r")
end

local function CheckTargetnpcID(value)
    if value ~= nil and value ~= 0 then
        local targetGUID = UnitGUID("target")
        if targetGUID ~= nil then
            local type, _, _, _, _, npcID, _ = strsplit("-",targetGUID);
            npcID = tonumber(npcID)
            for i, v in ipairs(value) do
                if v == npcID then
                    return true;
                end
            end
        else
            return false;
        end
    elseif value ~= nil and value == 0  then
        return true;
    else
        return false;
    end
end

npcIDList={
    
    141127, --Simon UD
    143787, --flap-flap

}





--------------------------------------
------------Check Coordinate----------
--------------------------------------
--[[mapInfo :
    0 Cosmic            4 Dungeon
    1 World             5 Mirco
    2 Continent         6 Orphan
    3 Zone
/script mapInfo = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
/script print(mapInfo.mapType);

local FakeInstanceList = {
    -- Although mapType return "4 - dungeon", the player is not actually in any dungeon 
    -- Put such current mapID here **not the instanceMapID
    629, --The Portrait Room, Dalaran
    20, --Tyr's Tomb
    --936 Azshara's Palace, Well of Eternity
    --939 Courtyard of Lights, Well of Eternity 398
}


local function GetInstanceMapID()
    local _, _, difficultyID, _, _, _, _, instanceMapID, _ = GetInstanceInfo();
    --print(instanceMapID);
    return instanceMapID;
end

function isPlayerInInstance(mapID)
    for i, v in ipairs(FakeInstanceList) do
        if v == mapID then
            return false;
        else
            return true;
        end
    end
end
--]]
--/dump C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"));
local function AssignMapID()
    local BestMapForPlayer = C_Map.GetBestMapForUnit("player")
    if BestMapForPlayer ~= nil then
        local mapInfo = C_Map.GetMapInfo(BestMapForPlayer);
        mapID = BestMapForPlayer
        mapType = mapInfo.mapType
        --print("Type: "..mapType.." mapID= "..mapID)
        --[[
        if (mapType == 4  or mapType == 5)and isPlayerInInstance(BestMapForPlayer) then            --dungeon
            mapID = GetInstanceMapID();
            print("Player in Instance")
        --elseif mapType == 3 then                                                                 --zone
        --    mapID = BestMapForPlayer
        else
            mapID = BestMapForPlayer
            --mapID = GetInstanceMapID();
            --print(mapType.." Player in Instance？")
        end
        --]]
    end
end

local function GetPlayerPosition()
    local x, y, positionTable
    positionTable = C_Map.GetPlayerMapPosition(mapID, "player")

    if positionTable ~= nil then
        x, y = positionTable:GetXY();
    else
        x, y = 0, 0
    end

    return x, y
end

local function SaveSpecificProgress(CardID, AlbumID)
    if (AlbumID == 1) then
        if (not Travel[CardID]["Status"]) then
            SetNotificationCard(CardID, Travel)
            Progress[CardID] = true;              --turn this off so the progress won't be saved.
            Travel[CardID]["Status"] = true;
        end
    elseif (AlbumID == 2) then
        if (not Titans[CardID]["Status"]) then
            SetNotificationCard(CardID, Titans)
            Progress.Titans[CardID] = true;
            Titans[CardID]["Status"] = true;
        end
    elseif (AlbumID == 3) then
        if (not TidesofV[CardID]["Status"]) then
            SetNotificationCard(CardID, TidesofV)
            Progress.TidesofV[CardID] = true;
            TidesofV[CardID]["Status"] = true;
        end
    end

    TargetnpcID:Hide();
end

local function SaveProgress(index)
    CardID = CheckList[index]["CardID"];
    AlbumID = CheckList[index]["Album"];
    SaveSpecificProgress(CardID, AlbumID);
    AAA_Shelf_Update();
end

local function GetCheckListLength()
    if CheckList ~= nil then
    local i = 1;
    
    while (CheckList[i]["x1"] ~= nil) do
        i = i + 1;
    end
    return i-1
    else
        return 0
    end
end

local NoJ = 1;

local function LoadList(mapID, CheckList, Album, AlbumNumber) --Album = the name of the table
    for i = 1, #Album, 1 do
        if (Album[i]["mapID"] == mapID and (not Album[i]["Status"]) and Album[i]["x1"] ~= nil) then
            CheckList[NoJ]["CardID"] = i;
            CheckList[NoJ]["x1"] = Album[i]["x1"];
            CheckList[NoJ]["x2"] = Album[i]["x2"];
            CheckList[NoJ]["y1"] = Album[i]["y1"];
            CheckList[NoJ]["y2"] = Album[i]["y2"];
            CheckList[NoJ]["Album"] = AlbumNumber;
            CheckList[NoJ]["npcID"] = Album[i]["npcID"];
            CheckList[NoJ]["GossipOption"] = Album[i]["GossipOption"];
            CheckList[NoJ]["Faction"] = Album[i]["Faction"];
            NoJ = NoJ + 1;
        end
    end
end

local function RefreshCheckList(mapID)
    --print("Refreshed")
    GossipListener:Hide();

    CheckList = {
        [1]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [2]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [3]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [4]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [5]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [6]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [7]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [8]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [9]  = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [10] = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [11] = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
        [12] = {["Status"]=false, ["x1"]=nil, ["y1"]=nil, ["x2"]=nil, ["y2"]=nil, ["Album"]=nil, ["npcID"]=nil, ["GossipOption"]=nil, ["Faction"] = nil},
    };

    NoJ = 1;
    LoadList(mapID, CheckList, Travel, 1);
    LoadList(mapID, CheckList, Titans, 2);
    LoadList(mapID, CheckList, TidesofV, 3);
end


local CoordinateListener_totalTime = 0
local throttle, counter= 1, 0
local CoordinateListener = CreateFrame("Frame", "CoordinateListener", AAAEventsContainer, EventListenerTemplate)

CoordinateListener:SetScript("OnHide", function(self)
    --print(self:GetName()..": |cFFFF0000OFF|r")
end)
CoordinateListener:SetScript("OnShow", function(self)
    CoordinateListener_totalTime = 0
    --print((self:GetName()..": |cFF00FF00ON|r"))
end)
CoordinateListener:SetScript("OnUpdate", function(self, elapsed)
    counter = counter + elapsed
    if counter < throttle then
        return
    end
    counter = 0

    local x, y = GetPlayerPosition()
    

    if(mapID ~= mapID_Temp) then
        RefreshCheckList(mapID);        --ZONE_CHANGED event fires every time you enter a "subzone". But we only need to refresh the list when entering a new zone.
        mapID_Temp = mapID;
    end

    local CheckListLength = GetCheckListLength();
    if CheckListLength == 0 and mapType~=0 and mapType~=1 and mapType~=2 then
        self:Hide()
    end

    for i=1,CheckListLength,1 do
        --print(CheckList[i]["CardID"])
        if (not CheckList[i]["Status"] and (x > CheckList[i]["x1"] and x < CheckList[i]["x2"]) and (y > CheckList[i]["y1"]  and y < CheckList[i]["y2"]) ) then
            --print("Right Location")
            AAA_MinimapButton.Bling.animIn:Play();
            if CheckList[i]["npcID"] == nil then
                SaveProgress(i)
                RefreshCheckList(mapID)                             --refresh checklist after earning one
            else
                if CheckTargetnpcID(CheckList[i]["npcID"]) then       --if the criteria include npcID and target npcID = that npcID
                    --print("Right npcID")
                    if CheckList[i]["Faction"] == nil or playerFaction == CheckList[i]["Faction"] then    --the card is not faction-specific, or player match the faction
                        if  CheckList[i]["GossipOption"] == nil then                                      
                            SaveProgress(i);
                            RefreshCheckList(mapID)
                        elseif CheckList[i]["GossipOption"] == 0 then
                            GossipListener:Show();
                            if gossipHasClosed then
                                SaveProgress(i);
                                RefreshCheckList(mapID)
                                
                            end
                        else
                            GossipListener:Show();
                            if gossipHasClosed and gossipOption == CheckList[i]["GossipOption"] then
                                SaveProgress(i);
                                RefreshCheckList(mapID)
                                
                            end
                            --GossipOption CheckList[i]["GossipOption"]
                        end
                    else                                                                                  --If the faction doesn't match, just save
                        SaveProgress(i);
                        RefreshCheckList(mapID)                       
                    end
                end
            end

            CheckListLength = GetCheckListLength();
            break;
        end
    end    
end)

--------------------------------------
local ListenerTrigger = CreateFrame("Frame")

ListenerTrigger:RegisterEvent("ZONE_CHANGED");
ListenerTrigger:RegisterEvent("PLAYER_ENTERING_WORLD");
ListenerTrigger:RegisterEvent("ZONE_CHANGED_INDOORS")
ListenerTrigger:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ListenerTrigger:SetScript("OnEvent",function(self,event,...)
    --print(event)
    AssignMapID()
    --print(mapID.."/".. mapType)
    CoordinateListener:Show();
    GossipListener:Hide();
end)

-------------------------------------- this listener only triggers after player closes the gossip frame
---------Check Gossip Option---------- so the player won't be disturbed while reading the text
--------------------------------------


function GossipListener_OnLoad(self)
    gossipHasClosed = false
    hooksecurefunc('SelectGossipOption', function(index)
        if self:IsShown() then
            gossipOption = index
        end
    end)
end

function GossipListener_OnShow(self)
    TargetnpcID:Show();

    --print(self:GetName()..": |cFF00FF00ON|r")
    self:RegisterEvent("GOSSIP_SHOW");
    self:RegisterEvent("GOSSIP_CLOSED")
    self:RegisterEvent("ITEM_TEXT_CLOSED")
    self:SetScript("OnEvent", function(self, event, ...)
        --print(event)
        if event == "GOSSIP_CLOSED" or "ITEM_TEXT_CLOSED" then
            gossipHasClosed = true
        end
       end);
end

function GossipListener_OnHide(self)
    self:UnregisterAllEvents();
    --print(self:GetName()..": |cFFFF0000OFF|r")
    gossipHasClosed = false
    TargetnpcID:Hide();
end
