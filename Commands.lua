local function sortAscendant(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys, order and function(a, b) return order(t, a, b) end or nil)
    
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function secondsToTime(seconds)
    local units = {
        {name = L.Years,   value = 31536000},
        {name = L.Days,   value = 86400},  
        {name = L.Hours, value = 3600},    
        {name = L.Minutes,   value = 60},     
        {name = L.Seconds,   value = 1}
    }
    
    local result = {}
    for _, unit in ipairs(units) do
        local unitValue = math.floor(seconds / unit.value)
        if unitValue > 0 then
            table.insert(result, ("%d %s"):format(unitValue, unit.name))
        end
        seconds = seconds % unit.value
    end
    return table.concat(result, ", ")
end

local function helpCommand()    
    print(L.HelpString)
    print("/totalplayed or /tp all - " .. L.HelpStringAll)
    print("/totalplayed or /tp server - " .. L.HelpStringServer)
    print("/totalplayed or /tp reset - " .. L.HelpStringReset)
end

local function getPlayedTime(param)
    local totalTime = 0
    for server, characters in pairs(PlayedTotal) do
        if param == "all" or GetRealmName() == server then
            print(WrapTextInColorCode(L.Server .. " : " .. server, "FFB5FFEB"))
            for characterID, datas in sortAscendant(characters, function(t, a, b) return t[b].time < t[a].time end) do
                local color = C_ClassColor.GetClassColor(datas.class)
                print("-> " .. WrapTextInColorCode(datas.name, color:GenerateHexColor()) .. " - " .. secondsToTime(datas.time) .. ".")
                totalTime = totalTime + datas.time
            end
        end
    end
    -- Localized message using placeholders for server/account and total time
    local serverMessage = param == "all" and L.Account or GetRealmName() .. " " .. L.Server
    local totalTimeString = secondsToTime(totalTime)
    local message = string.format(L.BurnedMessage, serverMessage, totalTimeString)
    print(WrapTextInColorCode(message, "ffffff00"))
end

local function deletePlayedTime(param)
    PlayedTotal = {}
    print(L.HelpStringReset .. " " .. L.Done)
end
local function commands(msg, editbox)
    local actions = {
        all = function() getPlayedTime("all") end,
        server = function() getPlayedTime("server") end,
        reset = function() deletePlayedTime("all") end
    }
    
    if actions[msg] then
        actions[msg]()
    else
        helpCommand()
    end
end

-- 슬래시 명령어 등록
SLASH_TOTALPLAYED1 = "/totalplayed"
SLASH_TOTALPLAYED2 = "/tp"

-- 두 슬래시 명령어를 기존 commands 함수와 연결
SlashCmdList["TOTALPLAYED"] = commands