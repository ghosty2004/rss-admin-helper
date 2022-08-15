script_name("RSS Admin Helper");
script_author("Ghosty2004");
script_version("1.0.0");

local sampev = require("samp.events");
local imgui = require("imgui");
local key = require("vkeys");

local menuState = imgui.ImBool(false);
local menuTabs = {"Utility", "Auto", "Actions", "Blacklisted", "Whitelisted"};
local menuSelectedTab = imgui.ImInt(1);

local dingOnShot = imgui.ImBool(false);

local autoMute = imgui.ImBool(false);
local autoScreenShot = imgui.ImBool(true);
local autoReconnect = imgui.ImBool(true);
local autoRob = imgui.ImBool(false);

local robbedPlayers = {};

local whitelistedTags = {"{FF0000}(King)", "{FF0000}(Lord)", "{FF0000}({FFFFFF}RCON{FF0000})", "{0060ff}(Admin)"};
local blacklistedWords = {};
local whitelistedWords = {};

local sampDll = nil;

function main()
    repeat wait(0) until isSampAvailable();
    local _, tempSampDll = loadDynamicLibrary("samp.dll");
    if(not _) then return end;
    sampDll = tempSampDll;

    wait(4000);

    -- Load Blacklisted Words
    local file_blacklistedWords = io.open('moonloader\\RSSAdminHelper_blacklistedWords.txt', "r");
    for value in file_blacklistedWords:lines() do 
        table.insert(blacklistedWords, value);
    end

    -- Load Whitelisted Words
    local file_whitelistedWords = io.open('moonloader\\RSSAdminHelper_whitelistedWords.txt', "r");
    for value in file_whitelistedWords:lines() do 
        table.insert(whitelistedWords, value);
    end

    -- Load Mission Audio for "Ding On Shot"
    loadMissionAudio(1, 17802);

    sampAddChatMessage(string.format("[RSSBUSTER]: Loaded (Lua version: %s, Moonloader version: %d).", _VERSION, getMoonloaderVersion()), 0xFF0000);

    while true do
        wait(0);

        --> Menu toggle
        if(wasKeyPressed(key.VK_INSERT)) then
            menuState.v = not menuState.v;
        end
        imgui.Process = menuState.v;

        --> Auto Rob
        if(autoRob.v) then
            local players = getAllChars();
            for index, value in ipairs(players) do
                local _, id = sampGetPlayerIdByCharHandle(value);
                local _self, _self_id = sampGetPlayerIdByCharHandle(PLAYER_PED);

                local _posX, _posY, _posZ = getCharCoordinates(value);
                local _self_posX, _self_posY, _self_posZ = getCharCoordinates(PLAYER_PED);

                local distance = getDistanceBetweenCoords3d(_posX, _posY, _posZ, _self_posX, _self_posY, _self_posZ);

                if(_ and _self) then
                    if(id ~= _self_id) then
                        if(distance < 2.5) then
                            if(not isCharInAnyCar(PLAYER_PED) and not isCharInAnyCar(value)) then
                                if(robbedPlayers[id] == nil) then
                                    sampProcessChatInput("/rob " .. tostring(id));
                                    robbedPlayers[id] = true;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local style = imgui.GetStyle();
local colors = style.Colors;
local clr = imgui.Col;
local ImVec4 = imgui.ImVec4;

imgui.SwitchContext();

style.WindowRounding = 2.0;
style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84);
style.ChildWindowRounding = 2.0;
style.FrameRounding = 2.0;
style.WindowPadding = imgui.ImVec2(5, 5);
style.ScrollbarSize = 13.0;
style.ScrollbarRounding = 0;
style.GrabMinSize = 8.0;
style.GrabRounding = 1.0;

colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54);
colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40);
colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67);
colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00);
colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00);
colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00);
colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00);
colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00);
colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40);
colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00);
colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00);
colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31);
colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80);
colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00);
colors[clr.Separator]              = colors[clr.Border];
colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78);
colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00);
colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25);
colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67);
colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95);
colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35);
colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00);
colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94);
colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00);
colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
colors[clr.ComboBg]                = colors[clr.PopupBg];
colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50);
colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00);
colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00);
colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53);
colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00);
colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00);
colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00);
colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50);
colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00);
colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00);
colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35);

imgui.GetIO().FontGlobalScale = 1.3;

