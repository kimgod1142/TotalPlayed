-- 플레이 타임 이벤트 프레임 생성 및 이벤트 등록
local EventFrame = CreateFrame("frame", "PlayededFrame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
EventFrame:RegisterEvent("TIME_PLAYED_MSG")

-- 플레이 시간 데이터를 로컬 변수에 저장하는 함수
local function savePlayedTime(realm, playerGUID, class, name, time)
    PlayedTotal = PlayedTotal or {} -- PlayedTotal 초기화
    PlayedTotal[realm] = PlayedTotal[realm] or {}
    PlayedTotal[realm][playerGUID] = {
        name = name,
        time = time,
        lastregistered = C_DateAndTime.GetCurrentCalendarTime(),
        class = class
    }
    print("TotalPlayed - 이 캐릭터의 플레이 타임이 저장되었습니다.")
end

-- 이벤트 발생 시 호출되는 함수
EventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LEAVING_WORLD" then
        RequestTimePlayed()
    elseif event == "TIME_PLAYED_MSG" then
        local totalTimePlayed = ...
        local playerGUID = UnitGUID("player")
        local name = UnitName("player")
        local realm = GetRealmName()
        local localizedClass, englishClass = UnitClass("player")
        savePlayedTime(realm, playerGUID, englishClass, name, totalTimePlayed)
    end
end)

-- TODO:
-- - 매크로 /TotalPlayed resetCurrent [현재 캐릭터의 플레이 타임 초기화]
-- - 매크로 /TotalPlayed resetServer [현재 서버의 플레이 타임 초기화]