function imgui.OnDrawFrame()
    if(menuState.v) then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver);
        imgui.Begin("RSS Admin Helper", true, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse);

        imgui.Columns(2);
        imgui.SetColumnOffset(1, 100)

        for index, value in ipairs(menuTabs) do
            imgui.Spacing();
            imgui.PushStyleColor(imgui.Col.Button, (menuSelectedTab.v == index and colors[clr.ButtonActive] or colors[clr.Button]));
            if(imgui.Button(value, imgui.ImVec2(100 - 10, 30))) then menuSelectedTab.v = index; end
            imgui.PopStyleColor();
        end

        imgui.NextColumn();
        imgui.Spacing();

        if(menuSelectedTab.v == 1) then
            imgui.Checkbox("Ding On Shot", dingOnShot);
        elseif(menuSelectedTab.v == 2) then
            imgui.Checkbox("Mute", autoMute);
            imgui.Checkbox("Screen-Shot", autoScreenShot);
            imgui.Checkbox("Reconnect", autoReconnect);
            imgui.Checkbox("Rob", autoRob);
        elseif(menuSelectedTab.v == 3) then
            if(imgui.Button("Respect All")) then
                lua_thread.create(function()
                    wait(0);
                    local _, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED);
                    for i=0, 999 do
                        if(sampIsPlayerConnected(i) and i ~= playerId) then
                            wait(1100);
                            sampProcessChatInput(string.format("/respect %d 1 -> /respect %d 1 1", i, playerId));
                        end
                    end
                end);
            end
        elseif(menuSelectedTab.v == 4) then
            imgui.TextColored(ImVec4(1, 1, 0, 1), "Words");
            imgui.BeginChild("Words");
            for index, value in ipairs(blacklistedWords) do
                imgui.Text(string.format("%s", value));
            end
            imgui.EndChild();
        elseif(menuSelectedTab.v == 5) then
            imgui.BeginChild("Scroll");
            imgui.TextColored(ImVec4(1, 1, 0, 1), "Tags");
            for index, value in ipairs(whitelistedTags) do
                imgui.Text(string.format("%s", value));
            end
            imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Words");
            for index, value in ipairs(whitelistedWords) do
                imgui.Text(string.format("%s", value));
            end
            imgui.EndChild();
        end
        imgui.End();
    end
end

----------------
--> Events
----------------
function sampev.onSendGiveDamage(reader, writer) 
    if(dingOnShot.v) then
        playMissionAudio(1);
        clearCharLastDamageEntity(PLAYER_PED);
    end
end

function sampev.onServerMessage(color, text)
    if(not sampIsLocalPlayerSpawned() or not autoMute.v) then return end;

    local isAdminChat = false;
    local isVipChat = false;
    local isGangChat = false;
    local isClanChat = false;
    if(color == 872362922 and text:find("{FF9D00}Admin Chat: ")) then isAdminChat = true end
    if(color == 872362922 and text:find("{FF9D00}Vip Chat: ")) then isVipChat = true end
    if(color == -6487809 and text:find("Gang Chat{FF4800}:")) then isGangChat = true end
    if(color == -6487809 and text:find("Clan Chat: {FF4800}")) then isClanChat = true end

    if(not isAdminChat and not isVipChat and not isGangChat and not isClanChat and not isStringHasWhitelistedTag(text)) then
        local i, j = text:find("{15FF00}");
        if(i == nil) then return end;
        local newText = text:sub(j+1);
        local i2, j2 = newText:find(": {FFFFFF}");
        if(i2 == nil) then return end;
        local playerId = newText:sub(2, j2-11);
        if(isStringHaveBlacklistedWords(newText) and not isStringHaveWhitelistedWords(newText)) then
            lua_thread.create(function()
                wait(0);
                sampProcessChatInput(string.format("/mute %d limbaj vulgar.", playerId));
                playMissionAudio(1);
                takeScreenShot();
            end);
        end
    end
end

function sampev.onPlayerJoin(playerId, color, isNpc, nickname)
    if(isStringHaveBlacklistedWords(nickname)) then
        sampAddChatMessage(string.format("[RSSBUSTER]: Jucator conectat cu nume vulgar: %s(%d)", nickname, playerId), 0xFF0000);
    elseif((string.format("%s", nickname)):lower():find("(admin)")) then
        sampAddChatMessage(string.format("[RSSBUSTER]: Player %s(%d) connected with admin tag", nickname, playerId));
    end
end

function sampev.onConnectionLost() checkReconnect() end
function sampev.onConnectionClosed() checkReconnect() end

function sampev.onPlayerDeathNotification(killerId, killedId, reason)
    if(robbedPlayers[killedId] ~= nil) then
        robbedPlayers[killerId] = nil
    end
end

----------------
--> Functions
----------------
function checkReconnect()
    if(autoReconnect) then 
        local ip, port = sampGetCurrentServerAddress()
        sampConnectToServer(ip, port);
    end
end

function isStringHasWhitelistedTag(string)
    for index, value in ipairs(whitelistedTags) do
        if(string:find(value, 1, true)) then
            return true;
        end
    end
    return false;
end

function isStringHaveBlacklistedWords(string)
    for index, value in ipairs(blacklistedWords) do
        if(string:lower():find(value)) then
            return true;
        end
    end
    return false;
end

function isStringHaveWhitelistedWords(string)
    for index, value in ipairs(whitelistedWords) do
        if(string:lower():find(value)) then
            return true;
        end
    end
    return false;
end

function takeScreenShot()
    if(not autoScreenShot) then return end;
    lua_thread.create(function()
        wait(1000);
        --setVirtualKeyDown(key.VK_F8, false); -- for F8
        --writeMemory(sampDll + 0x119CBC, 1, 1, false); -- for F8 alternative but call function to "samp.dll"
        setVirtualKeyDown(key.VK_SNAPSHOT, true); -- for "prtsc"
    end);
end